extends CanvasLayer

var score = 0.0

var dialogue_data: Dictionary
var current_dialogue: Dictionary
var current_dialogue_index = -1

var is_scrolling_text = false

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
	# If there is no current dialogue...
	if current_dialogue.is_empty():
		# Load the dialogue
		current_dialogue = find_dialogue_with_id(dialogue_id)
		if current_dialogue.is_empty():
			printerr("%s: Dialogue failed to load" % name)
			return
		current_dialogue_index = 0
		# Begin displaying the dialogue
		display_dialogue(current_dialogue["dialogue"][current_dialogue_index])
	# If the dialogue being displayed is still scrolling...
	elif is_scrolling_text:
		# Skip the scrolling and display it instantly
		display_dialogue(current_dialogue["dialogue"][current_dialogue_index], true)
	# If there is more dialogue...
	elif current_dialogue_index + 1 < current_dialogue["dialogue"].size():
		# Display the next piece of dialogue
		current_dialogue_index += 1
		display_dialogue(current_dialogue["dialogue"][current_dialogue_index])
	# If there is no more dialogue left...
	else:
		# Unload the dialogue
		current_dialogue_index = -1
		current_dialogue = {}
		$TextBox.visible = false
		
func display_dialogue(dialogue: Dictionary, instant: bool = false) -> void:
	# Display the dialogue box
	$TextBox.visible = true
	$TextBox/NameBox/Label.text = dialogue["name"]
	# If not instant...
	if not instant:
		# Start scrolling text
		is_scrolling_text = true
		# Keep scrolling text as long as the scrolling text timer is running
		$ScrollingTextTimer.start()
		for i in dialogue["text"].length():
			$TextBox/Label.text = dialogue["text"].left(i + 1)
			# If the scrolling text timer, for some reason, isn't running...
			if $ScrollingTextTimer.is_stopped():
				# End this loop
				break
			await $ScrollingTextTimer.timeout
		is_scrolling_text = false
	# If instant text...
	else:
		# Stop the scrolling text timer if it has started
		# This will break any scrolling loops that have started
		$ScrollingTextTimer.stop()
		# Display all the text at once
		$TextBox/Label.text = dialogue["text"]
		is_scrolling_text = false


func _on_sign_sign_stop_read() -> void:
	current_dialogue_index = -1
	current_dialogue = {}
	$TextBox.visible = false
	$ScrollingTextTimer.stop()
