extends Node2D

## The enemy's current health.
@export var health = 30.0
## The enemy's max health.
@export var max_health = 30.0
## The damage dealt by the enemy.
@export var damage = 10.0
## The enemy's current movement speed.
@export var speed = 40.0

func _ready() -> void:
	$PathFollow2D/Hitbox.set_meta("hit_damage", damage)
	$PathFollow2D/AnimatedSprite2D.play("default")
		
	health = max_health
	update_health_bar()

func _physics_process(delta: float) -> void:
	$PathFollow2D.progress += speed * delta
	if $PathFollow2D.progress_ratio >= 0.5:
		$PathFollow2D/AnimatedSprite2D.flip_h = true
	else:
		$PathFollow2D/AnimatedSprite2D.flip_h = false

func hit(amount: float) -> void:
	health = clamp(health - amount, 0, max_health)
	update_health_bar()
	$PathFollow2D/IFrameTimer.start()
	$PathFollow2D/Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	
	if health == 0.0:
		queue_free()
	
func update_health_bar() -> void:
	$PathFollow2D/HealthBarAnchor/HealthBar.value = health / max_health
	if health < max_health:
		$PathFollow2D/HealthBarAnchor/HealthBar.visible = true
	else:
		$PathFollow2D/HealthBarAnchor/HealthBar.visible = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		hit(area.get_meta("hit_damage") as float)

func _on_i_frame_timer_timeout() -> void:
	$PathFollow2D/Hurtbox/CollisionShape2D.disabled = false
	for area in $PathFollow2D/Hurtbox.get_overlapping_areas():
		if area.is_in_group("player_hitbox"):
			hit(area.get_meta("hit_damage") as float)
