@icon("res://assets/icons/icon_map.png")
extends Node2D

const PLAYER_SCENE: PackedScene = preload("res://scenes/entities/player/player.tscn")

@onready var fps_label: Label = $CanvasLayer/Container/HBoxContainer/FpsLabel
@onready var state_label: Label = $CanvasLayer/Container/HBoxContainer/StateLabel
@onready var base_player: Player = $Player

var players: Array[Player] = []
var device_to_player: Dictionary = {}
var base_player_device_id: int = -1


func _ready() -> void:
	players.append(base_player)
	base_player.player_index = 0
	_strip_gamepad_events_for_prefix(GameConfig.get_player_prefix(0))
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	for device_id in Input.get_connected_joypads():
		_register_device(device_id)


func _physics_process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	var state_chunks: Array[String] = []
	for p in players:
		if not is_instance_valid(p):
			continue
		state_chunks.append("P%d:%s" % [p.player_index, str(p.get_current_state())])
	state_label.text = "States: " + ", ".join(state_chunks)


func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
	if connected:
		_register_device(device_id)
	else:
		_unregister_device(device_id)


func _register_device(device_id: int) -> void:
	if device_to_player.has(device_id):
		return
	if base_player_device_id == -1:
		base_player_device_id = device_id
		device_to_player[device_id] = base_player
		_configure_actions_for_player(base_player.player_index, device_id)
		return

	var player_index := _get_available_player_index()
	if player_index == -1:
		return
	var new_player := PLAYER_SCENE.instantiate() as Player
	if new_player == null:
		return
	new_player.player_index = player_index
	var spawn_offset := Vector2(24.0 * float(players.size()), 0.0)
	new_player.position = base_player.position + spawn_offset
	add_child(new_player)
	new_player.set_skin(player_index)
	players.append(new_player)
	device_to_player[device_id] = new_player
	_configure_actions_for_player(new_player.player_index, device_id)


func _unregister_device(device_id: int) -> void:
	if not device_to_player.has(device_id):
		return
	var player_instance: Player = device_to_player[device_id]
	device_to_player.erase(device_id)
	if player_instance == base_player:
		_remove_device_bindings_for_player(base_player.player_index, device_id)
		base_player_device_id = -1
		return
	players.erase(player_instance)
	_clear_actions_for_player(player_instance.player_index)
	if is_instance_valid(player_instance):
		player_instance.queue_free()


func _configure_actions_for_player(player_index: int, device_id: int) -> void:
	var prefix := GameConfig.get_player_prefix(player_index)
	var motion_defs := [
		{ "suffix": "move_left", "axis": JOY_AXIS_LEFT_X, "value": -1.0 },
		{ "suffix": "move_right", "axis": JOY_AXIS_LEFT_X, "value": 1.0 },
		{ "suffix": "move_up", "axis": JOY_AXIS_LEFT_Y, "value": -1.0 },
		{ "suffix": "move_down", "axis": JOY_AXIS_LEFT_Y, "value": 1.0 },
		{ "suffix": "weapon_aim_left", "axis": JOY_AXIS_RIGHT_X, "value": -1.0 },
		{ "suffix": "weapon_aim_right", "axis": JOY_AXIS_RIGHT_X, "value": 1.0 },
		{ "suffix": "weapon_aim_up", "axis": JOY_AXIS_RIGHT_Y, "value": -1.0 },
		{ "suffix": "weapon_aim_down", "axis": JOY_AXIS_RIGHT_Y, "value": 1.0 },
		{ "suffix": "attack", "axis": JOY_AXIS_TRIGGER_RIGHT, "value": 1.0 },
		{ "suffix": "block", "axis": JOY_AXIS_TRIGGER_LEFT, "value": 1.0 }
	]
	for motion_def in motion_defs:
		var action_name = prefix + motion_def["suffix"]
		_ensure_action_exists(action_name)
		_remove_action_events_for_device(action_name, device_id)
		var event := InputEventJoypadMotion.new()
		event.device = device_id
		event.axis = motion_def["axis"]
		event.axis_value = motion_def["value"]
		InputMap.action_add_event(action_name, event)

	var button_defs := [
		{ "suffix": "dash", "buttons": [JOY_BUTTON_A, JOY_BUTTON_RIGHT_STICK] },
		{ "suffix": "next_weapon", "buttons": [JOY_BUTTON_DPAD_RIGHT] },
		{ "suffix": "prev_weapon", "buttons": [JOY_BUTTON_DPAD_LEFT] },
		{ "suffix": "skin_next", "buttons": [JOY_BUTTON_RIGHT_SHOULDER] },
		{ "suffix": "skin_prev", "buttons": [JOY_BUTTON_LEFT_SHOULDER] }
	]
	for button_def in button_defs:
		var button_action = prefix + button_def["suffix"]
		_ensure_action_exists(button_action)
		_remove_action_events_for_device(button_action, device_id)
		for button_index in button_def["buttons"]:
			var button_event := InputEventJoypadButton.new()
			button_event.device = device_id
			button_event.button_index = button_index
			button_event.pressed = true
			InputMap.action_add_event(button_action, button_event)


func _clear_actions_for_player(player_index: int) -> void:
	var prefix := GameConfig.get_player_prefix(player_index)
	for suffix in GameConfig.ACTION_SUFFIXES:
		var action_name := prefix + suffix
		if InputMap.has_action(action_name):
			InputMap.erase_action(action_name)


func _strip_gamepad_events_for_prefix(prefix: String) -> void:
	for suffix in GameConfig.ACTION_SUFFIXES:
		var action_name := prefix + suffix
		if not InputMap.has_action(action_name):
			continue
		var events := InputMap.action_get_events(action_name)
		for event in events:
			if event is InputEventJoypadMotion or event is InputEventJoypadButton:
				InputMap.action_erase_event(action_name, event)


func _ensure_action_exists(action_name: String, deadzone: float = GameConfig.ACTION_DEADZONE) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name, deadzone)


func _remove_action_events_for_device(action_name: String, device_id: int) -> void:
	if not InputMap.has_action(action_name):
		return
	var events := InputMap.action_get_events(action_name)
	for event in events:
		if (event is InputEventJoypadMotion or event is InputEventJoypadButton) and event.device == device_id:
			InputMap.action_erase_event(action_name, event)


func _get_available_player_index() -> int:
	var used_indices: Dictionary = {}
	for p in players:
		if not is_instance_valid(p):
			continue
		used_indices[p.player_index] = true
	for i in range(1, GameConfig.MAX_PLAYERS):
		if not used_indices.has(i):
			return i
	return -1


func _remove_device_bindings_for_player(player_index: int, device_id: int) -> void:
	var prefix := GameConfig.get_player_prefix(player_index)
	for suffix in GameConfig.ACTION_SUFFIXES:
		var action_name := prefix + suffix
		_remove_action_events_for_device(action_name, device_id)
