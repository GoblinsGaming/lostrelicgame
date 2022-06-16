extends Node2D

var noise_level = 0
const min_noise_increase_rate = 5
const max_noise_increase_rate = 20
#const min_noise_decrease_rate = 20
#const max_noise_decrease_rate = 30
const MAX_NOISE_LEVEL = 50
const MIN_TIME_BETWEEN_NOISE_CHANGES = 1
const MAX_TIME_BETWEEN_NOISE_CHANGES = 10
var rng = RandomNumberGenerator.new()

var time_to_next_noise_change = 0

func _ready():
	rng.randomize()
	time_to_next_noise_change = rng.randf_range(MIN_TIME_BETWEEN_NOISE_CHANGES,MAX_TIME_BETWEEN_NOISE_CHANGES)

func _process(delta):
	if time_to_next_noise_change > 0:
		time_to_next_noise_change -= delta
	else: 
		if noise_level < MAX_NOISE_LEVEL:
			noise_level += rng.randf_range(min_noise_increase_rate, max_noise_increase_rate)
		noise_level = clamp(noise_level, 0, MAX_NOISE_LEVEL)
		$NoiseLevel.text = str(floor(noise_level))
		time_to_next_noise_change = rng.randf_range(MIN_TIME_BETWEEN_NOISE_CHANGES,MAX_TIME_BETWEEN_NOISE_CHANGES)
