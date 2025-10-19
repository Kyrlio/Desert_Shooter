class_name GameConfig
extends Resource

## Configuration centralisée pour le jeu

const MAX_PLAYERS: int = 4
const ACTION_DEADZONE: float = 0.2
const BASE_MOVEMENT_SPEED: float = 100.0

const ACTION_SUFFIXES: Array[StringName] = [
	&"move_left",
	&"move_right",
	&"move_up",
	&"move_down",
	&"dash",
	&"attack",
	&"block",
	&"next_weapon",
	&"prev_weapon",
	&"skin_next",
	&"skin_prev",
	&"weapon_aim_left",
	&"weapon_aim_right",
	&"weapon_aim_up",
	&"weapon_aim_down"
]


static func get_player_prefix(index: int) -> String:
	return "player%d_" % index
