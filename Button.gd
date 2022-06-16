extends Node2D


export var is_active = true

func _ready():
	pass # Replace with function body.

#func _process(delta):
#	pass

func deactivate(): 
	is_active = false
	$Sprite.material.set_shader_param("should_highlight", false)

func activate(): 
	is_active = true
	$Sprite.material.set_shader_param("should_highlight", false)

func _on_ButtonArea2D_mouse_entered():
	if is_active: 
		$Sprite.material.set_shader_param("should_highlight", true)

func _on_ButtonArea2D_mouse_exited():
	if is_active: 
		$Sprite.material.set_shader_param("should_highlight", false)
