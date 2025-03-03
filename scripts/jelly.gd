extends Node2D

## The enemy's current health.
@export var health = 30.0
## The enemy's max health.
@export var max_health = 30.0
## The damage dealt by the enemy.
@export var damage = 10.0

func _ready() -> void:
	# Assign the damage to the hitbox's metadata.
	$Hitbox.set_meta("hit_damage", damage)
	$AnimatedSprite2D.play("default")
		
	health = max_health
	update_health_bar()

## Called when the enemy takes damage.
func hit(amount: float) -> void:
	health = clamp(health - amount, 0, max_health)
	update_health_bar()
	$IFrameTimer.start()
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	
	if health == 0.0:
		queue_free()

## Updates the enemy's health bar.
func update_health_bar() -> void:
	$HealthBarAnchor/HealthBar.value = health / max_health
	if health < max_health:
		$HealthBarAnchor/HealthBar.visible = true
	else:
		$HealthBarAnchor/HealthBar.visible = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	# When the player hits this enemy, take damage.
	if area.is_in_group("player_hitbox"):
		hit(area.get_meta("hit_damage") as float)

func _on_i_frame_timer_timeout() -> void:
	# Give the enemy invincibility frames, then reenable the hurtbox.
	$Hurtbox/CollisionShape2D.disabled = false
	# If the guard is still colliding with the player, take damage.
	for area in $Hurtbox.get_overlapping_areas():
		if area.is_in_group("player_hitbox"):
			hit(area.get_meta("hit_damage") as float)
