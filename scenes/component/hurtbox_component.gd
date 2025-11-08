@icon("res://assets/icons/icon_damage_area.png")
class_name HurtboxComponent
extends Area2D

signal knockbacked(direction: Vector2, force: float, knockback_duration: float)

var impact_particles_scene: PackedScene = preload("uid://dtr5lw5ocrg3p")
var floating_text_scene: PackedScene = preload("uid://d256axv46seu0")

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
	
	var hitbox := other_area as HitboxComponent
	
	# empêcher self-hit
	if get_parent() is Player and hitbox.owner_player_index != -1:
		var owning_player := get_parent() as Player
		if owning_player.player_index == hitbox.owner_player_index:
			return
	
	_handle_hit.call_deferred(hitbox)
	
	var floating_text = floating_text_scene.instantiate() as Node2D
	get_tree().get_first_node_in_group("foreground_layer").add_child(floating_text)
	
	var spawn_position_x := randi_range(-16, 16)
	var spawn_position_y := randi_range(0, 16)
	
	floating_text.global_position = global_position + (Vector2(spawn_position_x, spawn_position_y))
	floating_text.start(str(hitbox.damage))
	
