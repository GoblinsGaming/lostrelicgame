extends Node2D

func _ready():
	$ShushResetLabel.visible = false
	$Sprite.material.set_shader_param("should_greyscale", false)

func set_to_greyscale(): 
	$ShushResetLabel.visible = true
	$Sprite.material.set_shader_param("should_greyscale", true)
	
func set_to_color(): 
	$ShushResetLabel.visible = false
	$Sprite.material.set_shader_param("should_greyscale", false)
	$Sprite.material.set_shader_param("is_flashing", false)

func update_reset_time(reset_time): 
	$ShushResetLabel.text = str(ceil(reset_time))

func flash(): 
	$Sprite.material.set_shader_param("is_flashing", true)
	yield(get_tree().create_timer(0.2), "timeout")
	$Sprite.material.set_shader_param("is_flashing", false)
