extends StaticBody2D

@export var teleport_target: Node2D

var player_in_range = false
var player_body: PhysicsBody2D

func _on_teleport_region_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		player_body = body

func _on_teleport_region_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func _input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		player_body.global_position = teleport_target.global_position
