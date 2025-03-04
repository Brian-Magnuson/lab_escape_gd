extends CharacterBody2D

## Emitted when the player's health updates, allowing other nodes, such as a
## health bar, to respond to the update.
signal health_updated(health: float, max_health: float)

## Emitted when the player needs to update the score by a certain amount.
signal score_updated(amount: float)

## The player's movement speed.
const SPEED = 150.0
## The player's jump velocity. Negative due to y-down coordinate system.
const JUMP_VELOCITY = -400.0

## The player's current health.
@export var health = 100.0
## The player's current maximum health.
@export var max_health = 100.0
## The amount of damage the player deals.
@export var damage = 10.0

## Whether the player has died.
var can_move = true
var can_jump = true
var can_attack = true
var can_animate = true

func _ready() -> void:
	# Set the hitbox's damage value and start the idle animation.
	$Hitbox.set_meta("hit_damage", damage)
	$AnimatedSprite2D.play("idle")
	health = max_health
	health_updated.emit(health, max_health)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if can_move and can_jump:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if can_move:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Handle attack.
	if can_attack:
		if Input.is_action_pressed("attack"):
			$Hitbox/CollisionShape2D.set_deferred("disabled", false)
		else:
			$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	
	# Sprite normally faces right; flip if moving left.
	if can_move:
		if direction < 0:
			$AnimatedSprite2D.flip_h = true
			$Hitbox.scale.x = -1
		elif direction > 0:
			$AnimatedSprite2D.flip_h = false
			$Hitbox.scale.x = 1
	
	# Handle animations
	if can_animate:
		if Input.is_action_pressed("attack"):
			$AnimatedSprite2D.play("attack")
		elif Input.is_action_just_pressed("jump") and is_on_floor():
			$AnimatedSprite2D.play("jump")
		elif is_on_floor() and abs(direction) > 0:
			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("idle")

	# Move the player.
	move_and_slide()

## Make the player take damage and emit the health_updated signal.
func hit(amount: float) -> void:
	health = clamp(health - amount, 0, max_health)
	health_updated.emit(health, max_health)
	if health == 0.0:
		death()
	else:
		$IFrameTimer.start()
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)

## Called when the player dies.
func death() -> void:
	$AnimatedSprite2D.play("death")
	can_move = false
	can_jump = false
	can_attack = false
	can_animate = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	# If the player is hit by an enemy, take damage.
	if area.is_in_group("enemy_hitbox"):
		hit(area.get_meta("hit_damage") as float)
	# If the player collides with an item, update the score or health.
	if area.is_in_group("item_score"):
		area.queue_free()
		score_updated.emit(100)
	# If the player collides with a health item, heal the player.
	elif area.is_in_group("item_heal"):
		area.queue_free()
		health = clamp(health + 50, 0, max_health)
		health_updated.emit(health, max_health)
	# If the player collides with an upgrade item, increase the player's health.
	elif area.is_in_group("item_upgrade"):
		area.queue_free()
		max_health += 20;
		health += 20;
		health_updated.emit(health, max_health)

func _on_i_frame_timer_timeout() -> void:
	# Give the player invincibility frames, then re-enable the hurtbox.
	$Hurtbox/CollisionShape2D.set_deferred("disabled", false)
	# If the player is still colliding with an enemy, take damage.
	for area in $Hurtbox.get_overlapping_areas():
		if area.is_in_group("enemy_hitbox"):
			hit(area.get_meta("hit_damage") as float)
