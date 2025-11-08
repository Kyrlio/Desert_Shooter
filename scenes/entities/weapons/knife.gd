@icon("res://assets/icons/icon_weapon.png")
class_name Knife
extends Weapon

var slash_scene = preload("uid://bkwg3s4pmoswa")

## Arme de mélée - ne peut pas être jetée, arme de base

@onready var slash_animation: AnimationPlayer = $AnimationPlayer

@export var slash_time: float = 0.2
@export var sword_return_time: float = 0.5

var can_slash: bool = true
var slash_cooldown: float = 0.5


func _ready() -> void:
	barrel_position = $BarrelPosition
	display_name = "Knife"
	damage = 3
	fire_rate = slash_cooldown
	
	# Le couteau n'utilise pas de munitions
	magazine_length = 0
	number_total_ammo = 0
	number_bullets_in_magazine = 0


func can_fire() -> bool:
	return can_slash and weapon_owner != null


func fire(direction: Vector2) -> void:
	if not can_fire():
		return
	
	can_slash = false
	_perform_slash()
	
	# Cooldown
	#await get_tree().create_timer(slash_cooldown).timeout
	#can_slash = true


func spawn_slash():
	if not is_instance_valid(weapon_owner):
		return
	var sword_slash: Node2D = slash_scene.instantiate()
	# Choisir un parent neutre (parent du joueur) pour éviter que la rotation / scale locale du socket ne décale l'effet
	var spawn_parent: Node = weapon_owner.get_parent() if is_instance_valid(weapon_owner.get_parent()) else get_tree().current_scene
	# Définir les infos de hitbox AVANT d'entrer dans l'arbre (pour éviter tout self-hit si l'anim active la shape immédiatement)
	if sword_slash.has_node("HitboxComponent"):
		var hb := sword_slash.get_node("HitboxComponent") as HitboxComponent
		if hb:
			hb.owner_player_index = weapon_owner.player_index
			hb.damage = damage

	spawn_parent.add_child(sword_slash)

	# Point d'origine: barrel_position si présent, sinon le knife lui-même, sinon le joueur
	var origin: Node2D = barrel_position if is_instance_valid(barrel_position) else self
	var base_pos := origin.global_position
	# Légère avance vers l'avant pour éviter de toucher le joueur lui-même
	var forward_offset := Vector2(20, 0).rotated(origin.global_rotation)
	# Appliquer position & rotation une fois parenté
	sword_slash.global_position = base_pos + forward_offset
	sword_slash.global_rotation = origin.global_rotation

	# Adapter la vitesse de l'animation du couteau (pas le slash lui-même)
	slash_animation.speed_scale = slash_animation.get_animation("slash").length / slash_time


func _perform_slash() -> void:
	# Jouer l'animation de slash
	if slash_animation and slash_animation.has_animation("slash"):
		slash_animation.play("slash")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "slash":
		slash_animation.speed_scale = slash_animation.get_animation("sword_return").length / sword_return_time
		slash_animation.play("sword_return")
	else:
		can_slash = true
