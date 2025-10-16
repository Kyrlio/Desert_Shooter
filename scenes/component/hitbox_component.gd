@icon("res://assets/icons/icon_hitbox.png")
class_name HitboxComponent
extends Area2D

signal hit_hurtbox(hurtbox_component: HurtboxComponent)

var damage: int = 1
var is_hit_handled: bool


func register_hurtbox_hit(hurtbox_component: HurtboxComponent):
	hit_hurtbox.emit(hurtbox_component)
