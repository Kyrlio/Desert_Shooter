@icon("res://scenes/entities/player/icon_character.png")
class_name Player
extends CharacterBody2D

const BASE_MOVEMENT_SPEED: float = 100
const BASE_FIRE_RATE: float = 0.2

@export var aim_root: Node2D

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

var bullet_scene: PackedScene = preload("uid://ccqop2oca0tcc")
var muzzle_flash_scene: PackedScene = preload("uid://we7xx2omqegd")

var rifle_scene: PackedScene = preload("uid://bnnmu2ycsi5pd")
var uzi_scene: PackedScene = preload("uid://c55fbudaqm7bl")
var shotgun_scene: PackedScene = preload("uid://r4fu7s6dkih4")

var movement_vector: Vector2 = Vector2.ZERO
var aim_vector: Vector2 = Vector2.RIGHT
var _input_prefix: String = "player0_"

# DASH
var dash_timer: float = 0.0
var dash_reload_timer: float = 0.0

# WEAPONS - Système modulaire
var current_weapon: Weapon  # L'arme actuellement équipée


func _ready() -> void:
	apply_skin(current_skin_index)
	health_component.died.connect(_on_died)
	
	# Équiper l'arme de départ (rifle)
	var rifle = rifle_scene.instantiate() as Weapon
	equip_weapon(rifle)


func _physics_process(delta: float) -> void:
	if current_weapon == null:
		return
	current_weapon._process(delta)
	
	_gather_input()
	update_aim_position()
	
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
	# Mouse
	aim_vector = aim_root.global_position.direction_to(aim_root.get_global_mouse_position())
	var aim_position = weapon_root.global_position + aim_vector
	weapon_root.look_at(aim_position)
	visuals.scale = Vector2.ONE if aim_vector.x >= 0 else Vector2(-1, 1)


# ========== SYSTÈME D'ARMES MODULAIRE ==========

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


## Obtient l'arme actuellement équipée
func get_current_weapon() -> Weapon:
	return current_weapon


# ========== FIN SYSTÈME D'ARMES ==========

func try_fire() -> void:
	if current_weapon == null or state_machine.current_state is DashingState:
		return
	current_weapon.fire(aim_vector)


func block():
	pass
	#TODO clic droit bloquer attack ennemi


func _gather_input() -> void:
	var prefix := _ensure_actions_prefix()
	movement_vector = Input.get_vector(
		prefix + "move_left",
		prefix + "move_right",
		prefix + "move_up",
		prefix + "move_down"
	)
	
	if Input.is_action_pressed("player0_attack"):
		try_fire()
	
	# Debug - Changer de skin avec ui_up/ui_down
	if Input.is_action_just_pressed("ui_up"):
		cycle_skin(1)
	if Input.is_action_just_pressed("ui_down"):
		cycle_skin(-1)
	
	# Debug - Changer d'arme avec ui_left/ui_right (pour tester)
	if Input.is_action_just_pressed("ui_left"):
		change_weapon(rifle_scene)
	if Input.is_action_just_pressed("ui_right"):
		change_weapon(uzi_scene)
	if Input.is_action_just_pressed("ui_accept"):
		change_weapon(shotgun_scene)


func _ensure_actions_prefix() -> String:
	if InputMap.has_action(_input_prefix + "move_left"):
		return _input_prefix
	return "player0_"


func _on_died():
	print("player died")


# ========== GETTERS / SETTERS ==========

func get_fire_rate() -> float:
	return BASE_FIRE_RATE 


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
