extends Node2D

signal win
signal lose

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var signal_half_width = 275
export var signal_fill_speed = 50
export var signal_reduction_speed = 20
export var signal_threshold = 80
export var convo_fill_speed = 2
export var convo_reduction_speed = 0.5

export var signal_move_mult = 1
var signal_move_start 
var rng = RandomNumberGenerator.new()

onready var back = $background
var mistiness = 0
var mist_increase = true
var mist_change_rate = 1

var train_target_speed = 0
var train_acceleration = 100
var is_train_moving = false
var train_jutter_speed = 50
var train_jutter_acceleration = train_acceleration * 1.5
var is_train_juttering = false
var is_train_juttering_back = true
var is_train_speeding_up = false
var is_train_accelerating = false
var time_since_last_train_speed_change = 0
var time_to_next_train_speed_change = 0 

var time_to_next_signal_change = 10
var signal_target = 200

var time_to_sound = 10
var time_to_next_tunnel = 2

onready var signal_bar = $CanvasLayer/SignalBar/ProgressBar
onready var quiet_bar = $CanvasLayer/QuietBar/ProgressBar
onready var convo_bar = $CanvasLayer/ConvoBar/ProgressBar

func _ready():
	signal_move_start = $SignalPoint.position.x
	back.train_speed = 0
	time_to_next_train_speed_change = 8
	time_to_sound = 10
	time_to_next_tunnel = 18
	signal_bar.value = 0
	quiet_bar.value = 50
	convo_bar.value = 20


func _process(delta):
	signal_processing(delta)
	adjust_mist(delta)
	randomize_train_acceleration(delta)
	accelerate_train(delta)
	process_noise(delta)
	process_tunnel(delta)
	calculate_win_loss()
	start_train_sound(delta)

func start_train_sound(delta): 
	if time_to_sound > 0: 
		time_to_sound -= delta
	elif time_to_sound > -1: 
		$Sound/TrainBackground.playing = true
		time_to_sound = -2
		
	
func calculate_win_loss(): 
	if convo_bar.value >= 99:
		emit_signal("win")

var is_tunnel = false

func start_tunnel(): 
	$Tunnel.visible = true
	$Tunnel.position.x = 5982
	is_tunnel = true

func process_tunnel(delta): 
	if is_tunnel: 
		$Tunnel.position.x -= back.train_speed*delta*7
		if $Tunnel.position.x <= -34405: 
			is_tunnel = false
			$Tunnel.visible = false
			time_to_next_tunnel = rng.randf_range(10,60)
	else: 
		if time_to_next_tunnel > 0: 
			time_to_next_tunnel -= delta
		else: 
			start_tunnel()

const NOISE_DIST = 400
const SHUSH_DIST = 500
const QUIET_DEC = 80
const QUIET_INC = 50
const NOISE_THRESH = 50

var can_shush = true
var shush_reset_time = 0

func process_noise(delta): 
	var total_noise = 0
	var player_pos = $PlayerController.get_player_x_position()

	if is_train_accelerating:
		total_noise = sqrt(abs(train_acceleration))*2
	
	if not can_shush: 
		if Input.is_action_just_pressed("shush"):
			$CanvasLayer/ShushIndicator.flash()
		shush_reset_time -= delta

		if shush_reset_time <= 0:
			can_shush = true
			$CanvasLayer/ShushIndicator.set_to_color()
		$CanvasLayer/ShushIndicator.update_reset_time(shush_reset_time)
	else:
		if Input.is_action_just_pressed("shush"):
			$PlayerController.shush()
			can_shush = false
			shush_reset_time = 5
			$CanvasLayer/ShushIndicator.set_to_greyscale()
			$CanvasLayer/ShushIndicator.update_reset_time(shush_reset_time)
			
		# TODO timer on shushing to apply to the train noise as well
			for passenger in $PassengerController/Passengers.get_children():
				if abs(passenger.position.x - player_pos) < SHUSH_DIST:
					passenger.shush()
				
	for passenger in $PassengerController/Passengers.get_children():
		if abs(passenger.position.x - player_pos) < NOISE_DIST:
			total_noise += passenger.noise_level * (1.1 - abs(player_pos - passenger.position.x)/NOISE_DIST)
	
	var quiet = clamp(100 - total_noise, 0, 100)
	
	if quiet_bar.value < quiet - 2: 
		quiet_bar.value += QUIET_INC * delta
	elif quiet_bar.value > quiet + 2:
		quiet_bar.value -= QUIET_DEC * delta
#
	var styleBox = quiet_bar.get("custom_styles/fg") 
	if quiet_bar.value >= NOISE_THRESH: 
		styleBox.bg_color = Color(0.2, 0.9, 0.2)
	else: 
		styleBox.bg_color = Color(0.8, 0.5, 0.1)

