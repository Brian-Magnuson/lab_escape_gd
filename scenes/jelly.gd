extends Node2D

func hit() -> void:
	print("Enemy hurt!")
	$IFrameTimer.start()
	$Hurtbox/CollisionShape2D.disabled = true

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		hit()

func _on_i_frame_timer_timeout() -> void:
	$Hurtbox/CollisionShape2D.disabled = false
	for area in $Hurtbox.get_overlapping_areas():
		if area.is_in_group("player_hitbox"):
			hit()
