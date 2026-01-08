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
@export_range(0.1, 5.0, 0.1) var drain_rate: float = 1.0  ## Shield drain per second while active
@export_range(0.1, 5.0, 0.1) var recharge_rate: float = 0.5  ## Shield regen per second while inactive
@export_range(0.0, 40.0, 1.0) var reflection_angle_variance: float = 10.0
@export_node_path("Node2D") var center_marker_path: NodePath
@export var center_offset: Vector2 = Vector2.ZERO

const COLOR_NORMAL := Color(1, 1, 1.0)
const COLOR_REGEN := Color(0.3, 1.0, 0.5)

@onready var shield_area: Area2D = $ShieldArea
@onready var collision_polygon: CollisionPolygon2D = $"ShieldArea/CollisionPolygon2D"
@onready var shield_arc: Line2D = $ShieldArc
@onready var shield_outline: Line2D = $ShieldOutline
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var center_marker: Node2D = get_node_or_null(center_marker_path) as Node2D
@onready var impact_stream_player: AudioStreamPlayer = $ImpactStreamPlayer

var remaining_hits: float
var _is_active: bool = false
var _in_cooldown: bool = false
var _regen_tween: Tween = null
var _is_regenerating: bool = false


func _ready() -> void:
	remaining_hits = max_hits
	shield_area.area_entered.connect(_on_area_entered)
	cooldown_timer.timeout.connect(_on_cooldown_finished)
	cooldown_timer.one_shot = true
	shield_area.monitoring = false
	shield_area.monitorable = false
	set_process(true)
	hide()
	shield_arc.default_color = COLOR_NORMAL
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
	shield_outline.visible = true
	show()
	return true


func deactivate() -> void:
	if not _is_active:
		return
	_is_active = false
	shield_area.set_deferred("monitoring", false)
	shield_area.set_deferred("monitorable", false)
	shield_arc.visible = false
	shield_outline.visible = false
	hide()


func is_active() -> bool:
	return _is_active


func is_on_cooldown() -> bool:
	return _in_cooldown


func update_orientation(direction: Vector2) -> void:
	if direction.length_squared() < 0.0001:
		return
	rotation = direction.angle()
	var base_global := Vector2.ZERO
	if is_instance_valid(center_marker):
		base_global = center_marker.global_position
	else:
		var parent2d := get_parent() as Node2D
		if parent2d:
			base_global = parent2d.to_global(center_offset)
		else:
			base_global = global_position
	global_position = base_global + direction.normalized() * offset_distance


func _on_area_entered(other_area: Area2D) -> void:
	if not _is_active:
		return
	if other_area is HitboxComponent:
		impact_stream_player.play()
		_handle_block_hit(other_area)


func _handle_block_hit(hitbox: HitboxComponent) -> void:
	if hitbox.owner_player_index != -1 and get_parent() is Player:
		var shield_owner: Player = get_parent()
		if shield_owner.player_index == hitbox.owner_player_index:
			return
	var parent := hitbox.get_parent()
	if parent is Bullet:
		_reflect_bullet(parent)
	else:
		hitbox.is_hit_handled = true

	var shield_loss: float = float(max(hitbox.damage, 1))
	remaining_hits = max(remaining_hits - shield_loss, 0.0)
	_update_shield_shape()

	if remaining_hits <= 0:
		_deplete_shield()


func _reflect_bullet(bullet: Bullet) -> void:
	# Reverse the bullet direction (bounce back)
	var reflected_dir := -bullet.direction
	
	# Add angle variance
	if reflection_angle_variance > 0.0:
		var variance_rad := deg_to_rad(randf_range(-reflection_angle_variance, reflection_angle_variance))
		reflected_dir = reflected_dir.rotated(variance_rad)
	
	bullet.direction = reflected_dir
	bullet.rotation = reflected_dir.angle()
	
	# Transfer ownership to shield owner
	var shield_owner := get_parent() as Player
	if shield_owner:
		bullet.owner_player_index = shield_owner.player_index
		if bullet.hitbox_component:
			bullet.hitbox_component.owner_player_index = shield_owner.player_index
	
	# Offset bullet position to avoid re-triggering shield
	bullet.global_position += reflected_dir.normalized() * 8.0


func _deplete_shield() -> void:
	deactivate()
	_in_cooldown = true
	remaining_hits = 0.0
	_stop_regen_visual()
	cooldown_timer.start(cooldown_time)
	shield_depleted.emit()


func _on_cooldown_finished() -> void:
	remaining_hits = max_hits
	_in_cooldown = false
	_stop_regen_visual()
	_update_shield_shape()
	shield_ready.emit()


func _physics_process(delta: float) -> void:
	# No processing during cooldown
	if _in_cooldown:
		if _is_regenerating:
			_stop_regen_visual()
		return
	
	# ACTIVE: Drain shield continuously (Smash Bros style)
	if _is_active:
		if _is_regenerating:
			_stop_regen_visual()
		remaining_hits = max(remaining_hits - drain_rate * delta, 0.0)
		_update_shield_shape()
		if remaining_hits <= 0:
			_deplete_shield()
		return
	
	# INACTIVE: Regenerate shield slowly
	if remaining_hits >= max_hits:
		if _is_regenerating:
			_stop_regen_visual()
		return
	
	# Start regen visual if not already running
	if not _is_regenerating:
		_start_regen_visual()
	
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
		if is_instance_valid(shield_outline):
			shield_outline.set_deferred("points", PackedVector2Array())
		collision_polygon.set_deferred("polygon", PackedVector2Array())
		return

	var arc_points := _build_arc_points(angle, radius, arc_segments)
	shield_arc.set_deferred("points", arc_points)
	if is_instance_valid(shield_outline):
		shield_outline.set_deferred("points", arc_points)

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


func _start_regen_visual() -> void:
	if _is_regenerating:
		return
	_is_regenerating = true
	if _regen_tween and _regen_tween.is_valid():
		_regen_tween.kill()
	_regen_tween = create_tween().set_loops()
	_regen_tween.tween_property(shield_arc, "default_color", COLOR_REGEN, 0.3)
	_regen_tween.tween_property(shield_arc, "default_color", COLOR_NORMAL, 0.3)


func _stop_regen_visual() -> void:
	if not _is_regenerating:
		return
	_is_regenerating = false
	if _regen_tween and _regen_tween.is_valid():
		_regen_tween.kill()
	_regen_tween = null
	shield_arc.default_color = COLOR_NORMAL
