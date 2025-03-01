extends RigidBody2D

@export var damage = 10.0

func _ready() -> void:
	$Hitbox.set_meta("hit_damage", damage)

func _on_hitbox_body_shape_entered(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	queue_free()
