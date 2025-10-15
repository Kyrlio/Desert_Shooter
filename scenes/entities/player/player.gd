@icon("res://scenes/entities/player/icon_character.png")
class_name Player
extends CharacterBody2D

const BASE_MOVEMENT_SPEED: float = 100
const BASE_FIRE_RATE: float = 0.2

@export var aim_root: Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var weapon_animation_player: AnimationPlayer = $WeaponAnimationPlayer
@onready var visuals: Node2D = $Visuals
@onready var state_machine: StateMachine = $StateMachine
@onready var weapon_root: Node2D = $Visuals/WeaponRoot
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var barrel_position: Marker2D = %BarrelPosition

var bullet_scene: PackedScene = preload("uid://ccqop2oca0tcc")
var muzzle_flash_scene: PackedScene = preload("uid://we7xx2omqegd")

var movement_vector: Vector2 = Vector2.ZERO
var aim_vector: Vector2 = Vector2.RIGHT
var _input_prefix: String = "player0_"

# Dash
var dash_timer: float = 0.0
var dash_reload_timer: float = 0.0


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	_gather_input()
	update_aim_position()
	
	print(Engine.get_frames_per_second())
	print(Engine.get_physics_frames())
	
	# Décrémenter le cooldown du dash
	if dash_reload_timer > 0.0:
		dash_reload_timer -= _delta


func update_aim_position() -> void:
	# Mouse
	aim_vector = aim_root.global_position.direction_to(aim_root.get_global_mouse_position())
	var aim_position = weapon_root.global_position + aim_vector
	weapon_root.look_at(aim_position)
	visuals.scale = Vector2.ONE if aim_vector.x >= 0 else Vector2(-1, 1)


func try_fire() -> void:
	if !fire_rate_timer.is_stopped():
		return
	
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.global_position = weapon_root.global_position
	bullet.start(aim_vector)
	get_parent().add_child(bullet, true)
	
	fire_rate_timer.wait_time = get_fire_rate()
	fire_rate_timer.start()
	
	play_fire_effects()


func play_fire_effects():
	if weapon_animation_player.is_playing():
		weapon_animation_player.stop()
	weapon_animation_player.play("fire")
	
	var muzzle_flash: Node2D = muzzle_flash_scene.instantiate()
	muzzle_flash.global_position = barrel_position.global_position
	muzzle_flash.rotation = barrel_position.global_rotation
	get_parent().add_child(muzzle_flash)


func get_fire_rate() -> float:
	return BASE_FIRE_RATE 


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


func _ensure_actions_prefix() -> String:
	if InputMap.has_action(_input_prefix + "move_left"):
		return _input_prefix
	return "player0_"


func get_movement_speed() -> float:
	return BASE_MOVEMENT_SPEED
	
	
	
	
	
	
	
	
