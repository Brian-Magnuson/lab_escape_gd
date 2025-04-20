extends Area2D

@export var amplitude: float = 1
@export var frequency: float = 1
var initial_pos: Vector2

func _ready() -> void:
	initial_pos = position

func _physics_process(_delta: float) -> void:
	position.y = initial_pos.y + sin(Time.get_ticks_msec() / 1000.0 * TAU * frequency) * amplitude

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set_meta("in_water", true)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set_meta("in_water", false)
