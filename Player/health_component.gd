extends Node
class_name HealthComponent

signal defeat()
signal health_changed()

var max_health: float
var current_health: float:
	set(value):
		current_health = max(0.0, value)
		if current_health == 0.0:
			defeat.emit()
		health_changed.emit()
		print(max_health)

func update_max_health(max_hp_in: float):
	max_health = max_hp_in
	current_health = max_health
	
func take_damage(damage_in: float):
	current_health -= damage_in
