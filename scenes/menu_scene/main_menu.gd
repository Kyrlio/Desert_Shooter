extends MarginContainer

const MULTIPLAYER_LEVEL: String = "uid://bjm5f088lj3hb"
const SINGLEPLAYER_LEVEL: String = "uid://bv3gdo114ov1x"

@onready var menu_input_manager: MenuInputManager = $MenuInputManager
@onready var main_menu_container: VBoxContainer = $MainVBoxContainer
@onready var multiplayer_container: MarginContainer = $MultiplayerContainer
@onready var player_slots_row: HBoxContainer = $MultiplayerContainer/VBoxContainer/HBoxContainer
@onready var options_container: VBoxContainer = $OptionsVBoxContainer
@onready var multiplayer_play_button: Button = $MultiplayerContainer/VBoxContainer/MultiplayerPlayButton
var player_slot_nodes: Array[Control] = []

func _ready() -> void:
	Cursor.change_cursor(load("uid://cvpl0vkt81dco"))
	
	_initialize_options()
	
	menu_input_manager.closing_menu.connect(_on_menu_closed)
	multiplayer_container.visible = false
	# Cache player slot containers (VBoxContainer, VBoxContainer2, ...)
	for child in player_slots_row.get_children():
		if child is Control:
			player_slot_nodes.append(child)
	_update_multiplayer_slots()
	# React to gamepad hotplug
	if not Input.joy_connection_changed.is_connected(_on_joy_connection_changed):
		Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	if ControllerManager.get_player_slots_count() <= 1:
		multiplayer_play_button.disabled = true
	else:
		multiplayer_play_button.disabled = false


func _initialize_options():
	options_container.modulate = Color(1, 1, 1, 0)
	$OptionsVBoxContainer/CheckButton.button_pressed = GameManager.show_fps


func _on_singleplayer_button_pressed() -> void:
	get_tree().change_scene_to_file(SINGLEPLAYER_LEVEL)


func _on_multiplayer_button_pressed() -> void:
	menu_input_manager.open_menu($MultiplayerContainer, $MainVBoxContainer/MultiplayerButton)
	main_menu_container.visible = false
	# Ensure slots are up to date when opening the menu
	_update_multiplayer_slots()


func _on_multiplayer_play_pressed() -> void:
	get_tree().change_scene_to_file(MULTIPLAYER_LEVEL)


func _on_multiplayer_back_button_pressed() -> void:
	menu_input_manager.close_menu()
	main_menu_container.visible = true

func _on_menu_closed():
	main_menu_container.visible = true


# Update the number of visible player selection panels based on connected gamepads
func _update_multiplayer_slots() -> void:
	var connected_pads := Input.get_connected_joypads().size()
	# Always leave at least one slot (keyboard or first pad), clamp to max players
	var target_count: int = max(1, min(connected_pads, GameConfig.MAX_PLAYERS))
	for i in range(player_slot_nodes.size()):
		var slot := player_slot_nodes[i]
		slot.visible = i < target_count
		
	if ControllerManager.get_player_slots_count() <= 1:
		multiplayer_play_button.disabled = true
	else:
		multiplayer_play_button.disabled = false


func _on_joy_connection_changed(_device_id: int, _connected: bool) -> void:
	_update_multiplayer_slots()


func _on_option_pressed() -> void:
	menu_input_manager.open_menu($OptionsVBoxContainer, $MainVBoxContainer/OptionButton)
	main_menu_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	main_menu_container.modulate = Color(1, 1, 1, 0.75)


func _on_option_back_pressed() -> void:
	menu_input_manager.close_menu()
	main_menu_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	main_menu_container.modulate = Color(1, 1, 1, 1)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_check_button_toggled(toggled_on: bool) -> void:
	GameManager.show_fps = toggled_on


func _on_show_damage_check_button_toggled(toggled_on: bool) -> void:
	GameManager.show_damage = toggled_on
