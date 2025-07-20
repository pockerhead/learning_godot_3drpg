extends Node3D
class_name DamageNumber

@onready var label_3d: Label3D = $Label3D

func setup(damage: int, color: Color, position: Vector3):
	if not is_inside_tree():
		await ready
	label_3d.text = str(damage)
	label_3d.modulate = color
	global_position = position
