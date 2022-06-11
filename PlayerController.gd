extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var is_camera_drifting = false

export var player_left_speed = 1200
export var player_right_speed = 800

export var still_camera_drift_speed = 200
#export var moving_camera_drift_speed = 500
export var max_camera_drift = 500

export var does_flip = true
export var flip_speed = 10

var is_right = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	camera_drift_settings()
	
	if Input.is_action_pressed("right"): 
		if $Player.position.x < 4920: 
			$Player.position.x += player_right_speed*delta
		is_right = true
	elif Input.is_action_pressed("left"): 
		if $Player.position.x > 200: 
			$Player.position.x -= player_left_speed*delta
		is_right = false
	
	flip_sprite(delta)
	drift_camera(delta)

func flip_sprite(delta): 
	if does_flip:
		if is_right: 
			if $Player/Sprite.scale.x < 1: 
				$Player/Sprite.scale.x += flip_speed * delta
		else: 
			if $Player/Sprite.scale.x > -1: 
				$Player/Sprite.scale.x -= flip_speed * delta
	else: 
		if is_right:
			$Player/Sprite.flip_h = false
		else: 
			$Player/Sprite.flip_h = true

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
