extends Node2D

export var train_speed = 100
export var player_move_scale = 10.0

export var cloud_very_far_scale = 0.1
export var mountain_far_scale = 0.2
export var cloud_far_scale = 0.3
export var mountain_close_scale = 0.5
export var cloud_close_scale = 1
export var grass_far_scale = 4
export var grass_mid_far_scale = 5
export var grass_mid_close_scale = 6
export var grass_close_scale = 7

onready var background = $WildernessBackground

func _ready():
	background.get_node("CloudsVeryFar").motion_scale.x = cloud_very_far_scale/player_move_scale
	background.get_node("MountainFar").motion_scale.x = mountain_far_scale/player_move_scale
	background.get_node("CloudsFar").motion_scale.x = cloud_far_scale/player_move_scale
	background.get_node("MountainClose").motion_scale.x = mountain_close_scale/player_move_scale
	background.get_node("CloudsClose").motion_scale.x = cloud_close_scale/player_move_scale
	background.get_node("GrassFar").motion_scale.x = grass_far_scale/player_move_scale
	background.get_node("GrassMidFar").motion_scale.x = grass_mid_far_scale/player_move_scale
	background.get_node("GrassMidClose").motion_scale.x = grass_mid_close_scale/player_move_scale
	background.get_node("GrassClose").motion_scale.x = grass_close_scale/player_move_scale	
	
func _process(delta):
	background.get_node("CloudsVeryFar").motion_offset.x -= train_speed*cloud_very_far_scale*delta
	background.get_node("MountainFar").motion_offset.x -= train_speed*mountain_far_scale*delta
	background.get_node("CloudsFar").motion_offset.x -= train_speed*cloud_far_scale*delta
	background.get_node("MountainClose").motion_offset.x -= train_speed*mountain_close_scale*delta	
	background.get_node("CloudsClose").motion_offset.x -= train_speed*cloud_close_scale*delta
	background.get_node("GrassFar").motion_offset.x -= train_speed*grass_far_scale*delta
	background.get_node("GrassMidFar").motion_offset.x -= train_speed*grass_mid_far_scale*delta
	background.get_node("GrassMidClose").motion_offset.x -= train_speed*grass_mid_close_scale*delta		
	background.get_node("GrassClose").motion_offset.x -= train_speed*grass_close_scale*delta		

func set_mistiness(new_mistiness): 
	background.get_node("CloudsVeryFar").modulate = Color(1,1,1,new_mistiness)
	background.get_node("CloudsFar").modulate = Color(1,1,1,new_mistiness)
	background.get_node("CloudsClose").modulate = Color(1,1,1,new_mistiness)
