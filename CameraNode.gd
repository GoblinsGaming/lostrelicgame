extends Node2D

export var still_camera_drift_speed = 200
#export var moving_camera_drift_speed = 500
export var max_camera_drift = 500

export var is_camera_drifting = false

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


var train_acc_camera_drift = 300
var train_acc_cam_drift_spd = 0.2
var train_acceleration = 0

func _ready():
	camera_node_pos = position
	noise.seed = rng.randi()
	noise.period = 4
	noise.octaves = 2

func _physics_process(delta):
	train_accelerate_drift_camera(delta)

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
		position = camera_node_pos

func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	position.x = camera_node_pos.x + max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	position.y = camera_node_pos.y + max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)
	
func set_train_acceleration(new_train_acceleration): 
	train_acceleration = new_train_acceleration
	
func train_accelerate_drift_camera(delta): 
	var train_acc_camera_drift = -train_acceleration
	if camera_node_pos.x < train_acc_camera_drift - 4:
		var diff = train_acc_camera_drift - camera_node_pos.x 
		camera_node_pos.x += diff*delta*train_acc_cam_drift_spd
	elif camera_node_pos.x > train_acc_camera_drift - 4:
		var diff = train_acc_camera_drift - camera_node_pos.x 
		camera_node_pos.x += diff*delta*train_acc_cam_drift_spd

