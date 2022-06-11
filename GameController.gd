extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var signal_half_width = 275
export var signal_fill_speed = 20
export var signal_reduction_speed = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	var player_x = $PlayerController/Player.position.x
	var signal_x = $SignalPoint.position.x
	var signal_bar = $CanvasLayer/SignalBar/ProgressBar

	
	if abs(signal_x - player_x) <= signal_half_width: 
		if signal_bar.value <= 100: 
			signal_bar.value = signal_bar.value + signal_fill_speed*delta
	else: 
		if signal_bar.value >= 0: 
			signal_bar.value = signal_bar.value - signal_reduction_speed*delta
