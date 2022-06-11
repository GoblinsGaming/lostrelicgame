extends Node2D

var rng = RandomNumberGenerator.new()

var NUM_TRIES = 3

var unassigned_targets = []
var Npcs = []

var Npc = preload("res://Npc.gd")

func _ready():
	for seat in $Seating.get_children (): 
		unassigned_targets.append(seat)
		
	for handhold in $Handholds.get_children (): 
		unassigned_targets.append(handhold)
		
	for npc in $Npcs.get_children(): 
		Npcs.append(npc)
		npc.connect("stop_using_target", self, "_on_npc_stop_using_target")

	for npc in Npcs:
		if npc.npc_state == Npc.NPCState.IDLE:
			walk_npc_to_random_target(npc)

func _on_npc_stop_sitting(npc): 
	if unassigned_targets.empty(): 
		npc.reset_wait()
		return
	var last_target = npc.target
	walk_npc_to_random_target(npc)
	unassigned_targets.append(last_target)

func _on_npc_stop_using_target(npc): 
	if unassigned_targets.empty(): 
		npc.reset_wait()
		return
	var last_target = npc.target
	walk_npc_to_random_target(npc)
	unassigned_targets.append(last_target)

func walk_npc_to_random_target(npc): 
	if unassigned_targets.empty():
		return
	var target_index
	
	var get_random = rng.randi_range(0,3) == 0
	
	if get_random: 
		target_index = rng.randi_range(0, unassigned_targets.size()-1)
	else: 
		var closest_dist = INF 
		var signal_pos_x = self.get_parent().get_node("SignalPoint").position.x
		for new_target_index in range(0, unassigned_targets.size()-1):
			var new_target = unassigned_targets[new_target_index]
			var dist_to_signal = abs(new_target.position.x - signal_pos_x)
			if dist_to_signal < closest_dist:
				closest_dist = dist_to_signal
				target_index = new_target_index

	var target = unassigned_targets[target_index]
	unassigned_targets.remove(target_index)
	npc.walk_to_target(target)
	
func _process(delta):
	pass


