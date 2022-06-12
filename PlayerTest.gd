extends Node2D


var player_force = 0
var player_net_force = 0
var player_velocity = 0
var enemies = []
var current_friction = 0
const PLAYER_WEIGHT = 10
const PLAYER_MAX_FORCE = 1000
const PLAYER_STRENGTH = 1000
const LEAN_INDICATOR_MAX = 45
const PLAYER_FRICTION = 500

func _ready():
	pass # Replace with function body.


func _process(delta):
	calculate_player_input_forces(delta)
	calculate_net_forces(delta)
	calculate_friction(delta)
	player_velocity += player_net_force * (delta / PLAYER_WEIGHT)
	print(player_velocity)
	position.x += player_velocity * delta * 10
	calculate_lean_indicator()
	if position.x > 1350 or position.x < 0:
		player_velocity *= -1


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

func calculate_net_forces(delta):
	player_net_force = player_force
	for enemy in enemies:
		var distance_mult = abs(position.x - enemy.position.x)
		if distance_mult < 15:
			distance_mult = 1.0
		var enemy_force_mult = 1.0 / sqrt(distance_mult)
		if position.x > enemy.position.x:
			player_net_force += enemy.STRENGTH * enemy_force_mult * delta
		else:
			player_net_force -= enemy.STRENGTH * enemy_force_mult * delta
	
func calculate_friction(delta):
	current_friction = player_velocity * player_velocity
	if player_net_force > 0:
		player_net_force -= current_friction
		if player_net_force < 0:
			player_net_force = 0
	if player_net_force < 0:
		player_net_force += current_friction
		if player_net_force > 0:
			player_net_force = 0

func calculate_lean_indicator():
	var lean_perc = player_force / PLAYER_MAX_FORCE
	var lean_angle = lean_perc * LEAN_INDICATOR_MAX
	$LeanIndicator.rotation_degrees = lean_angle

func _on_Area2D_area_entered(enemy_area):
	var enemy = enemy_area.get_parent()
	if position.x > enemy.position.x:
		enemy.velocity = -20
	else:
		enemy.velocity = 20
	enemy.friction += 6
	if not enemies.has(enemy):
		enemies.append(enemy)

func _on_Area2D_area_exited(enemy_area):
	var enemy = enemy_area.get_parent()
	enemies.erase(enemy)

