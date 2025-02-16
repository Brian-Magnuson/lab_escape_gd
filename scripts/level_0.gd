extends Node

func _on_player_health_updated(health: float, max_health: float) -> void:
	$CanvasLayer/HealthBar.value = health / max_health
	$CanvasLayer/HealthBar/Label.text = "%0.0f / %0.0f" % [health, max_health]
