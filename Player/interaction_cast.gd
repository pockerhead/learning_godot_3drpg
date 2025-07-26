extends ShapeCast3D

@export var ui: UserInterface

func check_interactions() -> void:
	for collision in get_collision_count():
		var collider = get_collider(collision)
		if collider is LootContainer:
			ui.update_interact_text("Oepn Chest")
			if Input.is_action_just_pressed("interact"):
				print(collider.get_items())
