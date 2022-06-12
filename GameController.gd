extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var signal_half_width = 275
export var signal_fill_speed = 50
export var signal_reduction_speed = 20
export var signal_threshold = 80
export var convo_fill_speed = 8
export var convo_reduction_speed = 2

export var signal_move_mult = 1
var signal_move_start 
var rng = RandomNumberGenerator.new()

onready var back = $background
var mistiness = 0
var mist_increase = true
var mist_change_rate = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	signal_move_start = $SignalPoint.position.x
	back.train_speed = 0

func _process(delta):
	signal_processing(delta)
	adjust_mist(delta)
	accelerate_train(delta)

var train_target_speed = 0

var train_acceleration = 500

var is_train_moving = false

var train_jutter_speed = 50
var train_jutter_acceleration = train_acceleration * 1.5
var is_train_juttering = false
var is_train_juttering_back = true

var is_train_speeding_up = false
var is_train_accelerating = false


func accelerate_train(delta): 
	if Input.is_action_just_pressed("train_up"): 
		train_target_speed = 800
		train_acceleration = 300
		train_jutter_acceleration =  train_acceleration * 1.5
		is_train_juttering = true
		is_train_juttering_back = true
		is_train_accelerating = true
		is_train_speeding_up = true
	
	if Input.is_action_just_pressed("train_double_up"): 
		train_target_speed = 1200
		train_acceleration = 500
		train_jutter_acceleration =  train_acceleration * 1.5
		is_train_juttering = true
		is_train_juttering_back = true
		is_train_accelerating = true
		is_train_speeding_up = true
		
	if Input.is_action_just_pressed("train_down"): 
		train_target_speed = 0
		train_acceleration = 300
		train_jutter_acceleration =  train_acceleration * 1.5
		is_train_juttering = false
		is_train_juttering_back = false
		is_train_accelerating = true
		is_train_speeding_up = false
			
	if Input.is_action_just_pressed("train_double_down"): 
		train_target_speed = 0
		train_acceleration = 500
		train_jutter_acceleration =  train_acceleration * 1.5
		is_train_juttering = false
		is_train_juttering_back = false
		is_train_accelerating = true
		is_train_speeding_up = false
		
	if not is_train_accelerating: 
		return
		
	if is_train_juttering: 
		if back.train_speed > train_jutter_speed:
			is_train_juttering = false
			return
		if is_train_juttering_back:
			if back.train_speed > -train_jutter_speed:
				back.train_speed -= train_jutter_acceleration * delta
				$PlayerController.set_train_acceleration(-train_jutter_acceleration)
			else:
				is_train_juttering_back = false
		else: 
			if back.train_speed < train_jutter_speed:
				back.train_speed += train_jutter_acceleration * delta
				$PlayerController.set_train_acceleration(train_jutter_acceleration)
			else:
				is_train_juttering = false
	else:
		if is_train_speeding_up:
			if back.train_speed < train_target_speed:
				back.train_speed += train_acceleration * delta
				$PlayerController.set_train_acceleration(train_acceleration)
			else: 
				$PlayerController.set_train_acceleration(0)
				is_train_accelerating = false
		else: 
			if back.train_speed > train_target_speed:
				back.train_speed -= train_acceleration * delta
				$PlayerController.set_train_acceleration(-train_acceleration)
			else: 
				$PlayerController.set_train_acceleration(0)
				is_train_accelerating = false

	return
	
	if Input.is_action_just_pressed("train_up"): 
		back.train_speed *= sqrt(2)
	elif Input.is_action_just_pressed("train_down"): 
		back.train_speed /= sqrt(2)
		
	

func signal_processing(delta): 
	var player_x = $PlayerController/Player.position.x
	var signal_x = $SignalPoint.position.x
	var signal_bar = $CanvasLayer/SignalBar/ProgressBar
	var convo_bar = $CanvasLayer/ConvoBar/ProgressBar
	
	if abs(signal_x - player_x) <= signal_half_width: 
		if signal_bar.value <= 100: 
			signal_bar.value = signal_bar.value + signal_fill_speed*delta
	else: 
		if signal_bar.value >= 0: 
			signal_bar.value = signal_bar.value - signal_reduction_speed*delta
	
	var styleBox = signal_bar.get("custom_styles/fg") 
	if signal_bar.value >= signal_threshold: 
		styleBox.bg_color = Color(0, 1, 0)
		if convo_bar.value <= 100: 
			convo_bar.value += convo_fill_speed*delta
	else: 
		styleBox.bg_color = Color(1, 0, 0)
		convo_bar.value -= convo_reduction_speed*delta
		
	$SignalPoint.position.x -= back.train_speed* signal_move_mult * delta
	if $SignalPoint.position.x < -250: 
		$SignalPoint.position.x = signal_move_start

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
