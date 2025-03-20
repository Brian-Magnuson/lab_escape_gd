extends Area2D

signal sign_read(dialogue_id: String)

@export var dialogue_id: String = "Default"

var player_in_range = false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		
func _input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		sign_read.emit(dialogue_id)
