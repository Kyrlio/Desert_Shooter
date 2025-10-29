extends Node

const PLAYER_SCENE: PackedScene = preload("res://scenes/entities/player/player.tscn")

var players: Array[Player] = []
var device_to_player_index: Dictionary = {}
var player_nodes: Dictionary = {}
var base_player_device_id: int = -1

var base_player: Player
var player_parent: Node

func _ready() -> void:
	if not Input.joy_connection_changed.is_connected(_on_joy_connection_changed):
		Input.joy_connection_changed.connect(_on_joy_connection_changed)
	for device_id in Input.get_connected_joypads():
		_register_device(device_id)


func setup_scene(base: Player, parent: Node) -> void:
	_cleanup_invalid_state()
	base_player = base
	player_parent = parent
	players.clear()
	player_nodes.clear()
	if base_player:
		base_player.player_index = 0
		players.append(base_player)
		player_nodes[0] = base_player
		_strip_gamepad_events_for_prefix(GameConfig.get_player_prefix(0))
		var exit_callable := Callable(self, "_on_base_player_tree_exited")
		if not base_player.tree_exited.is_connected(exit_callable):
			base_player.tree_exited.connect(exit_callable, CONNECT_ONE_SHOT)
	if base_player_device_id != -1:
		device_to_player_index[base_player_device_id] = 0
		_configure_actions_for_player(0, base_player_device_id)
	for device_id in Input.get_connected_joypads():
		_register_device(device_id)
	_refresh_spawned_players()


func teardown_scene() -> void:
	base_player = null
	player_parent = null
	players.clear()
	player_nodes.clear()


func get_players() -> Array[Player]:
	_prune_invalid_players()
	var result: Array[Player] = []
	for player in players:
		if is_instance_valid(player):
			result.append(player)
	result.sort_custom(func(a: Player, b: Player) -> bool: return a.player_index < b.player_index)
	return result


func get_player_index_for_device(device_id: int) -> int:
	return device_to_player_index.get(device_id, -1)


func get_device_for_player(player_index: int) -> int:
	for device_id in device_to_player_index:
		if device_to_player_index[device_id] == player_index:
			return int(device_id)
	return -1


func _refresh_spawned_players() -> void:
	var unique_indices: Array[int] = []
	for device_id in device_to_player_index.keys():
		var player_index := int(device_to_player_index[device_id])
		if unique_indices.has(player_index):
			continue
		unique_indices.append(player_index)
		_spawn_player_if_ready(player_index)


func _register_device(device_id: int) -> void:
	if device_to_player_index.has(device_id):
		return
	if base_player_device_id == -1:
		base_player_device_id = device_id
		device_to_player_index[device_id] = 0
		_configure_actions_for_player(0, device_id)
		_spawn_player_if_ready(0)
		return
	var player_index := _get_available_player_index()
	if player_index == -1:
		return
	device_to_player_index[device_id] = player_index
	_configure_actions_for_player(player_index, device_id)
	_spawn_player_if_ready(player_index)


func _unregister_device(device_id: int) -> void:
	if not device_to_player_index.has(device_id):
		return
	var player_index := int(device_to_player_index[device_id])
	device_to_player_index.erase(device_id)
	if player_index == 0:
		_remove_device_bindings_for_player(0, device_id)
		if device_id == base_player_device_id:
			base_player_device_id = -1
		return
	_clear_actions_for_player(player_index)
	_teardown_player_node(player_index)


func _spawn_player_if_ready(player_index: int) -> void:
	if player_index == 0:
		if base_player and not players.has(base_player):
			players.append(base_player)
			player_nodes[0] = base_player
		return
	if base_player == null or player_parent == null:
		return
	if player_nodes.has(player_index):
		var existing: Player = player_nodes[player_index]
		if is_instance_valid(existing):
			return
	var new_player := PLAYER_SCENE.instantiate() as Player
	if new_player == null:
		return
	new_player.player_index = player_index
	var spawn_offset := Vector2(24.0 * float(players.size()), 0.0)
	new_player.position = base_player.position + spawn_offset
	player_parent.add_child(new_player)
	new_player.set_skin(player_index)
	players.append(new_player)
	player_nodes[player_index] = new_player
	new_player.tree_exited.connect(_on_dynamic_player_tree_exited.bind(player_index, new_player))


func _teardown_player_node(player_index: int) -> void:
	if not player_nodes.has(player_index):
		return
	var player: Player = player_nodes[player_index]
	player_nodes.erase(player_index)
	if players.has(player):
		players.erase(player)
	if is_instance_valid(player):
		player.queue_free()


func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
	if connected:
		_register_device(device_id)
	else:
		_unregister_device(device_id)


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
		var action_name: String = prefix + String(motion_def["suffix"])
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
		#{ "suffix": "skin_next", "buttons": [JOY_BUTTON_RIGHT_SHOULDER] },
		#{ "suffix": "skin_prev", "buttons": [JOY_BUTTON_LEFT_SHOULDER] }
	]
	for button_def in button_defs:
		var action_name_button: String = prefix + String(button_def["suffix"])
		_ensure_action_exists(action_name_button)
		_remove_action_events_for_device(action_name_button, device_id)
		for button_index in button_def["buttons"]:
			var button_event := InputEventJoypadButton.new()
			button_event.device = device_id
			button_event.button_index = button_index
			button_event.pressed = true
			InputMap.action_add_event(action_name_button, button_event)


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
	var used_indices: Dictionary = { 0: true }
	for device_id in device_to_player_index.keys():
		var idx := int(device_to_player_index[device_id])
		used_indices[idx] = true
	for i in range(1, GameConfig.MAX_PLAYERS):
		if not used_indices.has(i):
			return i
	return -1


func _remove_device_bindings_for_player(player_index: int, device_id: int) -> void:
	var prefix := GameConfig.get_player_prefix(player_index)
	for suffix in GameConfig.ACTION_SUFFIXES:
		var action_name := prefix + suffix
		_remove_action_events_for_device(action_name, device_id)


func _cleanup_invalid_state() -> void:
	_prune_invalid_players()
	var stale_indices: Array[int] = []
	for index in player_nodes.keys():
		var node: Player = player_nodes[index]
		if not is_instance_valid(node):
			stale_indices.append(int(index))
	for index in stale_indices:
		player_nodes.erase(index)


func _prune_invalid_players() -> void:
	for i in range(players.size() - 1, -1, -1):
		if not is_instance_valid(players[i]):
			players.remove_at(i)


func _on_dynamic_player_tree_exited(player_index: int, player_ref: Player) -> void:
	if players.has(player_ref):
		players.erase(player_ref)
	if player_nodes.get(player_index) == player_ref:
		player_nodes.erase(player_index)


func _on_base_player_tree_exited() -> void:
	if base_player and players.has(base_player):
		players.erase(base_player)
	player_nodes.erase(0)
	base_player = null
	player_parent = null
