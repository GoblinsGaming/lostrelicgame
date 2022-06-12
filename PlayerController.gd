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

func _ready():
	pass

func _process(delta):
	calculate_player_input_forces(delta)
	if $Player.position.x < 200:
		player_velocity = -player_velocity * 2
		$Player.position.x = 210
	if $Player.position.x > 5000:
		player_velocity = -player_velocity * 2
		$Player.position.x = 4990
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
		
	# Note, we specifically don't check equality here
	if player_velocity > 0: 
		is_right = true
	elif player_velocity < 0: 
		is_right = false
		
	# print(player_velocity)
	player_velocity = clamp(player_velocity, -PLAYER_MAX_VELOCITY, PLAYER_MAX_VELOCITY)
	$Player.position.x += player_velocity * (delta / PLAYER_WEIGHT)
	calculate_lean_indicator(delta)
	
	camera_drift_settings()
	flip_sprite(delta)
	drift_camera(delta)


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
	if player_velocity > 0:
		player_velocity -= PLAYER_FRICTION
		if player_velocity < 0:
			player_velocity = 0
	if player_velocity < 0:
		player_velocity += PLAYER_FRICTION
		if player_velocity > 0:
			player_velocity = 0

func calculate_lean_indicator(delta):
	var lean_perc = player_velocity / PLAYER_MAX_FORCE
	var lean_angle = lean_perc * LEAN_INDICATOR_MAX
	$Player/LeanIndicator.rotation_degrees = lean_angle
	
	if $Player/Animations/BodyUpper.rotation_degrees < abs(lean_angle):
		$Player/Animations/BodyUpper.rotation_degrees += delta * LEAN_SPEED
	elif $Player/Animations/BodyUpper.rotation_degrees > abs(lean_angle):
		$Player/Animations/BodyUpper.rotation_degrees -= delta * LEAN_SPEED
	#$Player/Animations/BodyUpper.rotation_degrees = abs(lean_angle)
	$Player/Animations/BodyUpper.speed_scale = abs(lean_perc)
	$Player/Animations/BodyLower.speed_scale = abs(lean_perc)
	print(abs(lean_perc))

func _on_Area2D_area_entered(enemy_area):
	var enemy = enemy_area.get_parent()
	if enemy.passenger_state != Passenger.PassengerState.WALK:
		return
	if enemy.is_invincible:
		return
	if player_velocity > 0:
		player_velocity *= 0.6
		if player_velocity < 0:
			player_velocity = 0
		enemy.impact(player_velocity)
	else:
		player_velocity *= 0.6
		if player_velocity > 0:
			player_velocity = 0
		enemy.impact(player_velocity)

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

func camera_drift_settings(): 
	if Input.is_action_just_pressed("drift_camera"):
		is_camera_drifting = not is_camera_drifting
	if Input.is_action_just_pressed("camera_drift_up"):
		still_camera_drift_speed *= sqrt(2) 
	if Input.is_action_just_pressed("camera_drift_down"):
		still_camera_drift_speed /= sqrt(2)

func drift_camera(delta): 
	if not is_camera_drifting: 
		$Player/CameraNode.position.x = 0
		return
	
	if is_right: 
		if $Player/CameraNode.position.x < max_camera_drift:
			$Player/CameraNode.position.x += still_camera_drift_speed*delta	
	else: 
		if $Player/CameraNode.position.x > -max_camera_drift:
			$Player/CameraNode.position.x -= still_camera_drift_speed*delta


