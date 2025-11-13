@icon("res://assets/icons/icon_camera_grid.png")
class_name GameCamera
extends Camera2D

const NOISE_GROWTH: float = 750
const SHAKE_DECAY_RATE: float = 10

@export_category("Camera Shake")
@export var noise_texture: FastNoiseLite
@export var shake_strength: float

@export_category("Camera Smoothing")
@export var enable_position_smoothing: bool = true
@export_range(1, 10) var smoothing_speed: int = 8

@export_category("Camera Auto Zoom")
@export var enable_auto_zoom: bool = true
@export var max_zoom: float = 2.3 # Most zoomed-in (shows less world)
@export var min_zoom: float = 2.0 # Most zoomed-out (shows more world)

@export_category("Camera Mouse Look")
@export var enable_mouse_look: bool = true
@export_range(0.0, 1.0, 0.05) var cursor_influence: float = 0.15 # 0..1 part de la distance vers la souris
@export var cursor_max_offset: float = 220.0 # décalage max (unités monde)

static var instance: GameCamera

var noise_offset_x: float
var noise_offset_y: float
var players := []
var current_shake_percentage: float
var camera_position: Vector2


func _ready() -> void:
	instance = self

func _physics_process(delta: float) -> void:
	players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	
	var target := _calculate_position()
	
	if enable_mouse_look and players.size() == 1:
		target += _calculate_mouse_offset(target)
	
	if enable_position_smoothing:
		var weight:float = 1.0 - exp(-smoothing_speed * delta)
		global_position = global_position.lerp(target, weight)
	else:
		global_position = target
	
	if enable_auto_zoom:
		zoom = _calculate_zoom() 
	
	_apply_shake(delta)


static func shake(shake_percent: float):
	instance.current_shake_percentage = clamp(shake_percent, 0, 1)


func _apply_shake(delta: float):
	if current_shake_percentage == 0:
		return
	
	noise_offset_x += NOISE_GROWTH * delta
	noise_offset_y += NOISE_GROWTH * delta
	
	var offset_sample_x := noise_texture.get_noise_2d(noise_offset_x, 0)
	var offset_sample_y := noise_texture.get_noise_2d(0, noise_offset_y)
	
	offset = Vector2(offset_sample_x, offset_sample_y) * shake_strength * current_shake_percentage * current_shake_percentage
	
	current_shake_percentage = max(current_shake_percentage - (SHAKE_DECAY_RATE * delta), 0)


func _refresh_camera():
	global_position = _calculate_position()
	zoom = _calculate_zoom()


func _calculate_position() -> Vector2:
	var sum_position: Vector2 = Vector2.ZERO
	
	for player in players:
		sum_position += player.global_position
	
	return sum_position / players.size()


func _calculate_zoom():
	var max_distance = _get_max_player_distance()
	var zoom_level = clamp(max_zoom - (max_distance / 150), min_zoom, max_zoom)
	return Vector2(zoom_level, zoom_level)


func _get_max_player_distance():
	var max_distance := 0.0
	
	for player in players:
		for control_player in players:
			var distance = player.global_position.distance_to(control_player.global_position)
			
			if distance > max_distance:
				max_distance = distance
		
	return max_distance


func _calculate_mouse_offset(target: Vector2) -> Vector2:
	var mouse_world := get_global_mouse_position()
	var to_mouse := mouse_world - target
	if to_mouse == Vector2.ZERO:
		return Vector2.ZERO
	
	var cam_offset := to_mouse * cursor_influence
	# Limiter la magnitude pour garder un effet subtil
	if cam_offset.length() > cursor_max_offset:
		cam_offset = cam_offset.normalized() * cursor_max_offset
	
	# Rendre l'effet plus constant visuellement malgré le zoom
	if zoom.x != 0.0:
		cam_offset /= zoom.x
	
	return cam_offset
