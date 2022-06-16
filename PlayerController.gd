extends Node2D


export var is_camera_drifting = false

export var player_left_speed = 1200
export var player_right_speed = 800

export var still_camera_drift_speed = 200
#export var moving_camera_drift_speed = 500
export var max_camera_drift = 500

export var does_flip = true
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


func _physics_process(delta):
	player_main_process(delta)

func player_main_process(delta): 
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
		$Player/Animations/BodyUpper.play("idle")
		$Player/Animations/BodyLower.play("idle")
		$Player/Animations/BodyUpper.offset.x = 95
	else:
		$Player/Animations/BodyUpper.play("run")
		$Player/Animations/BodyLower.play("run")
		$Player/Animations/BodyUpper.offset.x = 103
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
	train_accelerate_drift_camera(delta)


func set_train_acceleration(new_train_acceleration): 
	train_acceleration = -3* new_train_acceleration

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
	if Input.is_action_pressed("ui_down"):
		player_velocity = 0
	

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
	if does_flip:
		if is_right: 
			if $Player/Sprite.scale.x < 1: 
				$Player/Sprite.scale.x += flip_speed * delta
				$Player/Animations.scale.x += flip_speed * delta
		else: 
			if $Player/Sprite.scale.x > -1: 
				$Player/Sprite.scale.x -= flip_speed * delta
				$Player/Animations.scale.x -= flip_speed * delta
	else: 
		if is_right:
			$Player/Sprite.flip_h = false
			$Player/Animations/BodyUpper.flip_h = false
			$Player/Animations/BodyLower.flip_h = false
		else: 
			$Player/Sprite.flip_h = true
			$Player/Animations/BodyUpper.flip_h = true
			$Player/Animations/BodyLower.flip_h = true


var train_acc_camera_drift = 300
var train_acc_cam_drift_spd = 0.2

func train_accelerate_drift_camera(delta): 
	var train_acc_camera_drift = -train_acceleration
	if camera_node_pos.x < train_acc_camera_drift - 4:
		var diff = train_acc_camera_drift - camera_node_pos.x 
		camera_node_pos.x += diff*delta*train_acc_cam_drift_spd
	elif camera_node_pos.x > train_acc_camera_drift - 4:
		var diff = train_acc_camera_drift - camera_node_pos.x 
		camera_node_pos.x += diff*delta*train_acc_cam_drift_spd


# Camera shake taken from https://kidscancode.org/godot_recipes/2d/screen_shake/

export var decay = 0.8  # How quickly the shaking stops [0, 1].
export var max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
export var max_roll = 0 # Maximum rotation in radians (use sparingly).
export (NodePath) var target  # Assign the node this camera will follow.
var rng = RandomNumberGenerator.new()

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].
onready var noise = OpenSimplexNoise.new()
var noise_y = 0
	
var camera_node_pos

func _ready():
	camera_node_pos = $Player/CameraNode.position
	noise.seed = rng.randi()
	noise.period = 4
	noise.octaves = 2
	
func _process(delta):
#	if Input.is_action_pressed("screenshake"):
#		trauma += delta
		
	if Input.is_action_just_pressed("screenshake"):
		trauma = 0.5
		
	if target:
		global_position = get_node(target).global_position
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	else: 
		$Player/CameraNode.position = camera_node_pos

func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	$Player/CameraNode.position.x = camera_node_pos.x + max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	$Player/CameraNode.position.y = camera_node_pos.y + max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)
	
