extends RayCast3D

func deal_damage():
	if not is_colliding():
		return
	var collider = get_collider()
	if collider is Enemy:
		collider.health_component.take_damage(15.0)
	print(collider)
	add_exception(collider)
