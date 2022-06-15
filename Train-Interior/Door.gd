extends Node2D

var pos_diff = 0
var is_opening = false
const DOOR_SPEED_MULT = 50

func _ready():
	open()

func _process(delta):
	if Input.is_action_pressed("ui_down"):
		close()
	if Input.is_action_pressed("ui_up"):
		open()
	if is_opening and pos_diff < 160:
		pos_diff += delta * DOOR_SPEED_MULT
		$DoorL.position.x -= delta * DOOR_SPEED_MULT
		$DoorR.position.x += delta * DOOR_SPEED_MULT
		if pos_diff >= 160:
			$Sound.play()
	if not is_opening and pos_diff > 0:
		pos_diff -= delta * DOOR_SPEED_MULT
		$DoorL.position.x += delta * DOOR_SPEED_MULT
		$DoorR.position.x -= delta * DOOR_SPEED_MULT
		if pos_diff <= 0:
			$Sound.play()	

func open():
	is_opening = true
	$Sound.play()

func close():
	is_opening = false
	$Sound.play()
