
extends Node2D

signal stop_using_target(this)

var PassengerTarget = preload("res://PassengerTarget.gd")
var BodyUpper
var BodyLower
var Accessories
var rng = RandomNumberGenerator.new()
var preseated_y

enum PassengerState {
	IDLE,
	WALK,
	SIT,
	SHOVE, 
	TRIP
	}

const WALK_SPEED = 200
export var target_velocity = WALK_SPEED
export var seating_half_width = 20

var target
var target_x

var passenger_state = PassengerState.IDLE

export var min_time_for_state_change = 8
export var max_time_for_state_change = 30
var time_since_last_state_change = 0
var time_til_next_state_change = 0

export var shove_strength = 2
var velocity = 0
const FRICTION = 200
const INVINCIBILITY_TIME = 1
var invincibility_timer = 0
var is_invincible

var noise_level = 0
const min_noise_increase_rate = 5
const max_noise_increase_rate = 20
const MAX_NOISE_LEVEL = 50
const MIN_TIME_BETWEEN_NOISE_CHANGES = 1
const MAX_TIME_BETWEEN_NOISE_CHANGES = 10
const MAX_VELOCITY = 1200
const TRIP_VELOCITY = 1000
const COMFORT_VELOCITY = 700

var time_to_next_noise_change = 0

var is_npc = true

var is_bumped = true

var train_acceleration = 0
var slide_velocity_mult = 2
var slide_velocity = 0
var slide_velocity_change_rate = 0.5

func _ready():
	rng.randomize()
	time_to_next_noise_change = rng.randf_range(MIN_TIME_BETWEEN_NOISE_CHANGES,MAX_TIME_BETWEEN_NOISE_CHANGES)
	# $AnimatedSprite.play("idle")
	var children = $Sound/Hit.get_children()
	for child in children:
		child.stream.loop = false
	invisibilize()
	generate_npc()
	
	# var seating = get_parent().get_node("train").get_node("chairs").get_node("Seating").get_node("Seating1")
	# target_seating_x = seating.position.x
	
func walk_to_target(new_target): 
	target = new_target
	target_x = target.position.x
	passenger_state = PassengerState.WALK
	
	reset_wait()

func _process(delta):
	if passenger_state == PassengerState.SIT:
		if time_to_next_noise_change > 0:
			time_to_next_noise_change -= delta
		else: 
			if noise_level < MAX_NOISE_LEVEL:
				noise_level += rng.randf_range(min_noise_increase_rate, max_noise_increase_rate)
			noise_level = clamp(noise_level, 0, MAX_NOISE_LEVEL)
			$Animations/Speech.scale.x = (noise_level / MAX_NOISE_LEVEL) * 2
			$Animations/Speech.scale.y = (noise_level / MAX_NOISE_LEVEL) * 2
			$Animations/Speech.visible = false
			if noise_level > 15:
				$Animations/Speech.visible = true
				$Sound/Talk/AudioStreamPlayer2D.playing = true
				$Sound/Talk/AudioStreamPlayer2D.volume_db = (noise_level / MAX_NOISE_LEVEL) * 24 - 12
			time_to_next_noise_change = rng.randf_range(MIN_TIME_BETWEEN_NOISE_CHANGES,MAX_TIME_BETWEEN_NOISE_CHANGES)

