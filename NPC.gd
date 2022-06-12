extends Node2D

var velocity = 0
const STRENGTH = 20000
const NORMAL_FRICTION = 500
const MAX_FRICTION = 2000
var friction = 0
const WEIGHT = 1
const FORCE_DECAY = 100
const BARRIER = 5
var enemies = []

func _ready():
	pass # Replace with function body.


func _process(delta):
	calculate_friction(delta)
	position.x += velocity * delta * 10
	if friction > NORMAL_FRICTION:
		friction -= 100 * delta
	if friction > MAX_FRICTION:
		friction = MAX_FRICTION
	if velocity > BARRIER:
		velocity -= FORCE_DECAY * delta
	if velocity < -BARRIER:
		velocity += FORCE_DECAY * delta
	for enemy in enemies:
		if enemy.position.x > position.x:
			enemy.velocity += delta * 100
		else:
			enemy.velocity -= delta * 100
	if position.x > 1350 or position.x < 0:
		velocity *= -1
		

func calculate_friction(delta):
	friction += velocity * delta
	if velocity > 0:
		velocity -= friction * delta
		if velocity < 0:
			velocity = 0
	if velocity < 0:
		velocity += friction * delta
		if velocity > 0:
			velocity = 0

func _on_Area2D_area_entered(enemy_area):
	var enemy = enemy_area.get_parent()
	if enemy.get("velocity") != null:
		#is not player
		if not enemies.has(enemy):
			enemies.append(enemy)

func _on_Area2D_area_exited(enemy_area):
	var enemy = enemy_area.get_parent()
	enemies.erase(enemy)

