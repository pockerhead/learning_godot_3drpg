extends Control
class_name UserInterface

@onready var level_label: Label = %LevelLabel
@export var player: Player
@onready var health_bar: TextureProgressBar = %HealthBar
@onready var xp_bar: TextureProgressBar = %XPBar
@onready var health_label: Label = %HPLabel
@onready var deadPlayer: AnimationPlayer = %DeadPlayer
@onready var deadBackground: ColorRect = %DeadRect
@onready var inventory: Inventory = $Inventory

func _ready():
	deadBackground.visible = false
	deadBackground.modulate.a = 0.0

func update_stats_display():
	level_label.text = str(player.stats.level)
	xp_bar.max_value = player.stats.percentage_level_up_boundary()
	xp_bar.value = player.stats.xp
	inventory.update_stats()

func update_health_display():
	health_bar.max_value = player.health_component.max_health
	health_bar.value = player.health_component.current_health
	health_label.text = player.health_component.get_health_string()

func play_dead_animation():
	deadBackground.visible = true
	deadPlayer.play("died")

func open_inventory():
	inventory.visible = true
	inventory.update_gear_stats()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_inventory():
	inventory.visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_menu"):
		if inventory.visible:
			close_inventory()
		else:
			open_inventory()
