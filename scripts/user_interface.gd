extends CanvasLayer

var score = 0.0

var dialogue_data: Dictionary
var current_dialogue: Dictionary
var current_dialogue_index = -1

func _ready() -> void:
	$BlackScreen/AnimationPlayer.play("fade_in")
	var dialogue_json_text = FileAccess.get_file_as_string("res://data/dialogue.json")
	dialogue_data = JSON.parse_string(dialogue_json_text)

func _on_player_health_updated(health: float, max_health: float) -> void:
	$HealthBar.value = health / max_health
	$HealthBar/Label.text = "%0.0f / %0.0f" % [health, max_health]

func _on_player_score_updated(amount: float) -> void:
	score += amount
	$ScoreLabel.text = "%0.0f" % score

func _on_player_player_died() -> void:
	await get_tree().create_timer(2.0).timeout
	$BlackScreen/AnimationPlayer.play("fade_out")

func find_dialogue_with_id(dialogue_id: String) -> Dictionary:
	for obj in dialogue_data["dialogues"]:
		if obj["id"] == dialogue_id:
			return obj
	return {}

func _on_sign_sign_read(dialogue_id: String) -> void:
	if current_dialogue.is_empty():
		current_dialogue = find_dialogue_with_id(dialogue_id)
		if current_dialogue.is_empty():
			printerr("%s: Dialogue failed to load" % name)
			return
		current_dialogue_index = 0
		$TextBox.visible = true
		$TextBox/Label.text = current_dialogue["dialogue"][current_dialogue_index]["text"]
	elif current_dialogue_index + 1 < current_dialogue["dialogue"].size():
		current_dialogue_index += 1
		$TextBox/Label.text = current_dialogue["dialogue"][current_dialogue_index]["text"]
	else:
		current_dialogue_index = -1
		current_dialogue = {}
		$TextBox.visible = false
		
