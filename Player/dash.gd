extends Node3D

@export var player: Player
@export var speed_multiplier := 3.0

@onready var timer: Timer = $Timer
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

var direction: Vector3 = Vector3.ZERO
var dash_duration := 0.1
var time_remaining := 0.0

func _ready() -> void:
	gpu_particles_3d.emitting = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_gain_xp"):
		player.stats.xp += 10000
		
	if not player.is_physics_processing():
		return
	if not timer.is_stopped():
		return
	if event.is_action_pressed("dash") == false:
		return
	direction = player.get_movement_direction()
	if direction.is_zero_approx():
		return
	
	gpu_particles_3d.emitting = true
	player.rig.travel("Dash")
	timer.start(player.stats.get_dash_cooldown())
	time_remaining = dash_duration

func _physics_process(delta: float) -> void:
	if direction.is_zero_approx():
		return
	
	player.velocity = direction * player.stats.get_base_speed() * speed_multiplier
	time_remaining -= delta
	if time_remaining > 0:
		return
	gpu_particles_3d.emitting = false
	direction = Vector3.ZERO
