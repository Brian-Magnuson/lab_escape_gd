extends Node2D

@export var amplitude: float = 1
@export var frequency: float = 1

var initial_pos: Vector2

func _ready() -> void:
	initial_pos = position

func _physics_process(_delta: float) -> void:
	position.y = initial_pos.y + sin(Time.get_ticks_msec() / 1000.0 * TAU * frequency) * amplitude
