extends CanvasLayer

@onready var fader: ColorRect = $Fader

func _ready() -> void:
	fader.color.a = 0

func fade_in():
	var tween = create_tween()
	tween.tween_interval(0.1)
	tween.tween_property(fader, "color:a", 0, 1).from(1)

func change_scene(next_level: String, player: Player):
	var tween = create_tween()
	print(player.user_interface.inventory.gold)
	tween.tween_property(fader, "color:a", 1, 1).from(0)
	tween.tween_interval(0.1)
	tween.tween_callback(
		func():
			PersistentData.cache_gear(player)
			PersistentData.cache_player_data(player)
			get_tree().change_scene_to_file(next_level)
	)
