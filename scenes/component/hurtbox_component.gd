@icon("res://assets/icons/icon_damage_area.png")
class_name HurtboxComponent
extends Area2D

var impact_particles_scene: PackedScene = preload("uid://dtr5lw5ocrg3p")

@export var health_component: HealthComponent


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func spawn_hit_particles():
	var hit_particles: Node2D = impact_particles_scene.instantiate()
	hit_particles.global_position = self.global_position
	get_parent().get_parent().add_child(hit_particles)


func _handle_hit(hitbox_component: HitboxComponent):
	if hitbox_component.is_hit_handled:
		return
	
	hitbox_component.register_hurtbox_hit(self)
	health_component.damage(hitbox_component.damage)
	spawn_hit_particles()
	
	if get_parent() is Player:
		GameCamera.shake(1)


func _on_area_entered(other_area: Area2D):
	if other_area is not HitboxComponent:
		return
	
	_handle_hit.call_deferred(other_area)
	
