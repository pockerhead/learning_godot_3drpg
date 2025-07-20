extends Node3D

const DAMAGE_NUMBER: PackedScene = preload("res://Player/damage_number.tscn")

func spawn_damage_number(damage: int, color: Color, position: Vector3):
	var damage_number = DAMAGE_NUMBER.instantiate() as DamageNumber
	damage_number.setup(damage, color, position)
	add_child(damage_number)
