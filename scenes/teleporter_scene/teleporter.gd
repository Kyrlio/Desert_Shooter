class_name Teleporter
extends Area2D

@export var destination_teleporter: Teleporter
@export var color: Color = Color(1, 1, 1, 1):
	set(new_value):
		color = new_value
		_update_sprite_color()

@onready var timer: Timer = $Timer
@onready var bullet_timer: Timer = $BulletTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_update_sprite_color()


func _update_sprite_color() -> void:
	if sprite and sprite.material:
		sprite.material.set_shader_parameter("target_color", color)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if not timer.is_stopped():
			return
		var player: Player = body
		player.global_position = destination_teleporter.global_position
		MusicPlayer.play_teleport()
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
