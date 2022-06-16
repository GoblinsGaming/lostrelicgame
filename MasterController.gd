extends Node2D

const menu = "res://Menu.tscn"
const game = "res://Main.tscn"
var current_level = null

# Called when the node enters the scene tree for the first time.
func _ready():
	current_level = load(menu).instance()
	current_level.connect("start_game", self, "start_game")
	add_child(current_level)
	
func start_game(): 
	var next_level = load(game).instance()
	current_level.queue_free()
	current_level = next_level
	add_child(current_level)
