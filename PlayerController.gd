extends Node2D

export var player_left_speed = 1200
export var player_right_speed = 800

export var flip_speed = 10

var is_right = true

var player_velocity = 0
const PLAYER_WEIGHT = 1 
const PLAYER_MAX_FORCE = 1000
const PLAYER_MAX_VELOCITY = 2000
const PLAYER_STRENGTH = 5000
const LEAN_INDICATOR_MAX = 75
const PLAYER_FRICTION = 5

const LEAN_SPEED = 50

var Passenger = preload("res://Passenger.gd")

var train_acceleration = 0
var slide_velocity_mult = 2
var slide_velocity = 0
var slide_velocity_change_rate = 0.5

var is_shushing = false
var time_for_shush = 0

func _process(delta):
	player_main_process(delta)

func player_main_process(delta): 
	if is_shushing: 
		time_for_shush -= delta
		if time_for_shush <= 0: 
			is_shushing = false
			$Player/ShushSound.playing = false
	
	calculate_player_input_forces(delta)
	# player_velocity -= delta*train_acceleration*2
			
	player_velocity = clamp(player_velocity, -PLAYER_MAX_VELOCITY, PLAYER_MAX_VELOCITY)
	$Player.position.x += player_velocity * (delta / PLAYER_WEIGHT)	

	if player_velocity > 0 and train_acceleration > 0 or player_velocity < 0  and train_acceleration <0:
		player_velocity += train_acceleration*delta*slide_velocity_change_rate*1.5
		if abs(slide_velocity - train_acceleration) > 4: 
			slide_velocity += (train_acceleration - slide_velocity)*delta*slide_velocity_change_rate*0.3
			$Player.position.x += delta*slide_velocity*slide_velocity_mult
	else:		
		player_velocity += train_acceleration*delta*slide_velocity_change_rate*0.5
		if abs(slide_velocity - train_acceleration) > 4: 
			slide_velocity += (train_acceleration - slide_velocity)*delta*slide_velocity_change_rate
			$Player.position.x += delta*slide_velocity*slide_velocity_mult
			
	# Note, we specifically don't check equality here
	if player_velocity > 0: 
		is_right = true
	elif player_velocity < 0: 
		is_right = false
	
	if $Player.position.x < 200:
		player_velocity = abs(player_velocity) + abs(slide_velocity)*2
		$Player.position.x = 250
	if $Player.position.x > 5000:
		player_velocity = -abs(player_velocity) - abs(slide_velocity)*2
		$Player.position.x = 4950
	
	if player_velocity == 0:
		if is_shushing:
			$Player/Animations/BodyUpper.play("shush")
		else:
			$Player/Animations/BodyUpper.play("idle")
		$Player/Animations/BodyLower.play("idle")
		#$Player/Animations/BodyUpper.offset.x = 95
	else:
		if is_shushing:
			$Player/Animations/BodyUpper.play("shush")
		else:
			$Player/Animations/BodyUpper.play("run")
		$Player/Animations/BodyLower.play("run")
		#$Player/Animations/BodyUpper.offset.x = 103
	if abs(player_velocity) > abs(PLAYER_MAX_FORCE + 100):
		$Player/Animations/BodyUpper.visible = false
		$Player/Animations/BodyLower.visible = false
		$Player/Animations/BodyWhole.visible = true
	else:
		$Player/Animations/BodyUpper.visible = true
		$Player/Animations/BodyLower.visible = true
		$Player/Animations/BodyWhole.visible = false

	calculate_lean_indicator(player_velocity, delta)
	flip_sprite(delta)

func shush(): 
	if not is_shushing: 
		is_shushing = true
		time_for_shush = 2
		$Player/ShushSound.playing = true

func set_train_acceleration(new_train_acceleration): 
	train_acceleration = -3* new_train_acceleration
	$Player/CameraNode.set_train_acceleration(train_acceleration) 

func calculate_player_input_forces(delta):
	if Input.is_action_pressed("right"): 
		if player_velocity < 0:
			player_velocity += delta * PLAYER_STRENGTH  / (1 + sqrt(sqrt(abs(player_velocity))))
		elif player_velocity < PLAYER_MAX_FORCE:
			player_velocity += delta * PLAYER_STRENGTH / (1 + sqrt(abs(player_velocity)))
	elif Input.is_action_pressed("left"): 
		if player_velocity > 0:
			player_velocity -= delta * PLAYER_STRENGTH / (1 + sqrt(sqrt(abs(player_velocity))))
		elif player_velocity > -PLAYER_MAX_FORCE:
			player_velocity -= delta * PLAYER_STRENGTH / (1 + sqrt(abs(player_velocity)))
	else:
		calculate_friction()
	

func calculate_friction():
	# var target_velocity = -train_acceleration
	var target_velocity = 0
	if player_velocity > target_velocity:
		player_velocity -= PLAYER_FRICTION
		if player_velocity < target_velocity:
			player_velocity = target_velocity
	if player_velocity < target_velocity:
		player_velocity += PLAYER_FRICTION
		if player_velocity > target_velocity:
			player_velocity = target_velocity

func calculate_lean_indicator(player_net_velocity, delta):
	var lean_perc = player_net_velocity / PLAYER_MAX_FORCE
	var lean_angle = lean_perc * LEAN_INDICATOR_MAX
	if lean_angle > LEAN_INDICATOR_MAX:
		lean_angle = LEAN_INDICATOR_MAX
	$Player/LeanIndicator.rotation_degrees = lean_angle
	
	if player_net_velocity > 0:
		$Player/Animations/BodyUpper.rotation_degrees = lean_angle
	elif player_net_velocity < 0:
		$Player/Animations/BodyUpper.rotation_degrees = -lean_angle
	$Player/Animations/BodyUpper.speed_scale = abs(lean_perc)
	$Player/Animations/BodyLower.speed_scale = abs(lean_perc)

func _on_Area2D_area_entered(enemy_area):
	var enemy = enemy_area.get_parent()
	
	if enemy.name != "StevenHawk":
		if enemy.passenger_state != Passenger.PassengerState.WALK:
			return
	
	if enemy.is_invincible:
		return
	
	var enemy_velocity = enemy.velocity
	enemy.impact(player_velocity)
	player_velocity += enemy_velocity*enemy.shove_strength
	# player_velocity += (100 + enemy_velocity * (abs(player_velocity)/PLAYER_MAX_FORCE) * enemy.shove_strength)	
	
func _on_Area2D_area_exited(enemy_area):
	pass

func flip_sprite(delta): 
	if is_right: 
		if $Player/Animations.scale.x < 1: 
			$Player/Animations.scale.x += flip_speed * delta
	else: 
		if $Player/Animations.scale.x > -1: 
			$Player/Animations.scale.x -= flip_speed * delta
			
	if $Player/Animations.scale.x > 1: 
		$Player/Animations.scale.x = 1
	elif $Player/Animations.scale.x < -1:
		$Player/Animations.scale.x = -1
			
func get_player_x_position(): 
	return $Player.position.x

