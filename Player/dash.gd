extends Node3D

@export var player: Player
@export var speed_multiplier := 3.0

@onready var timer: Timer = $Timer

var direction: Vector3 = Vector3.ZERO
var dash_duration := 0.1
var time_remaining := 0.0

func _unhandled_input(event: InputEvent) -> void:
	if not timer.is_stopped():
		return
	if event.is_action_pressed("dash") == false:
		return
	direction = player.get_movement_direction()
	if direction.is_zero_approx():
		return
		
	player.rig.travel("Dash")
	timer.start(1)
	time_remaining = dash_duration

func _physics_process(delta: float) -> void:
	if direction.is_zero_approx():
		return
	player.velocity = direction * player.SPEED * speed_multiplier
	time_remaining -= delta
	if time_remaining <= 0:
		direction = Vector3.ZERO
