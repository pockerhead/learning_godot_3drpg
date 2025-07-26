extends ItemIcon
class_name ShieldIcon

@export var power: int
@export var shield: shield_type

enum shield_type {
	SHORT_SHIELD,
	TALL_SHIELD
}

func _ready() -> void:
	stat_label.text = "+" + str(power)
	item_label.text = shield_type.keys()[shield]
	item_label.text = item_label.text.capitalize()
 
