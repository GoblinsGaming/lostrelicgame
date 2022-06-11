extends Node2D

var rng = RandomNumberGenerator.new()

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
	var target_index = rng.randi_range(0, unassigned_targets.size()-1)
	var next_target = unassigned_targets[target_index]
	unassigned_targets.remove(target_index)
	npc.walk_to_target(next_target)
	
func _process(delta):
	pass


