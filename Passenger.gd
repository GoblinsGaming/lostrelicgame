
extends Node2D

signal stop_using_target(this)

var PassengerTarget = preload("res://PassengerTarget.gd")

enum PassengerState {
	IDLE,
	WALK,
	HANDHOLD,
	SIT,
	SHOVE, 
	TRIP
}

const WALK_SPEED = 200
export var target_velocity = WALK_SPEED
export var seating_half_width = 20

var rng = RandomNumberGenerator.new()
var target
var target_x

var passenger_state = PassengerState.IDLE

export var min_time_for_state_change = 3
export var max_time_for_state_change = 6
var time_since_last_state_change = 0
var time_til_next_state_change = 0

export var shove_strength = 2
var velocity = 0
const FRICTION = 200
const INVINCIBILITY_TIME = 1
var invincibility_timer = 0
var is_invincible

const MAX_VELOCITY = 1200
const TRIP_VELOCITY = 800
const COMFORT_VELOCITY = 500

var is_npc = true

var is_bumped = true

var train_acceleration = 0
var slide_velocity_mult = 2
var slide_velocity = 0
var slide_velocity_change_rate = 0.5

func _ready():
	$AnimatedSprite.play("idle")
	var children = $Sound/Hit.get_children()
	for child in children:
		child.stream.loop = false
	
	# var seating = get_parent().get_node("train").get_node("chairs").get_node("Seating").get_node("Seating1")
	# target_seating_x = seating.position.x
	
func walk_to_target(new_target): 
	target = new_target
	target_x = target.position.x
	passenger_state = PassengerState.WALK
	
	reset_wait()

func _physics_process(delta): 
	if passenger_state == PassengerState.SHOVE and abs(velocity) < COMFORT_VELOCITY:
		passenger_state = PassengerState.WALK
		$AnimatedSprite.play("walk")
	if passenger_state in [PassengerState.WALK, PassengerState.SHOVE] and abs(velocity) > TRIP_VELOCITY: 
		passenger_state = PassengerState.TRIP
		$AnimatedSprite.play("trip")
	elif passenger_state == PassengerState.WALK and abs(velocity) > COMFORT_VELOCITY: 
		passenger_state = PassengerState.SHOVE
		$AnimatedSprite.play("shove")

	if passenger_state == PassengerState.SHOVE:
		if velocity > 0: 
			$AnimatedSprite.flip_h = false
		else: 
			$AnimatedSprite.flip_h = true
		
		# randomly trip

			
	if passenger_state == PassengerState.WALK: 
		$AnimatedSprite.play("walk")
		if position.x < target_x - seating_half_width:
			target_velocity = WALK_SPEED#  - train_acceleration
			$AnimatedSprite.flip_h = false
		elif position.x > target_x + seating_half_width:
			target_velocity = -WALK_SPEED#  + train_acceleration
			$AnimatedSprite.flip_h = true
		else: 
			if target.target_type == PassengerTarget.TargetType.SEAT:
				passenger_state = PassengerState.SIT
				position.x = target_x
				$AnimatedSprite.play("sit")
				reset_wait()
			elif target.target_type == PassengerTarget.TargetType.HANDHOLD:
				passenger_state = PassengerState.HANDHOLD
				position.x = target_x
				$AnimatedSprite.play("handhold")
				reset_wait()
			else: 
				passenger_state = PassengerState.IDLE
				printerr("Unexpected target type: " + str(target.target_type) + " for NPC")
				position.x = target_x
				$AnimatedSprite.play("idle")
				reset_wait()
				
	elif passenger_state in [PassengerState.SIT, PassengerState.HANDHOLD, PassengerState.TRIP] : 
		if time_since_last_state_change >= time_til_next_state_change: 
			emit_signal("stop_using_target", self)
		else: 
			time_since_last_state_change += delta
			
	velocity_calculations(delta) 

func set_train_acceleration(new_train_acceleration): 
	train_acceleration = -3*new_train_acceleration

func velocity_calculations(delta): 
	if passenger_state in [PassengerState.SIT, PassengerState.HANDHOLD]:
		return
	velocity = clamp(velocity, -MAX_VELOCITY, MAX_VELOCITY)
	
	if passenger_state == PassengerState.TRIP: 
		if velocity > 0:
			velocity -= FRICTION * delta
		else:
			velocity += FRICTION * delta
	else: 
		if velocity > target_velocity:
			velocity -= FRICTION * delta
		else:
			velocity += FRICTION * delta
		
	invincibility_timer -= delta
	if invincibility_timer > 0:
		$Sprite2.visible = true
		is_invincible = true
	else:
		$Sprite2.visible = false
		is_invincible = false
	if position.x < 200 or position.x > 5000:
		velocity = -velocity
	
	if position.x < 200:
		velocity = abs(velocity) + abs(velocity)*2
		position.x = 250
	if position.x > 5000:
		velocity = -abs(velocity) - abs(velocity)*2
		position.x = 4950
	
	position.x += velocity * delta
	if abs(slide_velocity - train_acceleration) > 4: 
		slide_velocity += (train_acceleration - slide_velocity)*delta*slide_velocity_change_rate

	position.x += delta*slide_velocity*slide_velocity_mult
	
	
func reset_wait(): 
	time_til_next_state_change = rng.randf_range(min_time_for_state_change, max_time_for_state_change)
	time_since_last_state_change = 0

func impact(player_velocity):
	if is_invincible:
		return
	if passenger_state != PassengerState.WALK:
		return

	velocity += player_velocity
	invincibility_timer = INVINCIBILITY_TIME
	hit_sound()

func impact_enemy(enemy_velocity):
	if is_invincible:
		return
	if passenger_state != PassengerState.WALK:
		return

	velocity += enemy_velocity
	invincibility_timer = INVINCIBILITY_TIME
	hit_sound()

func hit_sound():
	var children = $Sound/Hit.get_children()
	var sound = children[randi() % children.size()]
	sound.play()

func _on_Area2D_area_entered(enemy_area):
	var enemy = enemy_area.get_parent()
	if enemy.get("is_npc") != null:
		if is_invincible:
			enemy.impact_enemy(velocity)
