extends Node2D
signal stop_using_target(this)

var PassengerTarget = preload("res://PassengerTarget.gd")

enum PassengerState {
	IDLE,
	WALK,
	HANDHOLD,
	SIT,
	SHOVE, 
	TRIP
}

export var passenger_speed = 300
export var seating_half_width = 20


var rng = RandomNumberGenerator.new()
var target
var target_x

var passenger_state = PassengerState.IDLE

export var min_time_for_state_change = 3
export var max_time_for_state_change = 6
var time_since_last_state_change = 0
var time_til_next_state_change = 0

func _ready():
	$AnimatedSprite.play("idle")
	# var seating = get_parent().get_node("train").get_node("chairs").get_node("Seating").get_node("Seating1")
	# target_seating_x = seating.position.x
	
func walk_to_target(new_target): 
	target = new_target
	target_x = target.position.x
	passenger_state = PassengerState.WALK
	reset_wait()
	
func _process(delta): 
	if passenger_state == PassengerState.WALK: 
		$AnimatedSprite.play("walk")
		if position.x < target_x - seating_half_width:
			position.x += passenger_speed * delta
			$AnimatedSprite.flip_h = false
		elif position.x > target_x + seating_half_width:
			position.x -= passenger_speed * delta
			$AnimatedSprite.flip_h = true
		else: 
			if target.target_type == PassengerTarget.TargetType.SEAT:
				passenger_state = PassengerState.SIT
				position.x = target_x
				$AnimatedSprite.play("sit")
				reset_wait()
			elif target.target_type == PassengerTarget.TargetType.HANDHOLD:
				passenger_state = PassengerState.HANDHOLD
				position.x = target_x
				$AnimatedSprite.play("handhold")
				reset_wait()
			else: 
				passenger_state = PassengerState.IDLE
				printerr("Unexpected target type: " + str(target.target_type) + " for NPC")
				position.x = target_x
				$AnimatedSprite.play("idle")
				reset_wait()
				
	elif passenger_state in [PassengerState.SIT, PassengerState.HANDHOLD] : 
		if time_since_last_state_change >= time_til_next_state_change: 
			emit_signal("stop_using_target", self)
		else: 
			time_since_last_state_change += delta
			
func reset_wait(): 
	time_til_next_state_change = rng.randf_range(min_time_for_state_change, max_time_for_state_change)
	time_since_last_state_change = 0
