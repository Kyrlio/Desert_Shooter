@icon("res://assets/icons/icon_map.png")
class_name Main
extends Node2D

static var background_effects: Node2D
static var corpse_layer: Node2D

@onready var fps_label: Label = $CanvasLayer/Container/HBoxContainer/FpsLabel
@onready var state_label: Label = $CanvasLayer/Container/HBoxContainer/StateLabel
@onready var base_player: Player = $YSortRoot/Player
@onready var _background_effects: Node2D = $BackgroundEffects
@onready var _corpse_layer: Node2D = $CorpseLayer


func _ready() -> void:
	background_effects = _background_effects
	corpse_layer = _corpse_layer
	var YSortRoot: Node2D = base_player.get_parent()
	if YSortRoot:
		ControllerManager.setup_scene(base_player, YSortRoot)


func _physics_process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	var state_chunks: Array[String] = []
	for player in ControllerManager.get_players():
		if not is_instance_valid(player):
			continue
		state_chunks.append("P%d:%s" % [player.player_index, str(player.get_current_state())])
	state_label.text = "States: " + ", ".join(state_chunks)


func _exit_tree() -> void:
	ControllerManager.teardown_scene()
