extends Node2D

var target_rot = 0
var rot_amount = 0
const rot_speed = 100

func _ready():
	pass

func _process(delta):
	if rot_amount < target_rot - 1: 
		rot_amount += rot_speed * delta
	elif rot_amount > target_rot + 1: 
		rot_amount -= rot_speed * delta
	rotate_standles(rot_amount)

func open_doors():
	pass

func close_doors():
	pass

func set_train_acceleration(new_acceleration):
	target_rot = sqrt(abs(new_acceleration))*5
	if new_acceleration <0: 
		target_rot = -target_rot
	target_rot = clamp(target_rot, -100, 100)


func rotate_standles(perc_rotate): 
	for standle in $Standles.get_children(): 
		standle.rotate_standle(perc_rotate)
