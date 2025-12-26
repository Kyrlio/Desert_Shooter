@icon("res://assets/icons/icon_map.png")
class_name Main
extends Node2D

static var background_effects: Node2D
static var corpse_layer: Node2D
static var coop_mode: bool

@onready var fps_label: Label = %FpsLabel
@onready var base_player: Player = %Player
@onready var _background_effects: Node2D = %BackgroundEffects
@onready var _corpse_layer: Node2D = %CorpseLayer
@onready var player_spawn_manager: Node2D = %PlayerSpawnManager
@onready var y_sort_root: Node2D = %YSortRoot
@onready var win_label: Label = %WinLabel
@onready var hurt_zone: Area2D = %HurtZone

@export var _coop_mode: bool = false
@export var can_end_round: bool = true

var _round_ended: bool = false

func _ready() -> void:
	show_fps()
	hide_winner()
	if %WinLabel:
		%WinLabel.visible = false
	coop_mode = _coop_mode
	_round_ended = false
	GameManager.coop_mode = _coop_mode
	background_effects = _background_effects
	corpse_layer = _corpse_layer
	if y_sort_root:
		ControllerManager.setup_scene(base_player, y_sort_root)
	player_spawn_manager.spawn_players()
	
	hurt_zone.body_exited.connect(_on_hurt_zone_body_exited)
	hurt_zone.body_entered.connect(_on_hurt_zone_body_entered)


func _physics_process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	var state_chunks: Array[String] = []
	for player in ControllerManager.get_players():
		if not is_instance_valid(player):
			continue
		state_chunks.append("P%d:%s" % [player.player_index, str(player.get_current_state())])
	
	if ControllerManager.get_number_players() <= 1 and not coop_mode and not _round_ended:
		end_round()


func hide_winner():
	%TextureRect.visible = false
	%TextureRect2.visible = false
	%WinnerHeadSprite.visible = false


func show_winner():
	var winner = ControllerManager.get_players()[0].player_index
	%TextureRect.visible = true
	%TextureRect2.visible = true
	%WinnerHeadSprite.visible = true
	
	match winner:
		0:
			%WinnerHeadSprite.frame = 0
		1:
			%WinnerHeadSprite.frame = 4
		2:
			%WinnerHeadSprite.frame = 8
		3:
			%WinnerHeadSprite.frame = 12


func show_fps():
	if GameManager.show_fps:
		fps_label.visible = true
	else:
		fps_label.visible = false


func end_round() -> void:
	if not can_end_round:
		return
	if _round_ended:
		return
	
	_round_ended = true
	#print("Player " + str(ControllerManager.get_players()[0].player_index) + " Won !" )
	MusicPlayer.play_win()
	if win_label:
		win_label.visible = true
		var tween := create_tween()
		tween.tween_property(win_label, "scale", Vector2.ONE, .3).from(Vector2.ZERO).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		win_label.text = "PLAYER " + str(ControllerManager.get_players()[0].player_index + 1) + " WON"
	
	show_winner()
	
	await get_tree().create_timer(3).timeout
	_exit_tree()
	get_tree().change_scene_to_packed(GameManager.next_round())



func _exit_tree() -> void:
	ControllerManager.teardown_scene()


func _on_hurt_zone_body_exited(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		player.hurt_zone()


func _on_hurt_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		player.stop_hurt_zone()