func _physics_process(delta): 
	if passenger_state == PassengerState.WALK:
		passenger_state = PassengerState.WALK
		BodyUpper.play("walk")
		BodyLower.play("walk")
		BodyUpper.rotation_degrees = 0
		Accessories.position.x = 0
		Accessories.position.y = 0
		Accessories.rotation_degrees = 0
	if passenger_state == PassengerState.SHOVE and abs(velocity) < COMFORT_VELOCITY:
		passenger_state = PassengerState.WALK
		BodyUpper.play("walk")
		BodyLower.play("walk")
		BodyUpper.rotation_degrees = 0
		Accessories.position.x = 0
		Accessories.position.y = 0
		Accessories.rotation_degrees = 0
	if passenger_state in [PassengerState.WALK, PassengerState.SHOVE] and abs(velocity) > TRIP_VELOCITY: 
		BodyUpper.rotation_degrees = 0
		passenger_state = PassengerState.TRIP
		BodyUpper.play("dmcrun")
		BodyLower.play("dmcrun")
		Accessories.position.x = 40
		Accessories.position.y = 106
		Accessories.rotation_degrees = 44
	elif passenger_state == PassengerState.WALK and abs(velocity) > COMFORT_VELOCITY: 
		passenger_state = PassengerState.SHOVE
		BodyUpper.rotation_degrees = 45
		BodyUpper.play("run")
		BodyLower.play("run")
		Accessories.position.x = 0
		Accessories.position.y = 0
		Accessories.rotation_degrees = 45

	if passenger_state == PassengerState.SHOVE or passenger_state == PassengerState.TRIP:
		if velocity > 0: 
			$Animations.scale.x = 1
		else: 
			$Animations.scale.x = -1
		
		# randomly trip

			
	if passenger_state == PassengerState.WALK: 
		#$AnimatedSprite.play("walk")
		BodyUpper.play("walk")
		BodyLower.play("walk")
		var children = $Animations/BodyUpper/Accessories.get_children()
		for child in children:
			var grandchildren = child.get_children()
			for grandchild in grandchildren:
				grandchild.play("default")
		if position.x < target_x - seating_half_width:
			target_velocity = WALK_SPEED#  - train_acceleration
			$Animations.scale.x = 1
		elif position.x > target_x + seating_half_width:
			target_velocity = -WALK_SPEED#  + train_acceleration
			$Animations.scale.x = -1
		else: 
			if target.target_type == PassengerTarget.TargetType.SEAT:
				passenger_state = PassengerState.SIT
				position.x = target_x + 30
				#$AnimatedSprite.play("sit")
				sit_animations()
				reset_wait()
			else: 
				passenger_state = PassengerState.IDLE
				printerr("Unexpected target type: " + str(target.target_type) + " for NPC")
				position.x = target_x
				#$AnimatedSprite.play("idle")
				reset_wait()
				
	elif passenger_state == PassengerState.TRIP and abs(velocity) < TRIP_VELOCITY:
		emit_signal("stop_using_target", self)
	elif passenger_state in [PassengerState.SIT]: 
		if time_since_last_state_change >= time_til_next_state_change: 
			if passenger_state == PassengerState.SIT:
				time_since_last_state_change = 0
				stand_animations()
		else: 
			time_since_last_state_change += delta
			
	velocity_calculations(delta) 

func set_train_acceleration(new_train_acceleration): 
	train_acceleration = -3*new_train_acceleration

func velocity_calculations(delta): 
	if passenger_state in [PassengerState.SIT]:
		return
	velocity = clamp(velocity, -MAX_VELOCITY, MAX_VELOCITY)
	
	if passenger_state == PassengerState.TRIP: 
		if velocity > 0:
			velocity -= FRICTION * delta
		else:
			velocity += FRICTION * delta
	else: 
		if velocity > target_velocity:
			velocity -= FRICTION * delta
		else:
			velocity += FRICTION * delta
		
	invincibility_timer -= delta
	if invincibility_timer > 0:
		$Sprite2.visible = true
		is_invincible = true
	else:
		$Sprite2.visible = false
		is_invincible = false
	if position.x < 200 or position.x > 5000:
		velocity = -velocity
	
	if position.x < 200:
		velocity = abs(velocity) + abs(velocity)*2
		position.x = 250
	if position.x > 5000:
		velocity = -abs(velocity) - abs(velocity)*2
		position.x = 4950
	
	position.x += velocity * delta
	if abs(slide_velocity - train_acceleration) > 4: 
		slide_velocity += (train_acceleration - slide_velocity)*delta*slide_velocity_change_rate

	position.x += delta*slide_velocity*slide_velocity_mult
	
	
func reset_wait(): 
	time_til_next_state_change = rng.randf_range(min_time_for_state_change, max_time_for_state_change)
	time_since_last_state_change = 0

func impact(player_velocity):
	if is_invincible:
		return
	if passenger_state != PassengerState.WALK:
		return

	velocity += player_velocity
	invincibility_timer = INVINCIBILITY_TIME
	hit_sound()

func impact_enemy(enemy_velocity):
	if is_invincible:
		return
	if passenger_state != PassengerState.WALK:
		return

	velocity += enemy_velocity
	invincibility_timer = INVINCIBILITY_TIME
	hit_sound()

func hit_sound():
	var children = $Sound/Hit.get_children()
	var sound = children[randi() % children.size()]
	sound.play()

func _on_Area2D_area_entered(enemy_area):
	var enemy = enemy_area.get_parent()
	if enemy.get("is_npc") != null:
		if is_invincible:
			enemy.impact_enemy(velocity)

