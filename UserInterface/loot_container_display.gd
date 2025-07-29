extends CenterContainer
class_name LootContainerBox

@onready var grid_container: GridContainer = $PanelContainer/VBoxContainer/GridContainer
@onready var title: Label = $PanelContainer/VBoxContainer/TitleTexture/Title

@export var inventory: Inventory

var current_container: LootContainer

func _ready() -> void:
	visible = false

func close():
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if not is_instance_valid(current_container):
		return
	for child in grid_container.get_children():
		grid_container.remove_child(child)
		child.visible = false
		current_container.add_child(child)
		child.interact.disconnect(pick_up_item)

func open(loot: LootContainer):
	if visible:
		close()
	else:
		current_container = loot
		title.text = loot.name.capitalize()
		for item in loot.get_items():
			current_container.remove_child(item)
			grid_container.add_child(item)
			item.visible = true
			item.interact.connect(pick_up_item)
		visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func pick_up_item(item: ItemIcon):
	item.interact.disconnect(pick_up_item)
	if item is CurrencyIcon:
		inventory.add_currency(item.value)
		item.queue_free()
	else:
		inventory.add_item(item)
