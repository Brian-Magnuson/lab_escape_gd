extends Node2D

@export var health = 30
@export var damage = 10

func _ready() -> void:
	$Hitbox.set_meta("hit_damage", damage)

func hit(amount: int) -> void:
	print("Enemy took ", amount, " damage!")
	$IFrameTimer.start()
	$Hurtbox/CollisionShape2D.disabled = true

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		hit(area.get_meta("hit_damage") as int)

func _on_i_frame_timer_timeout() -> void:
	$Hurtbox/CollisionShape2D.disabled = false
	for area in $Hurtbox.get_overlapping_areas():
		if area.is_in_group("player_hitbox"):
			hit(area.get_meta("hit_damage") as int)
