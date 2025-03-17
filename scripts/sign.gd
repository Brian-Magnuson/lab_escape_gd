extends Area2D

func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and Input.is_action_just_pressed("interact"):
			print("Sign checked")
