extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_train_acceleration(train_acceleration):
	for object in get_children():
		object.set_train_acceleration(train_acceleration)
