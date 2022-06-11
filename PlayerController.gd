extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var is_camera_drifting = false

export var player_speed = 1000
export var still_camera_drift_speed = 200
#export var moving_camera_drift_speed = 500
export var max_camera_drift = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if Input.is_action_pressed("right"): 
		$Player.position.x += player_speed*delta
		$Player/Sprite.flip_h = false
	elif Input.is_action_pressed("left"): 
		$Player.position.x -= player_speed*delta
		$Player/Sprite.flip_h = true
	else: 
		drift_camera(delta)

func drift_camera(delta): 
	if Input.is_action_just_pressed("drift_camera"):
		is_camera_drifting = not is_camera_drifting
	if Input.is_action_just_pressed("camera_drift_up"):
		still_camera_drift_speed *= sqrt(2) 
	if Input.is_action_just_pressed("camera_drift_down"):
		still_camera_drift_speed /= sqrt(2)
			
	if not is_camera_drifting: 
		$Player/CameraNode.position.x = 0
		return
	
	if $Player/Sprite.flip_h: 
		if $Player/CameraNode.position.x > -max_camera_drift:
			$Player/CameraNode.position.x -= still_camera_drift_speed*delta
	else: 
		if $Player/CameraNode.position.x < max_camera_drift:
			$Player/CameraNode.position.x += still_camera_drift_speed*delta	
