class_name PlayerWeaponManager
extends Node

var thrown_weapon_scene: PackedScene = preload("uid://cfxoiaf6prpg4")
var knife_scene: PackedScene = preload("uid://d1s6h2umj862l")

signal weapon_changed(weapon: Weapon)

@export var weapon_animation_root: Node2D
@export var available_weapons: Array[PackedScene] = []

var current_weapon: Weapon
var current_weapon_index: int = -1
var weapon_owner: Player
var has_firearm: bool = false  # Track si le joueur a une arme à feu


func initialize(player: Player) -> void:
	weapon_owner = player
	change_weapon(knife_scene) # Toujours commencer avec le couteau
	has_firearm = false


func equip_weapon(weapon_instance: Weapon) -> void:
	if current_weapon != null:
		unequip_weapon()
	
	current_weapon = weapon_instance
	weapon_animation_root.add_child(current_weapon)
	current_weapon.on_equipped(weapon_owner)
	weapon_changed.emit(current_weapon)
	
	has_firearm = not (current_weapon is Knife)
	
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
		"Knife":
			var cursor := load("uid://by6xu56h1xb67")
			Cursor.change_cursor(cursor, Vector2(2,2), Vector2(-15, -15))


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
	
	if current_weapon != null:
		if current_weapon.name == new_weapon.name:
			add_ammo_same_weapon(current_weapon.name)
		else:
			equip_weapon(new_weapon)
			_sync_weapon_index_with_scene(weapon_scene)
	else: # Just for Knife
		equip_weapon(new_weapon)
		_sync_weapon_index_with_scene(weapon_scene)


func add_ammo_same_weapon(current_weapon_name: String) -> void:
	match current_weapon_name:
		"Rifle": add_ammo(20)
		"Uzi": add_ammo(30)
		"Shotgun": add_ammo(8)
		"Sniper": add_ammo(3)
		"Revolver": add_ammo(10)


func cycle_weapon(direction: int) -> void:
	# Si on n'a que le couteau, ne rien faire
	if not has_firearm:
		return
	
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
	if current_weapon:
		current_weapon.add_ammo(qte)
		if current_weapon.number_bullets_in_magazine <= 0:
			current_weapon.reload()


func pickup_weapon(weapon_scene: PackedScene) -> void:
	"""Ramasse une arme à feu (remplace le couteau)"""
	if weapon_scene == null:
		return
	
	change_weapon(weapon_scene)
	has_firearm = true
	
	# Mettre à jour l'index de l'arme dans available_weapons si elle y est
	_sync_weapon_index_with_scene(weapon_scene)


func get_fire_rate() -> float:
	if current_weapon == null:
		return 0.0
	return current_weapon.fire_rate


func throw_current_weapon(aim_vector: Vector2):
	if current_weapon == null or current_weapon.is_reloading:
		return
	
	# Ne peut pas jeter le couteau
	if current_weapon is Knife:
		return
	
	var thrown := thrown_weapon_scene.instantiate() as WeaponThrown
	if thrown == null:
		return
	
	var dir := aim_vector.normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT
	
	if current_weapon.barrel_position:
		thrown.global_position = current_weapon.barrel_position.global_position
	else:
		thrown.global_position = weapon_owner.global_position
	
	#weapon_owner.get_tree().current_scene.add_child(thrown)
	var target_parent := Main.corpse_layer if Main.corpse_layer else get_parent()
	target_parent.add_child(thrown)

	# Appliquer stats de l'arme à l'objet jeté (dégâts & ownership pour éviter auto-dégâts)
	thrown.set_texture(current_weapon.get_sprite_texture())
	#thrown.set_damage(20)
	thrown.set_owner_player(weapon_owner)

	if "throw" in thrown:
		thrown.throw(dir)
	
	unequip_weapon()
	# Retourner au couteau après avoir jeté l'arme
	change_weapon(knife_scene)
	has_firearm = false


func _sync_weapon_index_with_scene(target_scene: PackedScene) -> void:
	for i in available_weapons.size():
		if available_weapons[i] == target_scene:
			current_weapon_index = i
			return
