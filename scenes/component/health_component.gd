@icon("res://assets/icons/icon.png")
class_name HealthComponent
extends Node

signal died
signal damaged

var ground_particles_scene: PackedScene = preload("uid://d4fjkvjerbdpm")

@export var max_health: int = 1

var current_health: int


func _ready() -> void:
	current_health = max_health


func damage(amount: int):
	# never go below 0 and never go abose max_health
	current_health = clamp(current_health - amount, 0, max_health)
	damaged.emit()
	if current_health == 0:
		var die_particles: Node2D = ground_particles_scene.instantiate()
		die_particles.global_position = get_parent().global_position
		get_parent().get_parent().add_child(die_particles)
		died.emit()
