class_name PlayerSpawnManager
extends Node2D

var positions: Array[Vector2] = []

func _ready() -> void:
	for marker in get_children():
		if marker is Marker2D:
			positions.append(marker.global_position)


func spawn_players():
	if positions.is_empty():
		return
	
	positions.shuffle()
	for player in ControllerManager.get_players():
		if not is_instance_valid(player):
			continue
		var idx := player.player_index % positions.size()
		player.global_position = positions[idx]
