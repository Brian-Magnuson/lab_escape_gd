extends CanvasLayer

var score = 0.0

func _ready() -> void:
	$BlackScreen/AnimationPlayer.play("fade_in")

func _on_player_health_updated(health: float, max_health: float) -> void:
	$HealthBar.value = health / max_health
	$HealthBar/Label.text = "%0.0f / %0.0f" % [health, max_health]

func _on_player_score_updated(amount: float) -> void:
	score += amount
	$ScoreLabel.text = "%0.0f" % score

func _on_player_player_died() -> void:
	await get_tree().create_timer(2.0).timeout
	$BlackScreen/AnimationPlayer.play("fade_out")
