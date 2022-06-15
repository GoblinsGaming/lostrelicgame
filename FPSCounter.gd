extends Node2D

func _process(delta):
	var fps = Engine.get_frames_per_second()    
	$Label.text = str(fps)
