extends Path2D

@export var health = 40.0
@export var max_health = 40.0
@export var damage = 10.0

@export var speed = 40.0

@export var player: Node2D
@export var bullet: PackedScene

func _ready() -> void:
	$PathFollow2D/Hitbox.set_meta("hit_damage", damage)
	$PathFollow2D/AnimatedSprite2D.play("walking")
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
	$PathFollow2D/Hurtbox/CollisionShape2D.disabled = true
	
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


func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		speed = 0
		$PathFollow2D/AnimatedSprite2D.play("shooting")
		var bullet_inst = bullet.instantiate() as Node2D
		var v1 = $PathFollow2D.global_position
		var v2 = player.global_position
		bullet_inst.position = v1 - 20 * (v1 - v2).normalized()
		get_tree().root.add_child(bullet_inst)
		
func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		speed = 40.0
		$PathFollow2D/AnimatedSprite2D.play("walking")
