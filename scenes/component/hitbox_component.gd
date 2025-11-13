@icon("res://assets/icons/icon_hitbox.png")
class_name HitboxComponent
extends Area2D

signal hit_hurtbox(hurtbox_component: HurtboxComponent)

const ENVIRONMENT_IMPACT_PARTICLES = preload("uid://dtm267ungrnsi")
const LAYER_ENVIRONMENT: int = 2

var damage: int = 1
var is_hit_handled: bool
var owner_player_index: int = -1


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Ensure we collide with environment (obstacles) for impact behavior;
	# player/enemy filtering is handled on the Hurtbox side.
	set_collision_mask_value(LAYER_ENVIRONMENT, true)

func register_hurtbox_hit(hurtbox_component: HurtboxComponent):
	hit_hurtbox.emit(hurtbox_component)


func set_owner_player_index(idx: int) -> void:
	owner_player_index = idx


func refresh_collision_mask() -> void:
	pass # No-op now; mask is defined in the scene and Hurtbox handles filtering


func _on_body_entered(body: Node2D):
	if body.is_in_group("obstacle"): 
		var hit_particles: Node2D = ENVIRONMENT_IMPACT_PARTICLES.instantiate()
		hit_particles.global_position = self.global_position
		get_parent().get_parent().add_child(hit_particles)
		hit_particles.z_index = 1
		get_parent().queue_free.call_deferred()
	
