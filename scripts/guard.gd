extends Path2D

## The guard's current health.
@export var health = 40.0
## The guard's maximum health.
@export var max_health = 40.0
## The amount of damage the guard deals to the player.
@export var damage = 10.0
## The guard's current movement speed.
@export var speed = 40.0
## Reference to the player node.
@export var player: Node2D
## The bullet that the guard shoots.
@export var bullet: PackedScene
## The full speed of the bullets that the guard shoots.
@export var bullet_speed = 50

func _ready() -> void:
	$PathFollow2D/Hitbox.set_meta("hit_damage", damage)
	$PathFollow2D/AnimatedSprite2D.play("walking")
	health = max_health
	update_health_bar()

func _physics_process(delta: float) -> void:
	# Move the guard along the path.
	$PathFollow2D.progress += speed * delta
	# If the guard is moving, guard faces direction of movement.
	if speed != 0:
		if $PathFollow2D.progress_ratio >= 0.5:
			$PathFollow2D/AnimatedSprite2D.flip_h = true
		else:
			$PathFollow2D/AnimatedSprite2D.flip_h = false
	# If the guard is shooting, guard faces player.
	else:
		var v = player.global_position - $PathFollow2D.global_position;
		if v.x < 0:
			$PathFollow2D/AnimatedSprite2D.flip_h = true
		else:
			$PathFollow2D/AnimatedSprite2D.flip_h = false

## Called when the guard takes damage.
func hit(amount: float) -> void:
	health = clamp(health - amount, 0, max_health)
	update_health_bar()
	$PathFollow2D/IFrameTimer.start()
	$PathFollow2D/Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	
	if health == 0.0:
		queue_free()

## Shoot a bullet at the player.
func shoot_bullet() -> void:
	var bullet_inst = bullet.instantiate() as RigidBody2D
	# The guard's position.
	var v1 = $PathFollow2D.global_position
	# The player's position.
	var v2 = player.global_position
	bullet_inst.position = v1 - 20 * (v1 - v2).normalized()
	bullet_inst.linear_velocity = bullet_speed * (v2 - v1).normalized()
	get_tree().root.add_child(bullet_inst)

## Updates the guard's health bar.
func update_health_bar() -> void:
	$PathFollow2D/HealthBarAnchor/HealthBar.value = health / max_health
	if health < max_health:
		$PathFollow2D/HealthBarAnchor/HealthBar.visible = true
	else:
		$PathFollow2D/HealthBarAnchor/HealthBar.visible = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Make the guard take damage if hit by the player's hitbox.
	if area.is_in_group("player_hitbox"):
		hit(area.get_meta("hit_damage") as float)

func _on_i_frame_timer_timeout() -> void:
	# Give the guard invincibility frames, then re-enable the hurtbox.
	$PathFollow2D/Hurtbox/CollisionShape2D.set_deferred("disabled", false)
	# If the guard is still colliding with the player, take damage.
	for area in $PathFollow2D/Hurtbox.get_overlapping_areas():
		if area.is_in_group("player_hitbox"):
			hit(area.get_meta("hit_damage") as float)

func _on_detection_zone_body_entered(body: Node2D) -> void:
	# If the player enters the detection zone, stop moving and shoot.
	if body.is_in_group("player"):
		speed = 0
		$PathFollow2D/AnimatedSprite2D.play("shooting")
		shoot_bullet()
		$PathFollow2D/ShootTimer.start()
		
func _on_detection_zone_body_exited(body: Node2D) -> void:
	# If the player exits the detection zone, resume moving.
	if body.is_in_group("player"):
		speed = 40.0
		$PathFollow2D/AnimatedSprite2D.play("walking")
		$PathFollow2D/ShootTimer.stop()

func _on_shoot_timer_timeout() -> void:
	shoot_bullet()
