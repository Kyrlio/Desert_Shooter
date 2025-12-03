class_name PlayerInputController
extends Node

## Gère toute la logique d'input pour un joueur
## Émet des signaux pour les actions et expose des propriétés pour le mouvement/visée

signal fire_requested()
signal reload_requested()
signal dash_requested()
signal block_started()
signal block_stopped()
signal weapon_cycled(direction: int)
signal skin_cycled(direction: int)

@export var input_prefix: String = "player0_"
@export var allow_mouse_aim: bool = true
@export var gamepad_aim_deadzone: float = 0.25

var movement_vector: Vector2 = Vector2.ZERO
var aim_vector: Vector2 = Vector2.RIGHT
var is_using_mouse_for_aim: bool = true
var last_gamepad_aim: Vector2 = Vector2.RIGHT

var _mouse_hidden: bool = false


func _ready() -> void:
	is_using_mouse_for_aim = allow_mouse_aim
	


func gather_input() -> void:
	_gather_movement()
	_gather_aim()
	_check_fire()
	_check_reloading()
	_check_dash()
	_check_block()
	_check_weapon_cycle()
	_check_skin_cycle()


func _gather_movement() -> void:
	movement_vector = Input.get_vector(
		input_prefix + "move_left",
		input_prefix + "move_right",
		input_prefix + "move_up",
		input_prefix + "move_down"
	)


func _gather_aim() -> void:
	var aim_direct := Input.get_vector(
		input_prefix + "weapon_aim_left",
		input_prefix + "weapon_aim_right",
		input_prefix + "weapon_aim_up",
		input_prefix + "weapon_aim_down"
	)
	
	if aim_direct.length_squared() >= gamepad_aim_deadzone * gamepad_aim_deadzone:
		last_gamepad_aim = aim_direct.normalized()
		if is_using_mouse_for_aim:
			is_using_mouse_for_aim = false
			_set_mouse_visibility(false)


func _check_fire() -> void:
	var attack_action := input_prefix + "attack"
	if InputMap.has_action(attack_action) and Input.is_action_pressed(attack_action):
		fire_requested.emit()


func _check_reloading():
	var reload_action := input_prefix + "reload"
	if InputMap.has_action(reload_action) and Input.is_action_just_pressed(reload_action):
		reload_requested.emit()


func _check_dash() -> void:
	var dash_action := input_prefix + "dash"
	if InputMap.has_action(dash_action) and Input.is_action_just_pressed(dash_action):
		dash_requested.emit()


func _check_block() -> void:
	var block_action := input_prefix + "block"
	if InputMap.has_action(block_action):
		if Input.is_action_pressed(block_action):
			block_started.emit()
		elif Input.is_action_just_released(block_action):
			block_stopped.emit()


func _check_weapon_cycle() -> void:
	var prev_action := input_prefix + "prev_weapon"
	var next_action := input_prefix + "next_weapon"
	
	if InputMap.has_action(prev_action) and Input.is_action_just_pressed(prev_action):
		weapon_cycled.emit(-1)
	if InputMap.has_action(next_action) and Input.is_action_just_pressed(next_action):
		weapon_cycled.emit(1)


func _check_skin_cycle() -> void:
	var skin_next_action := input_prefix + "skin_next"
	var skin_prev_action := input_prefix + "skin_prev"
	
	var skin_changed := false
	if InputMap.has_action(skin_next_action) and Input.is_action_just_pressed(skin_next_action):
		skin_cycled.emit(1)
		skin_changed = true
	if InputMap.has_action(skin_prev_action) and Input.is_action_just_pressed(skin_prev_action):
		skin_cycled.emit(-1)
		skin_changed = true
	
	# Debug keyboard shortcuts retained for player 0 only
	#if not skin_changed and input_prefix == "player0_":
		#if Input.is_action_just_pressed("player0_next_skin"):
			#skin_cycled.emit(1)
		#if Input.is_action_just_pressed("player0_prev_skin"):
			#skin_cycled.emit(-1)


func handle_input_event(event: InputEvent, aim_root: Node2D) -> void:
	if not allow_mouse_aim:
		return
		
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		is_using_mouse_for_aim = true
		_set_mouse_visibility(true)
		if event is InputEventMouseMotion and event.relative.length_squared() > 0.0:
			var mouse_position := aim_root.get_global_mouse_position()
			aim_vector = aim_root.global_position.direction_to(mouse_position)
	elif event is InputEventJoypadMotion:
		if event.axis in [JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y] and abs(event.axis_value) >= gamepad_aim_deadzone:
			is_using_mouse_for_aim = false
			_set_mouse_visibility(false)


func get_effective_aim(aim_root: Node2D) -> Vector2:
	var effective_aim := aim_vector
	if allow_mouse_aim and is_using_mouse_for_aim:
		var mouse_position := aim_root.get_global_mouse_position()
		effective_aim = aim_root.global_position.direction_to(mouse_position)
	else:
		if last_gamepad_aim.length_squared() >= 0.0001:
			effective_aim = last_gamepad_aim
	
	if effective_aim.length_squared() < 0.0001:
		effective_aim = Vector2.RIGHT
	
	return effective_aim.normalized()


func _set_mouse_visibility(should_be_visible: bool) -> void:
	if not allow_mouse_aim:
		return
	if should_be_visible and _mouse_hidden:
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Cursor.show_cursor(true)
		_mouse_hidden = false
	elif not should_be_visible and not _mouse_hidden:
		#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		Cursor.show_cursor(false)
		_mouse_hidden = true
