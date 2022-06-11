extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var player_speed = 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if Input.is_action_pressed("right"): 
		$Player.position.x += player_speed*delta
		$Player/Sprite.flip_h = false
	elif Input.is_action_pressed("left"): 
		$Player.position.x -= player_speed*delta
		$Player/Sprite.flip_h = true
