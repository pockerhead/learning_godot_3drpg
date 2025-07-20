extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const DECAY := 8.0

# Stores the x/y direction the player is trying to look in
var _look := Vector2.ZERO
# Stores the direction the player moves when attacking
var _attack_direction = Vector3.ZERO

@export var mouse_sensitivity: float = 0.00075
@export var min_boundary: float = -60
@export var max_boundary: float = 10
@export var animation_decay: float = 20.0
@export var attack_move_speed: float = 3.0
@export_category("RPG Stats")
@export var stats: CharacterStats

@onready var horizontal_pivot: Node3D = $HorizontalPivot
@onready var vertical_pivot: Node3D = $HorizontalPivot/VerticalPivot
@onready var rig_pivot: Node3D = $RigPivot
@onready var rig: Rig = $RigPivot/Rig
@onready var attack_cast: RayCast3D = %AttackCast
@onready var health_component: HealthComponent = $HealthComponent
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var area_attack: AreaAttack = $RigPivot/AreaAttack
@onready var user_interface: UserInterface = %UserInterface

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health_component.update_max_health(stats.get_max_hp())
	print(stats.get_base_speed())
	user_interface.update_stats_display()
	stats.level_up_notification.connect(
		func(): health_component.update_max_health(stats.get_max_hp())
	)
	stats.update_stats_notification.connect(
		func(): user_interface.update_stats_display()
	)

func _physics_process(delta: float) -> void:
	frame_camera_rotation()
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var local_speed = stats.get_base_speed()
	if Input.is_action_pressed("sprint"):
		local_speed *= 1.5
	var direction := get_movement_direction()
	rig.update_animation_tree(direction)
	# Не вызываем handle_idle_physics_frame во время дэша
	if not rig.is_dashing():
		handle_idle_physics_frame(delta, direction, local_speed)
	handle_slashing_physics_frame(delta)
	handle_overhead_physics_frame()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED && event is InputEventMouseMotion:
		_look = -event.relative * mouse_sensitivity
	
	if rig.is_idle():
		if event.is_action_pressed("click"):
			slash_attack()
		if event.is_action_pressed("right_click"):
			heavy_attack()

func get_movement_direction() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_vector :=  Vector3(input_dir.x, 0, input_dir.y).normalized()
	var direction := horizontal_pivot.global_transform.basis * input_vector
	return direction

func frame_camera_rotation() -> void:
	horizontal_pivot.rotate_y(_look.x)
	vertical_pivot.rotate_x(_look.y)
	
	vertical_pivot.rotation.x = clampf(vertical_pivot.rotation.x, deg_to_rad(min_boundary), deg_to_rad(max_boundary))
	$SpringArm3D.global_transform = vertical_pivot.global_transform
	_look = Vector2.ZERO

func look_toward_direction(direction: Vector3, delta: float) -> void: 
	var target_transform := rig_pivot.global_transform.looking_at(
		rig_pivot.global_position + direction, Vector3.UP, true
	)
	rig_pivot.global_transform = rig_pivot.global_transform.interpolate_with(
		target_transform,
		1.0 - exp(-animation_decay * delta)
	)
	
func slash_attack() -> void:
	rig.travel("Slash")
	_attack_direction = get_movement_direction()
	if _attack_direction.is_zero_approx():
		_attack_direction = rig.global_basis * Vector3.BACK
	attack_cast.clear_exceptions()
	
func heavy_attack() -> void:
	rig.travel("Overhead")
	_attack_direction = get_movement_direction()
	if _attack_direction.is_zero_approx():
		_attack_direction = rig.global_basis * Vector3.BACK
	attack_cast.clear_exceptions()
	
func handle_slashing_physics_frame(delta: float):
	if not rig.is_slashing():
		return
	velocity.x = _attack_direction.x * attack_move_speed
	velocity.z = _attack_direction.z * attack_move_speed
	look_toward_direction(_attack_direction, delta)
	attack_cast.deal_damage(10.0 + stats.get_damage_modifier(), stats.get_crit_chance())

func handle_idle_physics_frame(delta: float, direction: Vector3, local_speed: float):
	if not rig.is_idle():
		return
	velocity.x = exponential_decay(
		velocity.x, 
		direction.x * local_speed,
		DECAY,
		delta
	)
	velocity.z = exponential_decay(
		velocity.z, 
		direction.z * local_speed,
		DECAY,
		delta
	)
	if direction:
		look_toward_direction(direction, delta)
	return

func handle_overhead_physics_frame():
	if not rig.is_overhead():
		return
	velocity.x = 0
	velocity.z = 0

func _on_health_component_defeat() -> void:
	rig.travel("Defeat")
	collision_shape_3d.disabled = true
	set_physics_process(false)
	await get_tree().create_timer(0.3).timeout
	user_interface.play_dead_animation()


func _on_rig_heavy_attack() -> void:
	area_attack.deal_damage(10.0 + stats.get_damage_modifier(), stats.get_crit_chance())


func exponential_decay(a: float, b: float, decay: float, delta: float) -> float:
	return b + (b - a) * exp(-decay * delta)
	
