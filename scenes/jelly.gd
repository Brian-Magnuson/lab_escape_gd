extends Node2D

@export var health = 30.0
@export var max_health = 30.0
@export var damage = 10.0

func _ready() -> void:
	$Hitbox.set_meta("hit_damage", damage)
	health = max_health
	update_health_bar()

func hit(amount: float) -> void:
	print("Enemy took ", amount, " damage!")
	health = clamp(health - amount, 0, max_health)
	update_health_bar()
	$IFrameTimer.start()
	$Hurtbox/CollisionShape2D.disabled = true
	
	if health == 0.0:
		queue_free()
	
func update_health_bar() -> void:
	$HealthBar.value = health / max_health
	if health < max_health:
		$HealthBar.visible = true
	else:
		$HealthBar.visible = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		hit(area.get_meta("hit_damage") as float)

func _on_i_frame_timer_timeout() -> void:
	$Hurtbox/CollisionShape2D.disabled = false
	for area in $Hurtbox.get_overlapping_areas():
		if area.is_in_group("player_hitbox"):
			hit(area.get_meta("hit_damage") as float)
