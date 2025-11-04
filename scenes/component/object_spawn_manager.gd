@icon("res://assets/icons/icon_destroyable.png")
class_name ObjectSpawnManager
extends Node2D

@export var object_pickup_scene: PackedScene

# Armes possibles et sprites correspondants (même index)
@export var available_objects: Array[PackedScene] = []
@export var available_sprites: Array[Texture2D] = []

# Où parent-er les pickups (laisser vide = ce nœud). 
# Mets ici le NodePath vers YSortRoot pour avoir le y-sorting (ex: "../YSortRoot").
@export var pickup_parent_path: NodePath

@export var spawn_interval: float = 12.0
@export var spawn_interval_jitter: float = 4.0 # [spawn_interval - jitter ; spawn_interval + jitter]
@export var spawn_on_ready: bool = true
@export var auto_pickup: bool = true

var _spawners: Array[Marker2D] = []
var _active_pickups: Dictionary = {}

func _ready() -> void:
	randomize()
	_collect_spawners()
	for marker in _spawners:
		if spawn_on_ready:
			_spawn_on_marker(marker)
		_schedule_next_spawn(marker)

func _collect_spawners() -> void:
	_spawners.clear()
	for marker in get_children():
		if marker is Marker2D:
			_spawners.append(marker)


func _get_pickup_parent() -> Node:
	var n := get_node_or_null(pickup_parent_path)
	return n if n else self


func _schedule_next_spawn(marker: Marker2D) -> void:
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = max(0.1, spawn_interval + randf_range(-spawn_interval_jitter, spawn_interval_jitter))
	add_child(t)
	t.timeout.connect(func():
		_spawn_on_marker(marker)
		_schedule_next_spawn(marker)
		t.queue_free()
	)
	t.start()


func _spawn_on_marker(marker: Marker2D) -> void:
	if not object_pickup_scene:
		return
	
	# Un seul pickup par marker
	if _active_pickups.has(marker) and is_instance_valid(_active_pickups[marker]):
		return
	
	# Choix de l'arme
	if available_objects.is_empty():
		return
	var idx := randi() % available_objects.size()
	
	var pickup := object_pickup_scene.instantiate()
	
	if pickup is WeaponPickup:
		pickup.weapon_scene = available_objects[idx]
		if idx < available_sprites.size():
			pickup.weapon_sprite = available_sprites[idx]
		pickup.auto_pickup = auto_pickup
	
	_get_pickup_parent().add_child(pickup)
	pickup.global_position = marker.global_position
	_active_pickups[marker] = pickup
	
	# Libère le slot
	pickup.tree_exited.connect(func():
		if _active_pickups.get(marker) == pickup:
			_active_pickups.erase(marker)
	)
