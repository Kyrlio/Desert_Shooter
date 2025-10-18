@icon("res://scenes/entities/player/icon_character.png")
class_name Player
extends CharacterBody2D

const BASE_MOVEMENT_SPEED: float = 100

@export var aim_root: Node2D
@export_range(0, 3) var player_index: int = 0
@export var allow_mouse_aim: bool = true

# 🎨 SKINS
@export_group("Skin System")
@export var character_spritesheet: Texture2D
@export var available_skins: Array[PlayerSkin] = []
@export var current_skin_index: int = 1

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals: Node2D = $Visuals
@onready var state_machine: StateMachine = $StateMachine
@onready var weapon_root: Node2D = $Visuals/WeaponRoot
@onready var weapon_animation_root: Node2D = $Visuals/WeaponRoot/WeaponAnimationRoot
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var barrel_position: Marker2D = %BarrelPosition
@onready var character_sprite_old: Sprite2D = $Visuals/CharacterSprite
@onready var health_component: HealthComponent = $HealthComponent
@onready var character_sprite: Sprite2D = $Visuals/HitFlashSpriteComponent
@onready var reload_sprite: Sprite2D = $ReloadSprite
@onready var shield := $Shield


# WEAPONS
var rifle_scene: PackedScene = preload("uid://bnnmu2ycsi5pd")
var uzi_scene: PackedScene = preload("uid://c55fbudaqm7bl")
var shotgun_scene: PackedScene = preload("uid://r4fu7s6dkih4")
var sniper_scene: PackedScene = preload("uid://did8iv6uy01c")
var bullet_scene: PackedScene = preload("uid://ccqop2oca0tcc")
var muzzle_flash_scene: PackedScene = preload("uid://we7xx2omqegd")
var current_weapon: Weapon
var weapon_scenes: Array[PackedScene] = []
var current_weapon_index: int = -1

# MOVEMENTS & INPUTS
var movement_vector: Vector2 = Vector2.ZERO
var aim_vector: Vector2 = Vector2.RIGHT
var aim_direct: Vector2 = Vector2.RIGHT
var is_attack_pressed: bool
var last_gamepad_aim: Vector2 = Vector2.RIGHT  # Store last gamepad aim direction
var _input_prefix: String = "player0_"
var _using_mouse_for_aim: bool = true
var _mouse_hidden: bool = false
var _gamepad_aim_deadzone: float = 0.25

# DASH
var dash_timer: float = 0.0
var dash_reload_timer: float = 0.0



func _ready() -> void:
	reload_sprite.visible = false
	apply_skin(current_skin_index)
	health_component.died.connect(_on_died)
	_initialize_weapon_inventory()
	_using_mouse_for_aim = allow_mouse_aim


func _physics_process(delta: float) -> void:
	if current_weapon == null:
		return
	current_weapon._process(delta)
	
	_gather_input()
	update_aim_position()
	if shield:
		shield.update_orientation(aim_vector)
	
	# Décrémenter le cooldown du dash
	if dash_reload_timer > 0.0:
		dash_reload_timer -= delta


func apply_skin(skin_index: int) -> void:
	if skin_index < 0 or skin_index >= available_skins.size():
		push_error("Invalid skin index: %d" % skin_index)
		return

	if not character_spritesheet:
		push_error("No character spritesheet assigned!")
		return

	current_skin_index = skin_index
	var skin = available_skins[skin_index]

	# Créer un AtlasTexture pour extraire la bonne région
	var atlas = AtlasTexture.new()
	atlas.atlas = character_spritesheet
	atlas.region = skin.get_idle_region()  # Frame 0 (idle)

	# Appliquer au sprite
	character_sprite.texture = atlas

	print("✅ Skin applied: %s (ID: %d)" % [skin.skin_name, skin.skin_id])


