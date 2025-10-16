@icon("res://scenes/entities/bullet/bullet.png")
class_name Bullet extends Node2D

const SPEED: int = 400

@onready var life_timer: Timer = $LifeTimer
@onready var hitbox_component: HitboxComponent = $HitboxComponent

var direction: Vector2


func _ready() -> void:
	hitbox_component.hit_hurtbox.connect(_on_hit_hurtbox)
	life_timer.timeout.connect(_on_life_timer_timeout)


func _physics_process(delta: float) -> void:
	global_position += direction * SPEED * delta


func start(dir: Vector2):
	self.direction = dir
	rotation = direction.angle()


func register_collision():
	hitbox_component.is_hit_handled = true
	queue_free()


func _on_life_timer_timeout():
	#call_deferred("queue_free")
	queue_free.call_deferred()


func _on_hit_hurtbox(_hutbox_component: HurtboxComponent):
	register_collision()
