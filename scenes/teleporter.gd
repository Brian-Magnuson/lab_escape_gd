extends StaticBody2D

@export var teleport_target: Node2D;

func _physics_process(_delta: float) -> void:
	for body in $TeleportRegion.get_overlapping_bodies():
		if body.is_in_group("player") and Input.is_action_just_pressed("interact"):
			body.position = teleport_target.position
