extends Node

## Gestion du système de scoring global multi-rounds

signal points_changed(player_index: int, points: int)
signal victory(player_index: int)

const POINTS_TO_WIN: int = 10
const MAX_PLAYERS: int = 4

var player_points: Array[int] = [0, 0, 0, 0]  # Points de chaque joueur


func _ready() -> void:
	# Ne pas réinitialiser automatiquement - les scores doivent persister entre les rounds!
	# reset_all_scores() sera appelée manuellement à la fin d'une partie complète
	pass


func add_points(player_index: int, points: int) -> void:
	"""Ajouter des points à un joueur et vérifier la victoire"""
	if player_index < 0 or player_index >= MAX_PLAYERS:
		return
	
	player_points[player_index] += points
	points_changed.emit(player_index, player_points[player_index])
	
	print("Player %d now has %d points" % [player_index+1, player_points[player_index]])
	# La verification de la victoire est desormais faite a la fin du round (Main.end_round)


func get_points(player_index: int) -> int:
	"""Obtenir les points actuels d'un joueur"""
	if player_index < 0 or player_index >= MAX_PLAYERS:
		return 0
	return player_points[player_index]


func get_all_points() -> Array[int]:
	"""Obtenir tous les points"""
	return player_points.duplicate()


func get_victorious_player() -> int:
	"""Renvoie l'index du joueur ayant atteint le seuil de victoire, ou -1 si personne."""
	for i in range(MAX_PLAYERS):
		if player_points[i] >= POINTS_TO_WIN:
			return i
	return -1


func reset_round_kills() -> void:
	"""Réinitialiser les kills de tous les joueurs (appelé en début de round)"""
	pass


func reset_all_scores() -> void:
	"""Réinitialiser complètement les scores (nouvelle partie)"""
	for i in range(MAX_PLAYERS):
		player_points[i] = 0
	print("All scores reset")


func reset_scores() -> void:
	"""Alias pour reset_all_scores"""
	reset_all_scores()
