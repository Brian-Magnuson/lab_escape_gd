extends CharacterBody2D

## Emitted when the player's health updates, allowing other nodes, such as a
## health bar, to respond to the update.
signal health_updated(health: float, max_health: float)

## Emitted when the player needs to update the score by a certain amount.
signal score_updated(amount: float)

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

@export var health = 100.0
@export var max_health = 100.0
@export var damage = 10.0

func _ready() -> void:
	$Hitbox.set_meta("hit_damage", damage)
	$AnimatedSprite2D.play("idle")
	health = max_health
	health_updated.emit(health, max_health)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if Input.is_action_pressed("attack"):
		$Hitbox/CollisionShape2D.disabled = false
	else:
		$Hitbox/CollisionShape2D.disabled = true
	
	if direction < 0:
		$AnimatedSprite2D.flip_h = true
		$Hitbox.scale.x = -1
	elif direction > 0:
		$AnimatedSprite2D.flip_h = false
		$Hitbox.scale.x = 1
	
	# Handle animations
	if Input.is_action_pressed("attack"):
		$AnimatedSprite2D.play("attack")
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		$AnimatedSprite2D.play("jump")
	elif is_on_floor() and abs(direction) > 0:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")


	move_and_slide()
	
func hit(amount: float) -> void:
	health = clamp(health - amount, 0, max_health)
	health_updated.emit(health, max_health)
	$IFrameTimer.start()
	$Hurtbox/CollisionShape2D.disabled = true

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hitbox"):
		hit(area.get_meta("hit_damage") as float)
	if area.is_in_group("item_score"):
		area.queue_free()
		score_updated.emit(100)
	if area.is_in_group("item_heal"):
		area.queue_free()
		health = clamp(health + 50, 0, max_health)
		health_updated.emit(health, max_health)

func _on_i_frame_timer_timeout() -> void:
	$Hurtbox/CollisionShape2D.disabled = false
	for area in $Hurtbox.get_overlapping_areas():
		if area.is_in_group("enemy_hitbox"):
			hit(area.get_meta("hit_damage") as float)
