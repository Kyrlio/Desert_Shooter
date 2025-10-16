@icon("res://assets/icons/icon_map.png")
extends Node2D

@onready var fps_label: Label = $CanvasLayer/Container/HBoxContainer/FpsLabel
@onready var state_label: Label = $CanvasLayer/Container/HBoxContainer/StateLabel

var player: Player

func _ready() -> void:
	player = get_node("Player")

func _physics_process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	state_label.text = "State: " + str(player.get_current_state())
