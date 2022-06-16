extends Node2D



func _ready():
	pass # Replace with function body.

#func _process(delta):
#	pass

func _on_ButtonArea2D_mouse_entered():
	$Sprite.material.set_shader_param("should_highlight", true)

func _on_ButtonArea2D_mouse_exited():
	$Sprite.material.set_shader_param("should_highlight", false)
