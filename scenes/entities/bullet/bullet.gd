@icon("res://scenes/entities/bullet/tile_0225.png")
class_name Bullet extends Node2D

const SPEED: int = 300

@onready var life_timer: Timer = $LifeTimer

var direction: Vector2


func _ready() -> void:
	life_timer.timeout.connect(_on_life_timer_timeout)


func _physics_process(delta: float) -> void:
	global_position += direction * SPEED * delta


func start(dir: Vector2):
	self.direction = dir
	rotation = direction.angle()


func _on_life_timer_timeout():
	#call_deferred("queue_free")
	queue_free.call_deferred()
