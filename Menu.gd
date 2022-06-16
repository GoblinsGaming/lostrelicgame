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


onready var start_button = $ButtonsLayer/StartButton
onready var help_button = $ButtonsLayer/HelpButton
onready var credits_button = $ButtonsLayer/CreditsButton
onready var exit_button = $ButtonsLayer/ExitButton

onready var start_layer = $StartLayer/StartScreen

onready var help_layer = $HelpLayer/HelpScreen
onready var close_help_button = $HelpLayer/HelpScreen/CloseHelpButton

onready var credits_layer = $CreditsLayer/CreditsScreen
onready var close_credits_button = $CreditsLayer/CreditsScreen/CloseCreditsButton

onready var exit_layer = $ExitLayer/ExitScreen
onready var close_exit_button = $ExitLayer/ExitScreen/CloseExitButton

var is_help_open = false
var is_credits_open = false
var is_exit_open = false

func _ready():
	back.train_speed = 0
	time_to_next_train_speed_change = 10
	start_layer.visible = false
	help_layer.visible = false
	credits_layer.visible = false
	exit_layer.visible = false
	activate_menu_buttons()
	close_help_button.deactivate()
	close_credits_button.deactivate()
	close_exit_button.deactivate()
		
func activate_menu_buttons(): 
	start_button.activate()
	help_button.activate()
	credits_button.activate()
	exit_button.activate()

func deactivate_menu_buttons(): 
	start_button.deactivate()
	help_button.deactivate()
	credits_button.deactivate()
	exit_button.deactivate()

func _on_StartButtonArea2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		if not is_help_open and not is_credits_open and not is_exit_open:
			start_layer.visible = true
			yield(get_tree().create_timer(0.2), "timeout")
			emit_signal("start_game")
		
func _on_HelpButtonArea2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		if not is_help_open and not is_credits_open and not is_exit_open:
			is_help_open = true
			help_layer.visible = true
			close_help_button.activate()
			deactivate_menu_buttons()
		
func _on_CreditsButtonArea2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		if not is_help_open and not is_credits_open and not is_exit_open:
			is_credits_open = true
			credits_layer.visible = true
			close_credits_button.activate()
			deactivate_menu_buttons()
		
func _on_ExitButtonArea2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		if not is_help_open and not is_credits_open and not is_exit_open:
			is_exit_open = true
			exit_layer.visible = true
			close_exit_button.activate()
			deactivate_menu_buttons()

func _on_CloseHelpButtonArea2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		if is_help_open:
			is_help_open = false
			help_layer.visible = false
			close_help_button.deactivate()
			activate_menu_buttons()

func _on_CloseCreditsButtonArea2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		if is_credits_open:
			is_credits_open = false
			credits_layer.visible = false
			close_credits_button.deactivate()
			activate_menu_buttons()

func _on_CloseExitButtonArea2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		if is_exit_open:
			is_exit_open = false
			exit_layer.visible = false
			close_exit_button.deactivate()
			activate_menu_buttons()
