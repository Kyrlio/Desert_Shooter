@icon("res://assets/icons/icon_resource.png")
class_name PlayerShield
extends Node2D

signal shield_depleted
signal shield_ready

@export var max_hits: int = 4
@export_range(0.5, 10.0, 0.1) var cooldown_time: float = 2.5
@export_range(30.0, 120.0, 1.0) var base_arc_angle_degrees: float = 100.0
@export_range(16.0, 64.0, 1.0) var arc_radius: float = 32.0
@export_range(0.0, 1.0, 0.05) var minimum_arc_ratio: float = 0.25
@export var offset_distance: float = 18.0
@export_range(6, 32, 1) var arc_segments: int = 16
@export_range(0.0, 5.0, 0.1) var recharge_delay: float = 1.0
@export_range(0.1, 10.0, 0.1) var recharge_rate: float = 1.0

@onready var shield_area: Area2D = $ShieldArea
@onready var collision_polygon: CollisionPolygon2D = $"ShieldArea/CollisionPolygon2D"
@onready var shield_arc: Line2D = $ShieldArc
@onready var cooldown_timer: Timer = $CooldownTimer

var remaining_hits: float
var _is_active: bool = false
var _in_cooldown: bool = false
var _regen_cooldown: float = 0.0


func _ready() -> void:
	remaining_hits = max_hits
	shield_area.area_entered.connect(_on_area_entered)
	cooldown_timer.timeout.connect(_on_cooldown_finished)
	cooldown_timer.one_shot = true
	shield_area.monitoring = false
	shield_area.monitorable = false
	set_process(true)
	hide()
	_update_shield_shape()


func activate() -> bool:
	if _in_cooldown:
		return false
	if _is_active:
		return true
	_is_active = true
	shield_area.monitoring = true
	shield_area.monitorable = true
	shield_arc.visible = true
	show()
	return true


func deactivate() -> void:
	if not _is_active:
		return
	_is_active = false
	shield_area.set_deferred("monitoring", false)
	shield_area.set_deferred("monitorable", false)
	shield_arc.visible = false
	hide()


func is_active() -> bool:
	return _is_active


func is_on_cooldown() -> bool:
	return _in_cooldown


func update_orientation(direction: Vector2) -> void:
	if direction.length_squared() < 0.0001:
		return
	rotation = direction.angle()
	position = direction.normalized() * offset_distance


func _on_area_entered(other_area: Area2D) -> void:
	if not _is_active:
		return
	if other_area is HitboxComponent:
		_handle_block_hit(other_area)


func _handle_block_hit(hitbox: HitboxComponent) -> void:
	var parent := hitbox.get_parent()
	if parent is Bullet:
		parent.register_collision()
	else:
		hitbox.is_hit_handled = true

	var shield_loss: float = float(max(hitbox.damage, 1))
	remaining_hits = max(remaining_hits - shield_loss, 0.0)
	_regen_cooldown = recharge_delay
	_update_shield_shape()

	if remaining_hits <= 0:
		_deplete_shield()


func _deplete_shield() -> void:
	deactivate()
	_in_cooldown = true
	remaining_hits = 0.0
	cooldown_timer.start(cooldown_time)
	shield_depleted.emit()


func _on_cooldown_finished() -> void:
	remaining_hits = max_hits
	_in_cooldown = false
	_regen_cooldown = 0.0
	_update_shield_shape()
	shield_ready.emit()


func _process(delta: float) -> void:
	if _in_cooldown:
		return
	if _regen_cooldown > 0.0:
		_regen_cooldown = max(_regen_cooldown - delta, 0.0)
		return
	if _is_active:
		return
	if remaining_hits >= max_hits:
		return
	remaining_hits = min(float(max_hits), remaining_hits + recharge_rate * delta)
	_update_shield_shape()


func _update_shield_shape() -> void:
	if max_hits <= 0:
		return
	if not is_instance_valid(collision_polygon) or not is_instance_valid(shield_arc):
		return
	var ratio := float(remaining_hits) / float(max_hits)
	ratio = clamp(ratio, 0.0, 1.0)
	var visual_ratio: float = 0.0
	if remaining_hits > 0:
		visual_ratio = max(ratio, minimum_arc_ratio)
	var base_angle: float = deg_to_rad(base_arc_angle_degrees)
	var angle: float = base_angle * visual_ratio
	var radius: float = arc_radius * (0.7 + 0.3 * ratio)

	if visual_ratio <= 0.0 or angle <= 0.0 or radius <= 0.0:
		shield_arc.set_deferred("points", PackedVector2Array())
		collision_polygon.set_deferred("polygon", PackedVector2Array())
		return

	var arc_points := _build_arc_points(angle, radius, arc_segments)
	shield_arc.set_deferred("points", arc_points)

	var polygon_points := PackedVector2Array()
	polygon_points.append(Vector2.ZERO)
	for point in arc_points:
		polygon_points.append(point)
	collision_polygon.set_deferred("polygon", polygon_points)


func _build_arc_points(angle: float, radius: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	if segments <= 0 or angle <= 0.0 or radius <= 0.0:
		return points
	var half_angle := angle * 0.5
	var step := angle / float(segments)
	for i in range(segments + 1):
		var current_angle := -half_angle + step * float(i)
		var unit := Vector2.RIGHT.rotated(current_angle)
		points.append(unit * radius)
	return points