# Cycler entre les skins (pour debug)
func cycle_skin(direction: int = 1) -> void:
	var new_index = wrapi(current_skin_index + direction, 0, available_skins.size())
	apply_skin(new_index)


func update_aim_position() -> void:
	var effective_aim := aim_vector
	if allow_mouse_aim and _using_mouse_for_aim:
		var mouse_position := aim_root.get_global_mouse_position()
		effective_aim = aim_root.global_position.direction_to(mouse_position)
	else:
		if aim_direct.length_squared() >= _gamepad_aim_deadzone * _gamepad_aim_deadzone:
			last_gamepad_aim = aim_direct.normalized()
		if last_gamepad_aim.length_squared() >= 0.0001:
			effective_aim = last_gamepad_aim
		else:
			effective_aim = aim_vector

	if effective_aim.length_squared() < 0.0001:
		effective_aim = Vector2.RIGHT
	aim_vector = effective_aim.normalized()
	var aim_position := weapon_root.global_position + aim_vector
	visuals.scale = Vector2.ONE if aim_vector.x >= 0 else Vector2(-1, 1)
	weapon_root.look_at(aim_position)


## Équipe une nouvelle arme
## @param weapon_instance: L'instance de l'arme à équiper (peut être créée depuis une PackedScene)
func equip_weapon(weapon_instance: Weapon) -> void:
	# Déséquiper l'arme actuelle si elle existe
	if current_weapon != null:
		unequip_weapon()
	
	# Équiper la nouvelle arme
	current_weapon = weapon_instance
	weapon_animation_root.add_child(current_weapon)
	current_weapon.on_equipped(self)


## Déséquipe l'arme actuelle
func unequip_weapon() -> void:
	if current_weapon == null:
		return
	
	current_weapon.on_unequipped()
	weapon_animation_root.remove_child(current_weapon)
	current_weapon.queue_free()
	current_weapon = null


## Change l'arme actuelle par une nouvelle
## @param weapon_scene: La PackedScene de l'arme à équiper
func change_weapon(weapon_scene: PackedScene) -> void:
	if weapon_scene == null:
		push_error("❌ Tentative de changer d'arme avec une scène nulle")
		return
	
	var new_weapon = weapon_scene.instantiate() as Weapon
	if new_weapon == null:
		push_error("❌ La scène n'est pas une arme valide")
		return
	
	equip_weapon(new_weapon)
	_sync_weapon_index_with_scene(weapon_scene)


## Fait défiler les armes disponibles dans un sens donné
## @param direction: +1 pour suivant, -1 pour précédent
func cycle_weapon(direction: int) -> void:
	if weapon_scenes.is_empty():
		return

	current_weapon_index = wrapi(current_weapon_index + direction, 0, weapon_scenes.size())
	var next_scene: PackedScene = weapon_scenes[current_weapon_index]
	change_weapon(next_scene)


## Maintient l'index courant aligné avec la scène équipée
func _sync_weapon_index_with_scene(target_scene: PackedScene) -> void:
	for i in weapon_scenes.size():
		if weapon_scenes[i] == target_scene:
			current_weapon_index = i
			return


func try_fire() -> void:
	if (current_weapon == null) or (state_machine.current_state is DashingState) or (shield and shield.is_active()):
		return
	current_weapon.fire(aim_vector)


func block():
	if shield == null:
		return
	if state_machine.current_state is DashingState:
		return
	shield.activate()


func stop_block() -> void:
	if shield == null:
		return
	shield.deactivate()


func start_reloading():
	reload_sprite.visible = true


func finished_reloading():
	reload_sprite.visible = false


# ========== GETTERS / SETTERS ==========

func get_fire_rate() -> float:
	return current_weapon.fire_rate


func get_movement_speed() -> float:
	return BASE_MOVEMENT_SPEED


func get_current_state() -> State:
	return state_machine.current_state


