extends Control

@onready var inventory_nodes: Control = $InventoryNodes
@onready var weapon_node: Control = $WeaponNode
@onready var armor_node: Control = $ArmorNode
@onready var shield_node: Control = $ShieldNode
var gold := 0
var current_health: int

func cache_gear(player: Player):
	var inventory = player.user_interface.inventory
	for item in inventory.item_grid.get_children():
		if item is ItemIcon:
			cache_item(item, inventory_nodes)

	cache_item(
		inventory.get_weapon(),
		weapon_node
	)
	cache_item(
		inventory.get_armor(),
		armor_node
	)
	cache_item(
		inventory.get_shield(),
		shield_node
	)
	self.gold = inventory.gold

func cache_player_data(player: Player):
	self.current_health = player.health_component.current_health

func get_equipped_items() -> Array:
	var equipped_items := []
	if weapon_node.get_child_count() > 0:
		equipped_items.append(weapon_node.get_child(0))
	if armor_node.get_child_count() > 0:
		equipped_items.append(armor_node.get_child(0))
	if shield_node.get_child_count() > 0:
		equipped_items.append(shield_node.get_child(0))
	return equipped_items

func get_inventory() -> Array:
	return inventory_nodes.get_children()

func cache_item(item: ItemIcon, storage_node: Control):
	item.get_parent().remove_child(item)
	storage_node.add_child(item)
