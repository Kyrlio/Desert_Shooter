@icon("res://assets/icons/icon.png")
class_name HealthComponent
extends Node

signal died
signal damaged
signal health_changed(current_health: int, max_health: int)

var ground_particles_scene: PackedScene = preload("uid://d4fjkvjerbdpm")

@export var max_health: int = 10

var _current_health: int
var current_health: int:
	get:
		return _current_health
	set(value):
		if value == _current_health:
			return
		_current_health = value
		health_changed.emit(_current_health, max_health)


func _ready() -> void:
	current_health = max_health


func spawn_death_particles():
	var die_particles: Node2D = ground_particles_scene.instantiate()
	die_particles.global_position = get_parent().global_position 
	
	var background_node: Node = Main.background_effects
	if not is_instance_valid(background_node):
		background_node = get_parent()
	background_node.add_child(die_particles)


func damage(amount: int):
	# never go below 0 and never go abose max_health
	current_health = clamp(current_health - amount, 0, max_health)
	damaged.emit()
	if current_health == 0:
		spawn_death_particles()
		died.emit()


func heal(amount: int):
	if current_health <= 0:
		return
	
	current_health += amount
	current_health = clamp(current_health, 0, max_health)
