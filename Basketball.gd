extends Node2D

var speed = -100


var train_acceleration = 0
var roll_velocity_mult = 2
var roll_velocity_change_rate = 0.5

func _ready():
	pass # Replace with function body.

func _process(delta):
	speed += train_acceleration*delta*roll_velocity_change_rate*0.5
	if abs(speed - train_acceleration) > 4: 
		speed += (train_acceleration - speed)*delta*roll_velocity_change_rate
		position.x += delta*speed*roll_velocity_mult
		$Outline.rotation_degrees += delta*speed*roll_velocity_mult
		
	if position.x < 200:
		speed = abs(speed)
		position.x = 250
	if position.x > 5000:
		speed = -abs(speed)
		position.x = 4950
		
func set_train_acceleration(new_train_acceleration): 
	train_acceleration = -3* new_train_acceleration
