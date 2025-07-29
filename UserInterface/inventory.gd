extends Control
class_name Inventory

const MIN_ARMOR_RATING := 0.0
const MAX_ARMOR_RATING := 80.0

signal armor_changed(protection: float)

@onready var level_label: Label = %LevelLabel
@onready var strength_value: Label = %StrengthValue
@onready var agility_value: Label = %AgilityValue
@onready var endurance_value: Label = %EnduranceValue
@onready var speed_value: Label = %SpeedValue
@onready var attack_value: Label = %AttackValue
@onready var item_grid: GridContainer = %ItemGrid
@onready var gold_label: Label = %GoldLabel
@onready var armor_value: Label = %ArmorValue

@onready var weapon_slot: CenterContainer = %WeaponSlot
@onready var armor_slot: CenterContainer = %ArmorSlot
@onready var shield_slot: CenterContainer = %ShieldSlot


@onready var player: Player = get_parent().player

@onready var gold: int = 0:
	set(value):
		gold_label.text = str(value) + "g"
		gold = value

func update_stats():
	strength_value.text = str(player.stats.strength.ability_score)
	agility_value.text = str(player.stats.agility.ability_score)
	endurance_value.text = str(player.stats.endurance.ability_score)
	speed_value.text = str(player.stats.speed.ability_score)
	level_label.text = "Level %s" % player.stats.level

func update_gear_stats():
	attack_value.text = str(get_weapon_value())
	armor_value.text = str(get_armor_value())
	armor_changed.emit(get_armor_value())

func _ready():
	update_stats()
	load_items_from_persistent_data()

func get_weapon_value() -> int:
	var damage = 0
	if get_weapon():
		damage += get_weapon().power
	else:
		damage += 1
	damage += player.stats.get_damage_modifier()
	return int(damage)

func get_armor_value() -> float:
	var armor = 0
	if get_armor():
		armor += get_armor().protection
	if get_shield():
		armor += get_shield().protection
	return clampf(armor, MIN_ARMOR_RATING, MAX_ARMOR_RATING)

func _on_back_button_pressed() -> void:
	get_parent().close_inventory()

func add_item(item: ItemIcon):
	for connection in item.interact.get_connections():
		item.interact.disconnect(connection.callable)
	item.get_parent().remove_child(item)
	item_grid.add_child(item)
	item.visible = true
	item.interact.connect(interact)

func add_currency(currency_in: int):
	gold += currency_in

func equip_item(item: ItemIcon, item_slot: CenterContainer):
	for child in item_slot.get_children():
		add_item(child)
	item.get_parent().remove_child(item)
	item_slot.add_child(item)

func interact(item: ItemIcon):
	if item is WeaponIcon:
		equip_item(item, weapon_slot)
		get_tree().call_group("PlayerRig", "replace_weapon", item.item_model)
	elif item is ArmorIcon:
		equip_item(item, armor_slot)
		get_tree().call_group("PlayerRig", "replace_armor", item.armor)
	elif item is ShieldIcon:
		equip_item(item, shield_slot)
		get_tree().call_group("PlayerRig", "replace_shield", item.item_model)
	update_gear_stats()

func get_weapon() -> WeaponIcon:
	for child in weapon_slot.get_children():
		if child is WeaponIcon:
			return child
	return null

func get_armor() -> ArmorIcon:
	for child in armor_slot.get_children():
		if child is ArmorIcon:
			return child
	return null

func get_shield() -> ShieldIcon:
	for child in shield_slot.get_children():
		if child is ShieldIcon:
			return child
	return null

func load_items_from_persistent_data():
	for item in PersistentData.get_inventory():
		add_item(item)
	for item in PersistentData.get_equipped_items():
		add_item(item)
		interact(item)
	gold = PersistentData.gold
