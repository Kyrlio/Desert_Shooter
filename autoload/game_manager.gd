extends Node

signal coop_mode_changed(enabled: bool)


var show_fps: bool = false
var show_damage: bool = true
var coop_mode: bool = false
var fullscreen: bool = false
var show_aiming: bool = true
var activate_zone: bool = true
var multiplayer_scenes: Array[String] = ["uid://bj1my63f0v553", "uid://ch86xj8ci7f7a", "uid://64sjetxrpab7", "uid://pq8pimrg2nfh"]
var multiplayer_actual_scene: String= "uid://bj1my63f0v553"
var player_max_health: int = 100

func set_coop_mode(enabled: bool) -> void:
	if coop_mode == enabled:
		return
	coop_mode = enabled
	coop_mode_changed.emit(enabled)


func next_round() -> PackedScene:
	var multiplayer_next_scene = multiplayer_scenes.pick_random()
	if multiplayer_next_scene == multiplayer_actual_scene:
		multiplayer_next_scene = multiplayer_scenes.pick_random()
	multiplayer_actual_scene = multiplayer_next_scene
	return load(multiplayer_next_scene)
