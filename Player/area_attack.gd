extends ShapeCast3D
class_name AreaAttack

func deal_damage(damage: float):
	for collision_index in get_collision_count():
		var collider = get_collider(collision_index)
		if collider is Player or collider is Enemy:
			collider.health_component.take_damage(damage)
