extends Node
class_name HealthComponent

signal defeat()
signal health_changed()

@export var body: PhysicsBody3D

var armor_value := 0.0

var max_health: float
var current_health: float:
	set(value):
		current_health = max(0.0, value)
		if current_health == 0.0:
			defeat.emit()
		health_changed.emit()

func update_max_health(max_hp_in: float):
	max_health = max_hp_in
	current_health = max_health
	
func take_damage(damage_in: float, is_crit: bool = false):
	var damage = damage_in
	var color = Color.WHITE
	if is_crit:
		damage *= 2.0
		color = Color.RED
	damage = damage * (1.0 - armor_value)
	current_health -= damage
	VfxManager.spawn_damage_number(damage, color, body.position)

func get_health_string() -> String:
	return "%s/%s" % [current_health, max_health]

func update_armor(armor_in: float):
	armor_value = armor_in / 100.0
