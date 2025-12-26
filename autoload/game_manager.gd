extends Node

signal coop_mode_changed(enabled: bool)


var show_fps: bool = false
var show_damage: bool = true
var coop_mode: bool = false
var fullscreen: bool = false
var show_aiming: bool = true
var activate_zone: bool = true
var multiplayer_scenes: Array[String] = ["uid://bj1my63f0v553", "uid://ch86xj8ci7f7a",
"uid://64sjetxrpab7", "uid://pq8pimrg2nfh", "uid://blq81prqmljm0", "uid://pklrei6nqtbh"]
var multiplayer_actual_scene: String= "uid://bj1my63f0v553"
var player_max_health: int = 50
var levels: Array[String]

func _ready() -> void:
	levels = multiplayer_scenes.duplicate()

func set_coop_mode(enabled: bool) -> void:
	if coop_mode == enabled:
		return
	coop_mode = enabled
	coop_mode_changed.emit(enabled)


func next_round() -> PackedScene:
	if levels.is_empty():
		levels = multiplayer_scenes.duplicate()
	var multiplayer_next_scene = levels.pick_random()
	while multiplayer_actual_scene == multiplayer_next_scene:
		multiplayer_next_scene = levels.pick_random()
	levels.erase(multiplayer_next_scene)
	return load(multiplayer_next_scene)