# Change skin with int
func set_skin_by_id(skin_id: int) -> void:
	for i in available_skins.size():
		if available_skins[i].skin_id == skin_id:
			apply_skin(i)
			return
	push_error("Skin with ID %d not found" % skin_id)


# Change skin by name
func set_skin_by_name(skin_name: String) -> void:
	for i in available_skins.size():
		if available_skins[i].skin_name == skin_name:
			apply_skin(i)
			return
	push_error("Skin '%s' not found" % skin_name)


func get_current_skin() -> PlayerSkin:
	if current_skin_index >= 0 and current_skin_index < available_skins.size():
		return available_skins[current_skin_index]
	return null


func get_current_weapon() -> Weapon:
	return current_weapon


## Prépare la liste des armes disponibles et équipe la première
func _initialize_weapon_inventory() -> void:
	weapon_scenes.clear()
	if rifle_scene:
		weapon_scenes.append(rifle_scene)
	if uzi_scene:
		weapon_scenes.append(uzi_scene)
	if shotgun_scene:
		weapon_scenes.append(shotgun_scene)
	if sniper_scene:
		weapon_scenes.append(sniper_scene)

	if weapon_scenes.is_empty():
		push_error("❌ Aucune arme configurée pour le joueur")
		return

	current_weapon_index = 0
	change_weapon(weapon_scenes[current_weapon_index])


func _gather_input() -> void:
	var prefix := _ensure_actions_prefix()
	movement_vector = Input.get_vector(
		prefix + "move_left",
		prefix + "move_right",
		prefix + "move_up",
		prefix + "move_down"
	)
	
	# CONTROLLER - Check if gamepad is being used for aiming
	aim_direct = Input.get_vector(
		prefix + "weapon_aim_left",
		prefix + "weapon_aim_right",
		prefix + "weapon_aim_up",
		prefix + "weapon_aim_down"
	)
	
	if aim_direct.length_squared() >= _gamepad_aim_deadzone * _gamepad_aim_deadzone:
		last_gamepad_aim = aim_direct.normalized()
		if _using_mouse_for_aim:
			_using_mouse_for_aim = false
			_set_mouse_visibility(false)

	if Input.is_action_pressed("player0_attack"):
		try_fire()
	
	# Debug - Changer de skin avec ui_up/ui_down
	if Input.is_action_just_pressed("ui_up"):
		cycle_skin(1)
	if Input.is_action_just_pressed("ui_down"):
		cycle_skin(-1)
	
	# Debug - Changer d'arme avec ui_left/ui_right (cycle modulo)
	if Input.is_action_just_pressed("player0_prev_weapon"):
		cycle_weapon(-1)
	if Input.is_action_just_pressed("player0_next_weapon"):
		cycle_weapon(1)

	var block_action := prefix + "block"
	if InputMap.has_action(block_action):
		if Input.is_action_pressed(block_action):
			block()
		else:
			stop_block()


func _ensure_actions_prefix() -> String:
	if InputMap.has_action(_input_prefix + "move_left"):
		return _input_prefix
	return "player0_"


func _input(event: InputEvent) -> void:
	if not allow_mouse_aim:
		return
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		_using_mouse_for_aim = true
		_set_mouse_visibility(true)
		if event is InputEventMouseMotion and event.relative.length_squared() > 0.0:
			var mouse_position := aim_root.get_global_mouse_position()
			aim_vector = aim_root.global_position.direction_to(mouse_position)
	elif event is InputEventJoypadMotion:
		if event.axis in [JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y] and abs(event.axis_value) >= _gamepad_aim_deadzone:
			_using_mouse_for_aim = false
			_set_mouse_visibility(false)


func _on_died():
	print("player died")
	stop_block()


func _set_mouse_visibility(should_be_visible: bool) -> void:
	if not allow_mouse_aim:
		return
	if should_be_visible and _mouse_hidden:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_mouse_hidden = false
	elif not should_be_visible and not _mouse_hidden:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		_mouse_hidden = true
