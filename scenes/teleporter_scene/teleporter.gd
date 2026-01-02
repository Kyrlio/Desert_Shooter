class_name Teleporter
extends Area2D

@export var destination_teleporter: Teleporter

@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	if not timer.is_stopped():
		return
	if body is Player:
		var player: Player = body
		player.global_position = destination_teleporter.global_position
		animation_player.play("enter")
		timer.start()
		
		# Destination Teleporter
		destination_teleporter.animation_player.play("enter")
		destination_teleporter.timer.start()


func _on_timer_timeout() -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "enter":
		animation_player.play("idle")
