@icon("res://assets/icons/icon_hitbox.png")
class_name HitboxComponent
extends Area2D

signal hit_hurtbox(hurtbox_component: HurtboxComponent)

var damage: int = 1
var is_hit_handled: bool
var owner_player_index: int = -1


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func register_hurtbox_hit(hurtbox_component: HurtboxComponent):
	hit_hurtbox.emit(hurtbox_component)


func _on_body_entered(body: Node2D):
	if body.is_in_group("obstacle"):
		# TODO play environment hit particles
		get_parent().queue_free.call_deferred()
