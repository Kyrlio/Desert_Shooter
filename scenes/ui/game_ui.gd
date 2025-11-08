extends CanvasLayer

## Game UI controller
## Shows one HBoxContainer per active player (1-4).

const MAX_PLAYERS := 4

var _last_player_count: int = -1

@onready var _p1: HBoxContainer = $MarginContainer/Player1HBoxContainer
@onready var _p2: HBoxContainer = $MarginContainer/Player2HBoxContainer
@onready var _p3: HBoxContainer = $MarginContainer/Player3HBoxContainer
@onready var _p4: HBoxContainer = $MarginContainer/Player4HBoxContainer

# Cached UI nodes per slot
@onready var _ammo_labels: Array[Label] = [
	$MarginContainer/Player1HBoxContainer/VBoxContainer/HBoxContainer/Label,
	$MarginContainer/Player2HBoxContainer/VBoxContainer/HBoxContainer/Label,
	$MarginContainer/Player3HBoxContainer/VBoxContainer/HBoxContainer/Label,
	$MarginContainer/Player4HBoxContainer/VBoxContainer/HBoxContainer/Label,
]
@onready var _health_bars: Array[ProgressBar] = [
	$MarginContainer/Player1HBoxContainer/VBoxContainer/ProgressBar,
	$MarginContainer/Player2HBoxContainer/VBoxContainer/ProgressBar,
	$MarginContainer/Player3HBoxContainer/VBoxContainer/ProgressBar,
	$MarginContainer/Player4HBoxContainer/VBoxContainer/ProgressBar,
]

# Track current weapon per slot to manage signal connections
var _slot_weapon: Dictionary = {}


func _ready() -> void:
	# Initialize visibility based on current connected/spawned players
	if typeof(ControllerManager) != TYPE_NIL:
		if not ControllerManager.players_changed.is_connected(_on_players_changed):
			ControllerManager.players_changed.connect(_on_players_changed)
	
	_update_visibility(_get_player_count())
	_rebind_all_player_slots()


func _get_player_count() -> int:
	# Prefer the slot count (distinct player indices/devices), so UI stays visible if a player dies.
	var count := 1
	if "get_player_slots_count" in ControllerManager:
		count = int(ControllerManager.get_player_slots_count())
	else:
		# Fallback to number of active player nodes
		var arr := ControllerManager.get_players()
		if typeof(arr) == TYPE_ARRAY and arr.size() > 0:
			count = arr.size()
	return clamp(count, 1, MAX_PLAYERS)


func _update_visibility(count: int) -> void:
	_last_player_count = clamp(count, 1, MAX_PLAYERS)
	var visibles := [
		_last_player_count >= 1,
		_last_player_count >= 2,
		_last_player_count >= 3,
		_last_player_count >= 4,
	]
	_p1.visible = visibles[0]
	_p2.visible = visibles[1]
	_p3.visible = visibles[2]
	_p4.visible = visibles[3]
	# For hidden slots, also clear UI
	for i in range(MAX_PLAYERS):
		if i >= _last_player_count:
			_set_ammo_text(i, "— / —")
			_set_health(i, 0, 1)


# Optional: public API to force a refresh from outside
func refresh_players_ui() -> void:
	_update_visibility(_get_player_count())
	_rebind_all_player_slots()


func _on_players_changed(new_count: int, _players: Array) -> void:
	_update_visibility(new_count)
	_rebind_all_player_slots()


func _rebind_all_player_slots() -> void:
	# Build a map from index -> Player for quick lookup
	var by_index: Dictionary = {}
	if typeof(ControllerManager) != TYPE_NIL:
		for player in ControllerManager.get_players():
			if is_instance_valid(player):
				by_index[player.player_index] = player
	# For each visible slot, bind signals or clear
	for i in range(_last_player_count):
		if by_index.has(i):
			_bind_player_signals(i, by_index[i])
			# Initialize UI with current values
			_update_slot_initial_values(i, by_index[i])
		else:
			_unbind_slot(i)
			_set_ammo_text(i, "— / —")
			_set_health(i, 0, 1)
	# For non-visible slots, ensure unbound
	for i in range(_last_player_count, MAX_PLAYERS):
		_unbind_slot(i)


