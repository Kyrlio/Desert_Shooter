@icon("res://assets/icons/icon_map.png")
class_name Main
extends Node2D

static var background_effects: Node2D
static var corpse_layer: Node2D
static var coop_mode: bool

@onready var base_player: Player = %Player
@onready var _background_effects: Node2D = %BackgroundEffects
@onready var _corpse_layer: Node2D = %CorpseLayer
@onready var player_spawn_manager: Node2D = %PlayerSpawnManager
@onready var y_sort_root: Node2D = %YSortRoot
@onready var hurt_zone: Area2D = %HurtZone
@onready var player_scores: PlayerScores = %PlayerScores

@export var safe_area: Area2D

@export var _coop_mode: bool = false
@export var can_end_round: bool = true

var _round_ended: bool = false

func _ready() -> void:
	hide_scores()
	coop_mode = _coop_mode
	_round_ended = false
	GameManager.coop_mode = _coop_mode
	background_effects = _background_effects
	corpse_layer = _corpse_layer
	if y_sort_root:
		ControllerManager.setup_scene(base_player, y_sort_root)
	player_spawn_manager.spawn_players()
	
	# Réinitialiser les kill_count de tous les joueurs pour cette nouvelle round
	for player in ControllerManager.get_players():
		if is_instance_valid(player):
			player.kill_count = 0
	
	hurt_zone.body_exited.connect(_on_hurt_zone_body_exited)
	hurt_zone.body_entered.connect(_on_hurt_zone_body_entered)
	
	# Écouter la victoire globale (quand un joueur atteint 10 points)
	if has_node("/root/ScoreManager"):
		if ScoreManager.victory.is_connected(_on_global_victory):
			ScoreManager.victory.disconnect(_on_global_victory)
		ScoreManager.victory.connect(_on_global_victory)
	
	if safe_area:
		safe_area.body_exited.connect(_player_fall_in_void)


func _physics_process(_delta: float) -> void:
	var state_chunks: Array[String] = []
	for player in ControllerManager.get_players():
		if not is_instance_valid(player):
			continue
		state_chunks.append("P%d:%s" % [player.player_index, str(player.get_current_state())])
	
	if ControllerManager.get_number_players() <= 1 and not coop_mode and not _round_ended:
		end_round()


func hide_scores():
	player_scores.visible = false


func show_scores():
	player_scores.update_scores()
	player_scores.visible = true


func end_round() -> void:
	if not can_end_round:
		return
	if _round_ended:
		return
	
	_round_ended = true
	MusicPlayer.play_win()
	
	# Les points ont déjà été ajoutés au moment de chaque kill dans Player._on_died()
	# Donc on n'a rien à faire ici d'autre que vérifier la victoire
	print("DEBUG: Round ended. Current points: %s" % [ScoreManager.get_all_points()])
	
	if player_scores:
		player_scores.visible = true
		var tween := create_tween()
		tween.tween_property(player_scores, "scale", Vector2.ONE, .3).from(Vector2.ZERO).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	show_scores()

	# Verifier la victoire globale uniquement a la fin du round pour ne pas couper une partie en cours
	var victorious_player := ScoreManager.get_victorious_player()
	if victorious_player != -1:
		await _on_global_victory(victorious_player)
		return
	
	await get_tree().create_timer(2).timeout
	_exit_tree()
	get_tree().change_scene_to_packed(GameManager.next_round())


func end_game() -> void:
	get_tree().change_scene_to_packed(GameManager.get_end_game_scene())


func _exit_tree() -> void:
	ControllerManager.teardown_scene()


func _on_hurt_zone_body_exited(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		if not player.is_dead:
			player.hurt_zone()


func _on_hurt_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		player.stop_hurt_zone()


func _on_global_victory(winner_player_index: int) -> void:
	"""Appelé quand un joueur atteint 10 points globalement"""
	print("GLOBAL VICTORY! Player %d wins the entire match!" % winner_player_index)
	
	# Empêcher d'autres rounds
	can_end_round = false
	_round_ended = true
	
	MusicPlayer.play_win()
	if player_scores:
		player_scores.visible = true
		var tween := create_tween()
		tween.tween_property(player_scores, "scale", Vector2.ONE, .5).from(Vector2.ZERO).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	show_scores()
	
	await get_tree().create_timer(2).timeout
	# Aller vers l'écran de fin qui affichera les scores et le bouton menu
	_exit_tree()
	get_tree().change_scene_to_packed(GameManager.get_end_game_scene())

func _player_fall_in_void(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		player.falling_in_void()
