extends Node2D


const MAX_ROTATE = 25.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func rotate_standle(perc_rotate): 
	$StandleHandleBottom.rotation_degrees = (perc_rotate / 100.0) * MAX_ROTATE
