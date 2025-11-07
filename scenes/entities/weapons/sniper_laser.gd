extends Node2D

@export var laser_max_distance: float = 5000.0
@onready var _laser_line: Line2D = $RayCast2D/Line2D
@onready var _laser_ray: RayCast2D = $RayCast2D

func _ready() -> void:
	if is_instance_valid(_laser_ray):
		_laser_ray.enabled = true
		_laser_ray.target_position = Vector2(laser_max_distance, 0)
		_laser_ray.exclude_parent = true  # ne pas toucher le porteur
		# Facultatif: config mask en code si vous connaissez les couches:
		# _laser_ray.collision_mask = 0
		# _laser_ray.set_collision_mask_value(1, true) # ex: Monde
		# _laser_ray.set_collision_mask_value(2, true) # ex: Ennemi
		# _laser_ray.set_collision_mask_value(3, true) # ex: Joueur

func _physics_process(_delta: float) -> void:
	_update_laser()

func _update_laser() -> void:
	if not is_instance_valid(_laser_line) or not is_instance_valid(_laser_ray):
		return
	var end_local := Vector2(laser_max_distance, 0)
	if _laser_ray.is_colliding():
		end_local = _laser_line.to_local(_laser_ray.get_collision_point())
	# En Godot 4, PackedVector2Array prend un tableau en paramètre
	_laser_line.points = PackedVector2Array([Vector2.ZERO, end_local])
	# Montrez/masquez selon votre logique (ex: viser). Ici toujours visible:
	_laser_line.visible = true
