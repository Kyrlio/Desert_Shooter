@icon("res://scenes/entities/player/icon_character.png")
class_name Player
extends CharacterBody2D

## Orchestrateur principal du joueur - délègue aux composants spécialisés

@export var aim_root: Node2D
@export_range(0, 3) var player_index: int = 0

# Skin configuration
@export var character_spritesheet: Texture2D
@export var available_skins: Array[PlayerSkin] = []

# Components
var input_controller: PlayerInputController
var skin_manager: PlayerSkinManager
var weapon_manager: PlayerWeaponManager

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals: Node2D = $Visuals
@onready var state_machine: StateMachine = $StateMachine
@onready var weapon_root: Node2D = $Visuals/WeaponRoot
@onready var weapon_animation_root: Node2D = $Visuals/WeaponRoot/WeaponAnimationRoot
@onready var health_component: HealthComponent = $HealthComponent
@onready var character_sprite: Sprite2D = $Visuals/HitFlashSpriteComponent
@onready var reload_sprite: Sprite2D = $ReloadSprite
@onready var shield := $Shield
@onready var run_particles: GPUParticles2D = $Visuals/GPUParticles2D

# DASH
var dash_timer: float = 0.0
var dash_reload_timer: float = 0.0

# Weapons configuration
var rifle_scene: PackedScene = preload("uid://bnnmu2ycsi5pd")
var uzi_scene: PackedScene = preload("uid://c55fbudaqm7bl")
var shotgun_scene: PackedScene = preload("uid://r4fu7s6dkih4")
var sniper_scene: PackedScene = preload("uid://did8iv6uy01c")
var corpse_scene: PackedScene = preload("uid://bm5ha6ujfnjyi")

var is_dead: bool = false


func _ready() -> void:
	_initialize_components()
	add_to_group("player")
	reload_sprite.visible = false
	health_component.died.connect(_on_died)
	


func _initialize_components() -> void:
	# Input Controller
	input_controller = PlayerInputController.new()
	input_controller.input_prefix = GameConfig.get_player_prefix(player_index)
	input_controller.allow_mouse_aim = (player_index == 0)  # Only player 0 uses mouse
	add_child(input_controller)
	
	# Connect input signals
	input_controller.fire_requested.connect(_on_fire_requested)
	input_controller.reload_requested.connect(_on_reload_requested)
	input_controller.dash_requested.connect(_on_dash_requested)
	input_controller.block_started.connect(_on_block_started)
	input_controller.block_stopped.connect(_on_block_stopped)
	input_controller.weapon_cycled.connect(_on_weapon_cycled)
	input_controller.skin_cycled.connect(_on_skin_cycled)
	
	# Skin Manager
	skin_manager = PlayerSkinManager.new()
	skin_manager.sprite = character_sprite
	skin_manager.spritesheet = character_spritesheet
	skin_manager.available_skins = available_skins
	add_child(skin_manager)
	
	# Weapon Manager
	weapon_manager = PlayerWeaponManager.new()
	weapon_manager.weapon_animation_root = self.weapon_animation_root
	weapon_manager.available_weapons = [rifle_scene, uzi_scene, shotgun_scene, sniper_scene]
	add_child(weapon_manager)
	weapon_manager.initialize(self)


func _physics_process(delta: float) -> void:
	weapon_manager.process_weapon(delta)
	input_controller.gather_input()
	_update_aim_and_visuals()
	_update_shield()
	_update_dash_cooldown(delta)


func add_ammo(amount: int):
	weapon_manager.add_ammo(amount)


func heal(amount: int):
	health_component.heal(amount)


func _input(event: InputEvent) -> void:
	if input_controller:
		input_controller.handle_input_event(event, aim_root)
	
	# THROW WEAPON
	var throw_action := GameConfig.get_player_prefix(player_index) + "throw_weapon"
	if Input.is_action_just_pressed(throw_action):
		var aim := input_controller.get_effective_aim(aim_root)
		weapon_manager.throw_current_weapon(aim)


func _update_aim_and_visuals() -> void:
	var aim_vector := input_controller.get_effective_aim(aim_root)
	var aim_position := weapon_root.global_position + aim_vector
	visuals.scale = Vector2.ONE if aim_vector.x >= 0 else Vector2(-1, 1)
	weapon_root.look_at(aim_position)
	if shield:
		shield.update_orientation(aim_vector)


func _update_shield() -> void:
	if not shield:
		return
	var aim_vector := input_controller.get_effective_aim(aim_root)
	shield.update_orientation(aim_vector)


func _update_dash_cooldown(delta: float) -> void:
	if dash_reload_timer > 0.0:
		dash_reload_timer -= delta


# ========== INPUT SIGNAL HANDLERS ==========

func _on_fire_requested() -> void:
	var can_fire = not (state_machine.current_state is DashingState) and not (shield and shield.is_active())
	var aim := input_controller.get_effective_aim(aim_root)
	weapon_manager.try_fire(aim, can_fire)


func _on_reload_requested() -> void:
	weapon_manager.current_weapon.reload()


func _on_dash_requested() -> void:
	# Handled by state machine via is_dash_pressed()
	pass


func _on_block_started() -> void:
	if shield and not (state_machine.current_state is DashingState):
		shield.activate()


func _on_block_stopped() -> void:
	if shield:
		shield.deactivate()


func _on_weapon_cycled(direction: int) -> void:
	weapon_manager.cycle_weapon(direction)


func _on_skin_cycled(direction: int) -> void:
	if skin_manager:
		skin_manager.cycle_skin(direction)


# ========== PUBLIC API FOR EXTERNAL SYSTEMS ==========

func cycle_skin(direction: int = 1) -> void:
	if skin_manager:
		skin_manager.cycle_skin(direction)


func set_skin(skin_index: int) -> void:
	if skin_manager:
		skin_manager.apply_skin(skin_index)


func start_reloading() -> void:
	reload_sprite.visible = true


func finished_reloading() -> void:
	reload_sprite.visible = false


# ========== GETTERS ==========

func get_fire_rate() -> float:
	return weapon_manager.get_fire_rate()


func get_movement_speed() -> float:
	return GameConfig.BASE_MOVEMENT_SPEED


func get_current_state() -> State:
	return state_machine.current_state


func get_current_weapon() -> Weapon:
	return weapon_manager.current_weapon


func get_movement_vector() -> Vector2:
	return input_controller.movement_vector if input_controller else Vector2.ZERO

## Return 1 for right
## -1 for left
func get_facing_direction():
	return visuals.scale.x


# ========== DASH SYSTEM (Used by State Machine) ==========

func is_dash_pressed() -> bool:
	if not input_controller:
		return false
	# The state machine checks this, but the signal already exists
	# For compatibility with existing FSM code:
	var dash_action := input_controller.input_prefix + "dash"
	return InputMap.has_action(dash_action) and Input.is_action_just_pressed(dash_action)


# ========== CLEANUP ==========

func _on_died() -> void:
	if is_dead:
		return
	
	is_dead = true
	if shield:
		shield.deactivate()
	# Spawn corpse at current position and keep some momentum
	var corpse := corpse_scene.instantiate()
	if corpse:
		corpse.sprite = $Visuals/HitFlashSpriteComponent.texture
		if corpse is RigidBody2D:
			(corpse as RigidBody2D).global_position = global_position
			(corpse as RigidBody2D).linear_velocity = velocity
		else:
			(corpse as Node2D).global_position = global_position
		var target_parent: Node = Main.corpse_layer if Main.corpse_layer else get_parent()
		if target_parent:
			target_parent.add_child(corpse)
	
	queue_free.call_deferred()
