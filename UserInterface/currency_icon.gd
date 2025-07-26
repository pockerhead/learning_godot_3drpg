extends ItemIcon
class_name CurrencyIcon

@export var value: int

func _ready() -> void:
	item_label.text = "Gold"
	stat_label.text = "+" + str(value)
