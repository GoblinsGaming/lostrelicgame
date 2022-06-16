extends Node2D

var train_acceleration = 0
var roll_velocity_mult = 2
var roll_velocity_change_rate = 0.5

export var shove_strength = 4
var velocity = -100
const FRICTION = 200
const INVINCIBILITY_TIME = 1
var invincibility_timer = 0
var is_invincible
const MAX_VELOCITY = 1200

func _ready():
	var sounds = $Sound/Hit.get_children()
	for sound in sounds:
		sound.stream.loop = false

func _physics_process(delta):
	velocity_calculations(delta)

func velocity_calculations(delta):
	velocity = clamp(velocity, -MAX_VELOCITY, MAX_VELOCITY)	
	velocity += train_acceleration*delta*roll_velocity_change_rate*0.5
	if abs(velocity - train_acceleration) > 4: 
		velocity += (train_acceleration - velocity)*delta*roll_velocity_change_rate
		position.x += delta*velocity*roll_velocity_mult
		$Wheel.rotation_degrees += delta*velocity*roll_velocity_mult
		
	invincibility_timer -= delta
	if invincibility_timer > 0:
		is_invincible = true
	else:
		is_invincible = false
	
	if position.x < 200:
		velocity = abs(velocity)
		position.x = 250
		$AnimatedSprite.play("lurch")
	if position.x > 5000:
		velocity = -abs(velocity)
		position.x = 4950
		$AnimatedSprite.play("brake")
	
	position.x += velocity * delta
		
func set_train_acceleration(new_train_acceleration): 
	train_acceleration = -3* new_train_acceleration

func impact(player_velocity):
	if is_invincible:
		return
	$AnimatedSprite.frame = 0
	if velocity < player_velocity: 
		$AnimatedSprite.play("lurch")
	else: 
		$AnimatedSprite.play("brake")
	velocity += player_velocity/4
	invincibility_timer = INVINCIBILITY_TIME
	hit_sound()

func impact_enemy(enemy_velocity):
	if is_invincible:
		return
	velocity += enemy_velocity
	invincibility_timer = INVINCIBILITY_TIME
	hit_sound()

func hit_sound():
	var children = $Sound/Hit.get_children()
	var sound = children[randi() % children.size()]
	sound.play()

func _on_StevenArea2D_area_entered(enemy_area):
	var enemy = enemy_area.get_parent()
	if enemy.get("is_npc") != null:
		if abs(velocity - enemy.velocity) > 200:
			enemy.impact_enemy(velocity)

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation != "moving":
		$AnimatedSprite.play("moving")
