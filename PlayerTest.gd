extends Node2D


var player_force = 0
var player_net_force = 0
var player_velocity = 0
const PLAYER_WEIGHT = 1 
const PLAYER_MAX_FORCE = 500
const PLAYER_STRENGTH = 1000
const LEAN_INDICATOR_MAX = 45
const PLAYER_FRICTION = 50

func _ready():
	pass # Replace with function body.


func _process(delta):
	calculate_player_input_forces(delta)
	if position.x < 0 or position.x > 1350:
		player_force = -player_force
	calculate_friction()
	player_velocity = player_net_force * (delta / PLAYER_WEIGHT)
	print(player_velocity)
	position.x += player_velocity
	calculate_lean_indicator()


func calculate_player_input_forces(delta):
	if Input.is_action_pressed("right"): 
		player_force += delta * PLAYER_STRENGTH
		if player_force > PLAYER_MAX_FORCE:
			player_force = PLAYER_MAX_FORCE
	elif Input.is_action_pressed("left"): 
		player_force -= delta * PLAYER_STRENGTH
		if player_force < -PLAYER_MAX_FORCE:
			player_force = -PLAYER_MAX_FORCE
	if Input.is_action_pressed("ui_down"):
		player_force = 0

	
func calculate_friction():
	player_net_force = player_force
	if player_net_force > 0:
		player_net_force -= PLAYER_FRICTION
		if player_net_force < 0:
			player_net_force = 0
	if player_net_force < 0:
		player_net_force += PLAYER_FRICTION
		if player_net_force > 0:
			player_net_force = 0

func calculate_lean_indicator():
	var lean_perc = player_force / PLAYER_MAX_FORCE
	var lean_angle = lean_perc * LEAN_INDICATOR_MAX
	$LeanIndicator.rotation_degrees = lean_angle

func _on_Area2D_area_entered(enemy_area):
	var enemy = enemy_area.get_parent()
	if enemy.is_invincible:
		return
	if player_force > 0:
		player_force -= 500
		if player_force < 0:
			player_force = 0
		enemy.impact(player_velocity)
	else:
		player_force += 500
		if player_force > 0:
			player_force = 0
		enemy.impact(player_velocity)

func _on_Area2D_area_exited(enemy_area):
	player_force *= 1.3
