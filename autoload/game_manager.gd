extends Node

signal coop_mode_changed(enabled: bool)

var show_fps: bool = false
var show_damage: bool = true
var coop_mode: bool = false


func set_coop_mode(enabled: bool) -> void:
	if coop_mode == enabled:
		return
	coop_mode = enabled
	coop_mode_changed.emit(enabled)
