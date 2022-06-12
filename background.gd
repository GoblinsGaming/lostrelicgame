extends Node2D

export var train_speed = 100
export var player_move_scale = 10.0

export var cloud_scale = 1
export var mountain_scale = 2
export var grass_far_scale = 3
export var grass_mid_far_scale = 4
export var grass_mid_close_scale = 5
export var grass_close_scale = 6

onready var background = $WildernessBackground

func _ready():
	background.get_node("CloudsClose").motion_scale.x = cloud_scale/player_move_scale
	background.get_node("Mountain").motion_scale.x = mountain_scale/player_move_scale
	background.get_node("GrassFar").motion_scale.x = grass_far_scale/player_move_scale
	background.get_node("GrassMidFar").motion_scale.x = grass_mid_far_scale/player_move_scale
	background.get_node("GrassMidClose").motion_scale.x = grass_mid_close_scale/player_move_scale
	background.get_node("GrassClose").motion_scale.x = grass_close_scale/player_move_scale	
	
func _process(delta):
	background.get_node("CloudsClose").motion_offset.x -= train_speed*cloud_scale*delta
	background.get_node("Mountain").motion_offset.x -= train_speed*mountain_scale*delta
	background.get_node("GrassFar").motion_offset.x -= train_speed*grass_far_scale*delta
	background.get_node("GrassMidFar").motion_offset.x -= train_speed*grass_mid_far_scale*delta
	background.get_node("GrassMidClose").motion_offset.x -= train_speed*grass_mid_close_scale*delta		
	background.get_node("GrassClose").motion_offset.x -= train_speed*grass_close_scale*delta		
