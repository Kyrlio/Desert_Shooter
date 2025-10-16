class_name Enemy
extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent


func _ready() -> void:
	health_component.died.connect(_on_died)


func _on_died():
	queue_free.call_deferred()
