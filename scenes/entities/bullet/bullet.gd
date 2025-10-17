@icon("res://scenes/entities/bullet/bullet.png")
class_name Bullet extends Node2D

var SPEED: int = 400

@onready var life_timer: Timer = $LifeTimer
@onready var hitbox_component: HitboxComponent = $HitboxComponent

var direction: Vector2
var damage_to_apply: int = 1  # Dégâts à appliquer (sera configuré avant _ready)
var time_to_apply: float
var speed_to_apply: int


func _ready() -> void:
	life_timer.wait_time = time_to_apply
	SPEED = speed_to_apply
	# Appliquer les dégâts une fois que hitbox_component est initialisé
	hitbox_component.damage = damage_to_apply
	hitbox_component.hit_hurtbox.connect(_on_hit_hurtbox)
	life_timer.timeout.connect(_on_life_timer_timeout)


func _physics_process(delta: float) -> void:
	global_position += direction * SPEED * delta
	time_to_apply -= delta
	if time_to_apply <= 0:
		_on_life_timer_timeout()


func start(dir: Vector2):
	self.direction = dir
	rotation = direction.angle()


func set_lifetime(time: float):
	time_to_apply = time


func set_speed(speed: int):
	speed_to_apply = speed


## Configure les dégâts de la balle
## @param dmg: Valeur des dégâts à appliquer
func set_damage(dmg: int) -> void:
	damage_to_apply = dmg


func register_collision():
	hitbox_component.is_hit_handled = true
	queue_free()


func _on_life_timer_timeout():
	#call_deferred("queue_free")
	queue_free.call_deferred()


func _on_hit_hurtbox(_hutbox_component: HurtboxComponent):
	register_collision()
