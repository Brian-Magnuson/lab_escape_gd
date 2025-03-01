extends RigidBody2D

@export var damage = 10.0

func _ready() -> void:
	$Hitbox.set_meta("hit_damage", damage)

func _on_hitbox_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	queue_free()
