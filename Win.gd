extends Node2D

signal start_game

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
var time_to_next_train_speed_change = 15

func _ready():
	back.train_speed = 0
	time_to_next_train_speed_change = 10
	
func _process(delta):
	adjust_mist(delta)
	randomize_train_acceleration(delta)
	accelerate_train(delta)

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
	time_to_next_train_speed_change = rng.randf_range(6,20)
	
	var acc_mult = rng.randf_range(0.05, 0.2)
	train_acceleration = (train_target_speed - back.train_speed) * acc_mult
	train_jutter_acceleration =  train_acceleration * 1.5
		
func accelerate_train(delta): 
	if not is_train_accelerating: 
		return	
	
	if is_train_speeding_up:
		if is_train_juttering: 
			if back.train_speed > train_jutter_speed:
				is_train_juttering = false
				return
			if is_train_juttering_back:
				if back.train_speed > -train_jutter_speed:
					back.train_speed -= train_jutter_acceleration * delta
					$train.set_train_acceleration(-train_jutter_acceleration)
				else:
					is_train_juttering_back = false
			else: 
				if back.train_speed < train_jutter_speed:
					back.train_speed += train_jutter_acceleration * delta
					$train.set_train_acceleration(train_jutter_acceleration)
				else:
					is_train_juttering = false
		else:
			if back.train_speed < train_target_speed:
				back.train_speed += train_acceleration * delta

				$train.set_train_acceleration(train_acceleration)
				$ObjectsController.set_train_acceleration(train_acceleration)
			else: 
				$train.set_train_acceleration(0)
				$ObjectsController.set_train_acceleration(0)
				is_train_accelerating = false
	else: 
		if back.train_speed > train_target_speed:
			back.train_speed += train_acceleration * delta
			$train.set_train_acceleration(train_acceleration)
			$ObjectsController.set_train_acceleration(train_acceleration)
		else: 
			$train.set_train_acceleration(0)
			$ObjectsController.set_train_acceleration(0)
			is_train_accelerating = false
	$Title.train_speed = back.train_speed

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
