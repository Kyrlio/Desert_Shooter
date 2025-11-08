class_name WeaponThrown
extends Node2D

@export var SPEED_START: float = 300.0
@export var FRICTION: float = 900.0
@export var MIN_SPEED: float = 20.0
@export var LIFETIME: float = 2.0

@onready var life_timer: Timer = $LifeTimer
@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var direction: Vector2
var damage_to_apply: int = 1
var time_to_apply: float
var speed_to_apply: float
var owner_player_index: int = -1


func _ready() -> void:
	if time_to_apply <= 0:
		time_to_apply = LIFETIME
	if speed_to_apply <= 0:
		speed_to_apply = SPEED_START
	life_timer.wait_time = time_to_apply
	life_timer.start()
	
	life_timer.timeout.connect(_on_life_timer_timeout)
	# Appliquer les paramètres si déjà définis avant l'entrée dans l'arbre
	hitbox_component.damage = damage_to_apply
	hitbox_component.owner_player_index = owner_player_index
	hitbox_component.hit_hurtbox.connect(_on_hit_hurtbox)


func _physics_process(delta: float) -> void:
	if speed_to_apply > 0:
		global_position += direction * speed_to_apply * delta
		speed_to_apply = max(speed_to_apply - FRICTION * delta, 0.0)
	if speed_to_apply < MIN_SPEED:
		speed_to_apply = 0.0
	time_to_apply -= delta
	if time_to_apply <= 0.0:
		queue_free.call_deferred()


func throw(dir: Vector2):
	direction = dir.normalized()
	rotation = direction.angle()
	


func set_texture(text: Texture2D):
	sprite.texture = text

func set_damage(dmg: int) -> void:
	damage_to_apply = dmg
	if is_inside_tree() and is_instance_valid(hitbox_component):
		hitbox_component.damage = damage_to_apply

func set_owner_player(player: Player) -> void:
	if player == null:
		owner_player_index = -1
	else:
		owner_player_index = player.player_index
	if is_inside_tree() and is_instance_valid(hitbox_component):
		hitbox_component.owner_player_index = owner_player_index


func _on_life_timer_timeout():
	queue_free.call_deferred()

func _on_hit_hurtbox(_hurtbox: HurtboxComponent) -> void:
	# Empêcher plusieurs hits et détruire l'arme jetée après impact
	hitbox_component.is_hit_handled = true
	queue_free()
