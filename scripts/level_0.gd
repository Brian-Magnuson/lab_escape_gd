extends Node

var score = 0.0

func _ready() -> void:
	$CanvasLayer/ColorRect.visible = true

func _on_player_health_updated(health: float, max_health: float) -> void:
	$CanvasLayer/HealthBar.value = health / max_health
	$CanvasLayer/HealthBar/Label.text = "%0.0f / %0.0f" % [health, max_health]

func _on_player_score_updated(amount: float) -> void:
	score += amount
	$CanvasLayer/ScoreLabel.text = "%0.0f" % score

func _on_player_player_died() -> void:
	await get_tree().create_timer(4.0).timeout
	$CanvasLayer/ColorRect/AnimationPlayer.play("fade_out")
