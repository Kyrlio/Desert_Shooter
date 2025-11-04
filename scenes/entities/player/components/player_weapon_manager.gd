class_name PlayerWeaponManager
extends Node

## Gère l'équipement et le changement d'armes pour un joueur

signal weapon_changed(weapon: Weapon)

@export var weapon_animation_root: Node2D
@export var available_weapons: Array[PackedScene] = []

var current_weapon: Weapon
var current_weapon_index: int = -1
var weapon_owner: Player


func initialize(player: Player) -> void:
	weapon_owner = player
	if available_weapons.is_empty():
		push_error("❌ No weapons configured for player")
		return
	current_weapon_index = 0
	change_weapon(available_weapons[current_weapon_index])


func equip_weapon(weapon_instance: Weapon) -> void:
	if current_weapon != null:
		unequip_weapon()
	
	current_weapon = weapon_instance
	weapon_animation_root.add_child(current_weapon)
	current_weapon.on_equipped(weapon_owner)
	weapon_changed.emit(current_weapon)
	
	# WEAPON CURSOR
	match current_weapon.display_name:
		"Rifle": 
			var cursor := load("uid://k77h833x77v0")
			Cursor.change_cursor(cursor, Vector2.ONE, Vector2(-15, -15))
		"Uzi":
			var cursor := load("uid://c3cps5gb0s6r5")
			Cursor.change_cursor(cursor, Vector2.ONE, Vector2(-15, -15))
		"Shotgun":
			var cursor := load("uid://bcyt0d2u7ni4j")
			Cursor.change_cursor(cursor, Vector2.ONE, Vector2(-15, -15))
		"Sniper":
			var cursor := load("uid://l5xfn518qxye")
			Cursor.change_cursor(cursor, Vector2.ONE, Vector2(-15, -15))


func unequip_weapon() -> void:
	if current_weapon == null:
		return
	
	current_weapon.on_unequipped()
	weapon_animation_root.remove_child(current_weapon)
	current_weapon.queue_free()
	current_weapon = null


func change_weapon(weapon_scene: PackedScene) -> void:
	if weapon_scene == null:
		push_error("❌ Attempt to change weapon with null scene")
		return
	
	var new_weapon := weapon_scene.instantiate() as Weapon
	if new_weapon == null:
		push_error("❌ Scene is not a valid weapon")
		return
	
	equip_weapon(new_weapon)
	_sync_weapon_index_with_scene(weapon_scene)


func cycle_weapon(direction: int) -> void:
	if available_weapons.is_empty():
		return
	
	current_weapon_index = wrapi(current_weapon_index + direction, 0, available_weapons.size())
	var next_scene: PackedScene = available_weapons[current_weapon_index]
	change_weapon(next_scene)


func try_fire(aim_vector: Vector2, can_fire: bool) -> void:
	if current_weapon == null or not can_fire:
		return
	current_weapon.fire(aim_vector)


func process_weapon(delta: float) -> void:
	if current_weapon == null:
		return
	current_weapon._physics_process(delta)


func add_ammo(qte: int):
	current_weapon.add_ammo(qte)


func get_fire_rate() -> float:
	if current_weapon == null:
		return 0.0
	return current_weapon.fire_rate


func _sync_weapon_index_with_scene(target_scene: PackedScene) -> void:
	for i in available_weapons.size():
		if available_weapons[i] == target_scene:
			current_weapon_index = i
			return
