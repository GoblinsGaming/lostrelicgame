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

# Called when the node enters the scene tree for the first time.
func _ready():
	signal_move_start = $SignalPoint.position.x


func _process(delta):
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
		
	var back = $background/WildernessBackground	
	$SignalPoint.position.x -= back.train_speed* signal_move_mult * delta
	if $SignalPoint.position.x < -250: 
		$SignalPoint.position.x = signal_move_start
	

	if Input.is_action_just_pressed("train_up"): 
		back.train_speed *= sqrt(2)
	elif Input.is_action_just_pressed("train_down"): 
		back.train_speed /= sqrt(2)
