extends ItemIcon
class_name WeaponIcon

@export var power: int
@export var item_model: PackedScene

func _ready() -> void:
	stat_label.text = "+" + str(power)
	item_label.text = item_model.resource_path.get_file().get_basename().capitalize()