func _bind_player_signals(slot_index: int, player: Player) -> void:
	# Health updates
	var hc := player.health_component if "health_component" in player else null
	if hc and not hc.health_changed.is_connected(_on_player_health_changed):
		hc.health_changed.connect(_on_player_health_changed.bind(slot_index))
	# Weapon changed updates (to (re)connect ammo signal)
	var wm := player.weapon_manager if "weapon_manager" in player else null
	if wm and not wm.weapon_changed.is_connected(_on_player_weapon_changed):
		wm.weapon_changed.connect(_on_player_weapon_changed.bind(slot_index))
	# Ensure ammo signal connected for current weapon
	if wm and wm.current_weapon:
		_connect_weapon_ammo_signal(slot_index, wm.current_weapon)


func _unbind_slot(slot_index: int) -> void:
	# Disconnect previous weapon signal if tracked
	if _slot_weapon.has(slot_index):
		var w: Weapon = _slot_weapon[slot_index]
		if is_instance_valid(w) and w.ammo_changed.is_connected(_on_player_ammo_changed):
			w.ammo_changed.disconnect(_on_player_ammo_changed)
		_slot_weapon.erase(slot_index)


func _connect_weapon_ammo_signal(slot_index: int, weapon: Weapon) -> void:
	# Disconnect previous if different
	if _slot_weapon.has(slot_index):
		var prev: Weapon = _slot_weapon[slot_index]
		if prev != weapon and is_instance_valid(prev) and prev.ammo_changed.is_connected(_on_player_ammo_changed):
			prev.ammo_changed.disconnect(_on_player_ammo_changed)
	# Connect new
	if weapon and not weapon.ammo_changed.is_connected(_on_player_ammo_changed):
		weapon.ammo_changed.connect(_on_player_ammo_changed.bind(slot_index))
	_slot_weapon[slot_index] = weapon


func _update_slot_initial_values(slot_index: int, player: Player) -> void:
	# Health initial
	var hc := player.health_component if "health_component" in player else null
	if hc:
		_set_health(slot_index, hc.current_health, hc.max_health)
	# Ammo initial
	var wm := player.weapon_manager if "weapon_manager" in player else null
	if wm and wm.current_weapon:
		var w := wm.current_weapon
		_set_ammo_text(slot_index, "%d / %d" % [w.number_bullets_in_magazine, w.number_total_ammo])
	else:
		_set_ammo_text(slot_index, "— / —")


func _on_player_health_changed(current: int, max_value: int, slot_index: int) -> void:
	_set_health(slot_index, current, max_value)


func _on_player_weapon_changed(new_weapon: Weapon, slot_index: int) -> void:
	_connect_weapon_ammo_signal(slot_index, new_weapon)
	# Also refresh ammo display immediately
	if new_weapon:
		_set_ammo_text(slot_index, "%d / %d" % [new_weapon.number_bullets_in_magazine, new_weapon.number_total_ammo])
	else:
		_set_ammo_text(slot_index, "— / —") 


func _on_player_ammo_changed(current_mag: int, total_ammo: int, _mag_size: int, slot_index: int) -> void:
	_set_ammo_text(slot_index, "%d / %d" % [current_mag, total_ammo])


func _set_ammo_text(slot_index: int, text: String) -> void:
	if slot_index >= 0 and slot_index < _ammo_labels.size():
		_ammo_labels[slot_index].text = text


func _set_health(slot_index: int, current: int, max_value: int) -> void:
	if slot_index >= 0 and slot_index < _health_bars.size():
		var bar := _health_bars[slot_index]
		bar.max_value = max(1, max_value)
		bar.value = clamp(current, 0, bar.max_value)
