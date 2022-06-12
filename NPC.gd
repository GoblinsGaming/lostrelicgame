extends Node2D

var velocity = 0
const FRICTION = 200
const INVINCIBILITY_TIME = 1
var invincibility_timer = 0
var is_invincible
var is_npc = true

func _ready():
	pass


func _process(delta):
	position.x += velocity * delta
	if velocity > 0:
		velocity -= FRICTION * delta
		if velocity < 0:
			velocity = 0
	else:
		velocity += FRICTION * delta
		if velocity > 0:
			velocity = 0
	invincibility_timer -= delta
	if invincibility_timer > 0:
		$Sprite2.visible = true
		is_invincible = true
	else:
		$Sprite2.visible = false
		is_invincible = false
	if position.x < 0 or position.x > 1350:
		velocity = -velocity

func impact(player_velocity):
	if is_invincible:
		return
	else:
		velocity += player_velocity * 20
		invincibility_timer = INVINCIBILITY_TIME

func _on_Area2D_area_entered(enemy_area):
	var enemy = enemy_area.get_parent()
	if enemy.get("is_npc") != null:
		if is_invincible:
			enemy.impact(velocity / 16)
