extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var train_speed = 0

func _ready():
	pass # Replace with function body.

func _process(delta):
	position.x -= 7*train_speed * delta
