class_name Spring extends Node2D

var center: Vector2
var angle: float
var base_radius: float
var index: int

var velocity: Vector2
var stiffness: float = 8.0
var damping: float = 4.0

var noise_speed: float = 0.5
var noise_strength: float = 2.0

var noise: Noise = FastNoiseLite.new()

func initialize(start_pos: Vector2, i: int, c: Vector2) -> void:
	position = start_pos
	index = i
	center = c

	base_radius = start_pos.distance_to(c)
	angle = (start_pos - c).angle()

	noise.seed = randi()
	noise.frequency = 0.5

func _physics_process(delta: float) -> void:
	var n: float = noise.get_noise_2d(index * 10.0, Time.get_ticks_msec() * 0.001 * noise_speed)
	var target_radius: float = base_radius + n * noise_strength
	
	var target_pos: Vector2 = center + Vector2(target_radius, 0).rotated(angle)

	var accel: Vector2 = (target_pos - position) * stiffness - velocity * damping
	velocity += accel * delta
	position += velocity * delta
