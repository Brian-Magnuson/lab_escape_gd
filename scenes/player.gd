extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -400.0


func _ready() -> void:
	$AnimatedSprite2D.play("idle")

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
	
func hit() -> void:
	$IFrameTimer.start()
	print("Player hurt!")
	$Hurtbox/CollisionShape2D.disabled = true

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hitbox"):
		hit()

func _on_i_frame_timer_timeout() -> void:
	$Hurtbox/CollisionShape2D.disabled = false
	for area in $Hurtbox.get_overlapping_areas():
		if area.is_in_group("enemy_hitbox"):
			hit()
