extends Node2D

export var train_speed = 100
export var player_move_scale = 10.0

export var cloud_scale = 1
export var mountain_scale = 2
export var tree_scale = 3

onready var background = $WildernessBackground

func _ready():
	background.get_node("CloudLayer").motion_scale.x = cloud_scale/player_move_scale
	background.get_node("MountainLayer").motion_scale.x = mountain_scale/player_move_scale
	background.get_node("TreeLayer").motion_scale.x = tree_scale/player_move_scale
	
func _process(delta):
	background.get_node("CloudLayer").motion_offset.x -= train_speed*cloud_scale*delta
	background.get_node("MountainLayer").motion_offset.x -= train_speed*mountain_scale*delta
	background.get_node("TreeLayer").motion_offset.x -= train_speed*tree_scale*delta

