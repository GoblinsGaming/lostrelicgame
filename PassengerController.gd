extends Node2D

var rng = RandomNumberGenerator.new()

var NUM_TRIES = 3

var unassigned_targets = []
var passengers = []

var Passenger = preload("res://Passenger.gd")

func _ready():
	# TODO UNCOMMENT! 
	for seat in $Seating.get_children (): 
		unassigned_targets.append(seat)

	for handhold in $Handholds.get_children (): 
		unassigned_targets.append(handhold)
		
	for passenger in $Passengers.get_children(): 
		passengers.append(passenger)
		passenger.connect("stop_using_target", self, "_on_passenger_stop_using_target")

	for passenger in passengers:
		if passenger.passenger_state == Passenger.PassengerState.IDLE:
			walk_passenger_to_random_target(passenger)

func _on_passenger_stop_sitting(passenger): 
	if unassigned_targets.empty(): 
		passenger.reset_wait()
		return
	var last_target = passenger.target
	walk_passenger_to_random_target(passenger)
	unassigned_targets.append(last_target)

func _on_passenger_stop_using_target(passenger): 
	if unassigned_targets.empty(): 
		passenger.reset_wait()
		return
	var last_target = passenger.target
	walk_passenger_to_random_target(passenger)
	unassigned_targets.append(last_target)

func walk_passenger_to_random_target(passenger): 
	if unassigned_targets.empty():
		return
	var target_index
	
	var get_random = rng.randi_range(0,3)
	
	if get_random == 0: 
		target_index = rng.randi_range(0, unassigned_targets.size()-1)
	else: 
		var closest_dist = INF 
		var get_close_to
		get_close_to = self.get_parent().get_node("PlayerController").get_node("Player").position.x
		for new_target_index in range(0, unassigned_targets.size()-1):
			var new_target = unassigned_targets[new_target_index]
			var dist_to_close = abs(new_target.position.x - get_close_to)
			if dist_to_close < closest_dist:
				closest_dist = dist_to_close
				target_index = new_target_index

	var target = unassigned_targets[target_index]
	unassigned_targets.remove(target_index)
	passenger.walk_to_target(target)
	
func _process(delta):
	pass