func invisibilize():
	var children = $Animations/BodyLower.get_children()
	for child in children:
		child.visible = false
	children = $Animations/BodyUpper/Jeans.get_children()
	for child in children:
		child.visible = false
	children = $Animations/BodyUpper/Chinos.get_children()
	for child in children:
		child.visible = false
	children = $Animations/BodyUpper/Accessories.get_children()
	for child in children:
		var grandchildren = child.get_children()
		for grandchild in grandchildren:
			grandchild.visible = false
	$Animations/Speech.visible = false
	

func generate_npc():
	if randi() % 2 == 0:
		BodyLower = $Animations/BodyLower/Jeans
		var children = $Animations/BodyUpper/Jeans.get_children()
		BodyUpper = children[randi() % children.size()]
	else:
		BodyLower = $Animations/BodyLower/Chinos
		var children = $Animations/BodyUpper/Chinos.get_children()
		BodyUpper = children[randi() % children.size()]
	Accessories = $Animations/BodyUpper/Accessories
	#eyes
	var children = $Animations/BodyUpper/Accessories/Eyes.get_children()
	children[randi() % children.size()].visible = true

	#eyewear
	children = $Animations/BodyUpper/Accessories/Eyewear.get_children()
	children[randi() % children.size()].visible = true

	#mouth
	children = $Animations/BodyUpper/Accessories/Mouth.get_children()
	children[randi() % children.size()].visible = true

	#nose
	children = $Animations/BodyUpper/Accessories/Nose.get_children()
	children[randi() % children.size()].visible = true

	children = $Animations/BodyUpper/Accessories.get_children()
	for child in children:
		var grandchildren = child.get_children()
		for grandchild in grandchildren:
			grandchild.play("default")

	BodyUpper.visible = true
	BodyLower.visible = true
	BodyUpper.playing = true
	BodyLower.playing = true
	BodyUpper.play("walk")
	BodyLower.play("walk")

func sit_animations():
	z_index = -1
	BodyLower.z_index = -1
	preseated_y =  position.y
	position.y = 555
	BodyUpper.play("sit")
	BodyLower.play("sit")
	var children = $Animations/BodyUpper/Accessories.get_children()
	var grandchildren
	for child in children:
		grandchildren = child.get_children()
		for grandchild in grandchildren:
			grandchild.play("sit")
	yield(BodyUpper, "animation_finished")
	BodyUpper.playing = false
	BodyLower.playing = false
	var framecount
	framecount = BodyUpper.frames.get_frame_count("sit")
	if framecount > 0:
		BodyUpper.set_frame(framecount - 1)
	framecount = BodyLower.frames.get_frame_count("sit")
	if framecount > 0:
		BodyLower.set_frame(framecount - 1)
	for child in children:
		grandchildren = child.get_children()
		for grandchild in grandchildren:
			grandchild.playing = false
			framecount = grandchild.frames.get_frame_count("sit")
			if framecount > 0:
				grandchild.set_frame(framecount - 1)
	$Animations/Speech.scale.x = (noise_level / MAX_NOISE_LEVEL ) * 2
	$Animations/Speech.scale.y = (noise_level / MAX_NOISE_LEVEL ) * 2
	#$Sound/Talk/AudioStreamPlayer2D.playing = true
	$Animations/Speech.visible = true

func stand_animations():
	print("STAND")
	BodyUpper.play("sit", true)
	BodyLower.play("sit", true)
	var children = $Animations/BodyUpper/Accessories.get_children()
	var grandchildren
	for child in children:
		grandchildren = child.get_children()
		for grandchild in grandchildren:
			grandchild.play("sit", true)
	noise_level = 0
	$Sound/Talk/AudioStreamPlayer2D.playing = false
	$Animations/Speech.visible = false
	$Animations/Speech.visible = false
	yield(BodyUpper, "animation_finished")
	$Animations/Speech.visible = false
	print("DONE")
	position.y = preseated_y
	z_index = 0
	BodyLower.z_index = 0
	emit_signal("stop_using_target", self)

func shush(): 
	noise_level = 0
	$Animations/Speech.scale.x = 0
	$Animations/Speech.scale.y = 0
	$Sound/Talk/AudioStreamPlayer2D.playing = false
	time_to_next_noise_change = rng.randf_range(MIN_TIME_BETWEEN_NOISE_CHANGES,MAX_TIME_BETWEEN_NOISE_CHANGES)
