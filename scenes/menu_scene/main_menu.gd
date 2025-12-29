extends MarginContainer

const MULTIPLAYER_LEVEL: String = "uid://bj1my63f0v553"
const SINGLEPLAYER_LEVEL: String = "uid://d1ar5lun3xl7x"

@onready var menu_input_manager: MenuInputManager = $MenuInputManager
@onready var main_menu_container: VBoxContainer = $MainVBoxContainer
@onready var multiplayer_container: MarginContainer = $MultiplayerContainer
@onready var player_slots_row: HBoxContainer = $MultiplayerContainer/VBoxContainer/HBoxContainer
@onready var options_container: HBoxContainer = $OptionsVBoxContainer
@onready var multiplayer_play_button: Button = $MultiplayerContainer/VBoxContainer/MultiplayerPlayButton
@onready var title_label: Label = %TitleLabel
@onready var sfx_down_button: Button = %SfxDownButton
@onready var sfx_progress_bar: ProgressBar = %SfxProgressBar
@onready var sfx_up_button: Button = %SfxUpButton
@onready var music_down_button: Button = %MusicDownButton
@onready var music_progress_bar: ProgressBar = %MusicProgressBar
@onready var music_up_button: Button = %MusicUpButton
@onready var fullscreen_check_button: CheckButton = %FullscreenCheckButton
@onready var health_progress_bar: ProgressBar = %HealthProgressBar

var player_slot_nodes: Array[Control] = []

func _ready() -> void:
	Cursor.change_cursor(load("uid://cvpl0vkt81dco"))
	%ShowDamageCheckButton.button_pressed = GameManager.show_damage
	%ShowAimCursorCheckButton.button_pressed = GameManager.show_aiming
	%ZoneCheckButton.button_pressed = GameManager.activate_zone
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
	
	update_display()
	
	sfx_down_button.pressed.connect(_on_down_pressed.bind("sfx"))
	sfx_up_button.pressed.connect(_on_up_pressed.bind("sfx"))
	
	music_down_button.pressed.connect(_on_down_pressed.bind("music"))
	music_up_button.pressed.connect(_on_up_pressed.bind("music"))


func _initialize_options():
	options_container.modulate = Color(1, 1, 1, 0)
	fullscreen_check_button.button_pressed = GameManager.fullscreen


func update_display():
	sfx_progress_bar.value = get_bus_volume("sfx")
	music_progress_bar.value = get_bus_volume("music")
	health_progress_bar.value = GameManager.player_max_health
	%HealthLabel2.text = str(int(health_progress_bar.value))


func get_bus_volume(bus_name: String) -> float:
	var index := AudioServer.get_bus_index(bus_name)
	return AudioServer.get_bus_volume_linear(index)


func change_bus_volume(bus_name: String, linear_change: float):
	var current_volume_linear := get_bus_volume(bus_name)
	var index := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_linear(index, clamp(current_volume_linear + linear_change, 0, 1))
	update_display()


func _on_down_pressed(bus_name: String):
	MusicPlayer.play_button_clicked()
	change_bus_volume(bus_name, -0.1)


func _on_up_pressed(bus_name: String):
	MusicPlayer.play_button_clicked()
	change_bus_volume(bus_name, +0.1)


func _on_singleplayer_button_pressed() -> void:
	MusicPlayer.play_button_clicked()
	get_tree().change_scene_to_file(SINGLEPLAYER_LEVEL)


func _on_multiplayer_button_pressed() -> void:
	MusicPlayer.play_button_clicked()
	menu_input_manager.open_menu($MultiplayerContainer, $MainVBoxContainer/MultiplayerButton)
	main_menu_container.visible = false
	title_label.visible = false
	# Ensure slots are up to date when opening the menu
	_update_multiplayer_slots()


func _on_multiplayer_play_pressed() -> void:
	MusicPlayer.play_button_clicked()
	get_tree().change_scene_to_file(MULTIPLAYER_LEVEL)


func _on_multiplayer_back_button_pressed() -> void:
	MusicPlayer.play_button_clicked()
	menu_input_manager.close_menu()
	main_menu_container.visible = true
	title_label.visible = true

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
	MusicPlayer.play_button_clicked()
	menu_input_manager.open_menu($OptionsVBoxContainer, $MainVBoxContainer/OptionButton)
	#main_menu_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	#main_menu_container.modulate = Color(1, 1, 1, 0.75)
	main_menu_container.visible = false
	%HealthLabel2.visible = true


func _on_option_back_pressed() -> void:
	MusicPlayer.play_button_clicked()
	menu_input_manager.close_menu()
	#main_menu_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	#main_menu_container.modulate = Color(1, 1, 1, 1)
	main_menu_container.visible = true
	%HealthLabel2.visible = false


func _on_quit_button_pressed() -> void:
	MusicPlayer.play_button_clicked()
	get_tree().quit()


func _on_check_button_toggled(toggled_on: bool) -> void:
	MusicPlayer.play_button_clicked()
	GameManager.show_fps = toggled_on


func _on_show_damage_check_button_toggled(toggled_on: bool) -> void:
	MusicPlayer.play_button_clicked()
	GameManager.show_damage = toggled_on


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		GameManager.fullscreen = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		GameManager.fullscreen = false


func _on_command_button_pressed() -> void:
	MusicPlayer.play_button_clicked()
	menu_input_manager.open_menu(%CommandContainer, %CommandBack)
	main_menu_container.visible = false
	title_label.visible = false


func _on_command_back_pressed() -> void:
	MusicPlayer.play_button_clicked()
	menu_input_manager.close_menu()
	main_menu_container.visible = true
	title_label.visible = true


func _on_show_aim_cursor_check_button_toggled(toggled_on: bool) -> void:
	MusicPlayer.play_button_clicked()
	GameManager.show_aiming = toggled_on


func _on_health_down_button_pressed() -> void:
	MusicPlayer.play_button_clicked()
	GameManager.player_max_health -= 5
	GameManager.player_max_health = clamp(GameManager.player_max_health, 1, 100)
	update_display()


func _on_health_up_button_pressed() -> void:
	MusicPlayer.play_button_clicked()
	GameManager.player_max_health += 5
	GameManager.player_max_health = clamp(GameManager.player_max_health, 1, 100)
	update_display()


func _on_zone_check_button_toggled(toggled_on: bool) -> void:
	MusicPlayer.play_button_clicked()
	GameManager.activate_zone = toggled_on