func randomize_train_acceleration(delta): 
	if time_since_last_train_speed_change < time_to_next_train_speed_change: 
		time_since_last_train_speed_change += delta
		return 
	
	if back.train_speed < 600:
		train_target_speed = rng.randf_range(800, 1200)
	else: 
		train_target_speed = rng.randf_range(0, 400)
		
	if train_target_speed > back.train_speed:
		is_train_juttering = true
		is_train_juttering_back = true
		is_train_accelerating = true
		is_train_speeding_up = true
	else: 
		is_train_juttering = false
		is_train_juttering_back = false
		is_train_accelerating = true
		is_train_speeding_up = false
	time_since_last_train_speed_change = 0
	time_to_next_train_speed_change = rng.randf_range(6,30)
	
	var acc_mult = rng.randf_range(0.05, 0.2)
	train_acceleration = (train_target_speed - back.train_speed) * acc_mult
	train_jutter_acceleration =  train_acceleration * 1.5
		
func accelerate_train(delta): 
	if not is_train_accelerating:
		$Sound/TrainAccelerate.playing = false
		$Sound/TrainBrake.playing = false
		return
	
	if is_train_speeding_up:
		if is_train_juttering: 
			if back.train_speed > train_jutter_speed:
				is_train_juttering = false
				return
			if is_train_juttering_back:
				if back.train_speed > -train_jutter_speed:
					back.train_speed -= train_jutter_acceleration * delta
					$PlayerController.set_train_acceleration(-train_jutter_acceleration)
					$train.set_train_acceleration(-train_jutter_acceleration)
				else:
					is_train_juttering_back = false
			else: 
				if back.train_speed < train_jutter_speed:
					back.train_speed += train_jutter_acceleration * delta
					$PlayerController.set_train_acceleration(train_jutter_acceleration)
					$train.set_train_acceleration(train_jutter_acceleration)
				else:
					is_train_juttering = false
		else:
			if back.train_speed < train_target_speed:
				if not $Sound/TrainAccelerate.playing:
					$Sound/TrainAccelerate.playing = true
				$Sound/TrainAccelerate.volume_db = (train_acceleration/1200)*24 - 12
				back.train_speed += train_acceleration * delta
				$PlayerController.set_train_acceleration(train_acceleration)
				$PassengerController.set_train_acceleration(train_acceleration)
				$train.set_train_acceleration(train_acceleration)
				$ObjectsController.set_train_acceleration(train_acceleration)
			else: 
				$PlayerController.set_train_acceleration(0)
				$PassengerController.set_train_acceleration(0)
				$train.set_train_acceleration(0)
				$ObjectsController.set_train_acceleration(0)
				is_train_accelerating = false
	else: 
		if back.train_speed > train_target_speed:
			if not $Sound/TrainBrake.playing:
				$Sound/TrainBrake.playing = true
			back.train_speed += train_acceleration * delta
			$PlayerController.set_train_acceleration(train_acceleration)
			$PassengerController.set_train_acceleration(train_acceleration)
			$train.set_train_acceleration(train_acceleration)
			$ObjectsController.set_train_acceleration(train_acceleration)
		else: 
			$PlayerController.set_train_acceleration(0)
			$PassengerController.set_train_acceleration(0)
			$train.set_train_acceleration(0)
			$ObjectsController.set_train_acceleration(0)
			is_train_accelerating = false
	return

func signal_processing(delta): 
	var player_x = $PlayerController/Player.position.x
	var signal_x = $SignalPoint.position.x

	
	if abs(signal_x - player_x) <= signal_half_width: 
		if signal_bar.value <= 100: 
			signal_bar.value = signal_bar.value + signal_fill_speed*delta
	else: 
		if signal_bar.value >= 0: 
			signal_bar.value = signal_bar.value - signal_reduction_speed*delta
	
	var signalStyleBox = signal_bar.get("custom_styles/fg") 

	if signal_bar.value >= signal_threshold: 
		signalStyleBox.bg_color = Color(0.2, 0.9, 0.9)
	else: 
		signalStyleBox.bg_color = Color(1, 0, 0)
		
	# TODO Move this elsewhere
	var convoStyleBox = convo_bar.get("custom_styles/fg") 
	if signal_bar.value >= signal_threshold and quiet_bar.value >= NOISE_THRESH:
		convoStyleBox.bg_color = Color(0.1, 0.1, 0.8)
		if convo_bar.value < 100: 
			convo_bar.value += convo_fill_speed*delta
	else: 
		convoStyleBox.bg_color = Color(0.5, 0.5, 0.0)
		if convo_bar.value > 0:
			convo_bar.value -= convo_reduction_speed*delta
		
	#$SignalPoint.position.x -= back.train_speed* signal_move_mult * delta

	if time_to_next_signal_change > 0: 
		time_to_next_signal_change -= delta
	else: 
		signal_target = rng.randf_range(200, 5000) 
		time_to_next_signal_change = rng.randf_range(2, 20) 
	
	if $SignalPoint.position.x < signal_target - 4:
		$SignalPoint.position.x += 200 * signal_move_mult * delta
	elif $SignalPoint.position.x > signal_target + 4:
		$SignalPoint.position.x -= 200 * signal_move_mult * delta

func adjust_mist(delta):
	if mist_increase:
		if mistiness < 270:
			mistiness += mist_change_rate * delta
		else: 
			mist_increase = false
	else: 
		if mistiness > 90:
			mistiness -= mist_change_rate * delta
		else: 
			mist_increase = true
	back.set_mistiness(sin(deg2rad(mistiness)))
