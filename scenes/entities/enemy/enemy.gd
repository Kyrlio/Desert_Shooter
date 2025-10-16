class_name Enemy
extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent


func _ready() -> void:
	health_component.died.connect(die)


func die():
	queue_free.call_deferred()
