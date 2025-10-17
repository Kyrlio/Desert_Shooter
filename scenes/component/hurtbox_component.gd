@icon("res://assets/icons/icon_damage_area.png")
class_name HurtboxComponent
extends Area2D

signal knockbacked(direction: Vector2, force: float, knockback_duration: float)

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
	
	var raw_direction := (global_position - hitbox_component.global_position)
	var knockback_direction := raw_direction.normalized() if raw_direction.length_squared() > 0.0001 else Vector2.ZERO
	#get_parent().apply_knockback(knockback_direction, 150.0, 0.12)
	knockbacked.emit(knockback_direction, 20.0, 0.12)
	
	if get_parent() is Player:
		GameCamera.shake(1)


func _on_area_entered(other_area: Area2D):
	if other_area is not HitboxComponent:
		return
	
	_handle_hit.call_deferred(other_area)
	
