@icon("res://assets/icons/icon_damage_area.png")
class_name HurtboxComponent
extends Area2D

signal knockbacked(direction: Vector2, force: float, knockback_duration: float)

const LAYER_PLAYER = 1
const LAYER_ENEMY = 3
const LAYER_BULLET = 9

var impact_particles_scene: PackedScene = preload("uid://dtr5lw5ocrg3p")
var floating_text_scene: PackedScene = preload("uid://d256axv46seu0")

@export var health_component: HealthComponent
@onready var hit_stream_player: AudioStreamPlayer = $HitStreamPlayer


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	_apply_coop_collision()
	if GameManager.has_signal("coop_mode_changed"):
		GameManager.coop_mode_changed.connect(_on_coop_mode_changed)


func spawn_hit_particles():
	var hit_particles: Node2D = impact_particles_scene.instantiate()
	hit_particles.global_position = self.global_position
	get_parent().get_parent().add_child(hit_particles)


#func play_hit_effects():
	#hit_stream_player.play()


func _handle_hit(hitbox_component: HitboxComponent):
	if hitbox_component.is_hit_handled:
		return
	
	hitbox_component.register_hurtbox_hit(self)
	
	# Tracker le dernier joueur qui a fait des dégâts (pour les kills)
	if get_parent() is Player and hitbox_component.owner_player_index != -1:
		var victim_player := get_parent() as Player
		victim_player.set_killer(hitbox_component.owner_player_index)
	
	health_component.damage(hitbox_component.damage)
	spawn_hit_particles()
	#play_hit_effects()
	
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

	# En coop: ignorer toutes les attaques d'origine joueur sur un joueur (friendly-fire off)
	# NB: owner_player_index >= 0 signifie que le hitbox appartient à un joueur
	if GameManager.coop_mode and get_parent() is Player and hitbox.owner_player_index != -1:
		return
	
	_handle_hit.call_deferred(hitbox)
	
	var floating_text = floating_text_scene.instantiate() as Node2D
	get_tree().get_first_node_in_group("foreground_layer").add_child(floating_text)
	
	var spawn_position_x := randi_range(-16, 16)
	var spawn_position_y := randi_range(0, 16)
	
	floating_text.global_position = global_position + (Vector2(spawn_position_x, spawn_position_y))
	floating_text.start(str(hitbox.damage))


func _on_coop_mode_changed(_enabled: bool) -> void:
	_apply_coop_collision()


func _apply_coop_collision() -> void:
	# Reset mask then enable layers explicitly per coop mode
	collision_mask = 0
	# Always detect enemy-layer hitboxes (e.g., melee)
	set_collision_mask_value(LAYER_ENEMY, true)
	# Always detect bullets; friendly-fire is handled in _on_area_entered by owner check
	set_collision_mask_value(LAYER_BULLET, true)
	
