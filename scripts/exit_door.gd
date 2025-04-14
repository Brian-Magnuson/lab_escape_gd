extends Area2D

@export var next_scene: PackedScene

var player_in_range = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		get_tree().change_scene_to_packed(next_scene)
