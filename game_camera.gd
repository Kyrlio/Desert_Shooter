@icon("res://assets/icons/icon_camera_grid.png")
class_name GameCamera
extends Camera2D

const NOISE_GROWTH: float = 750
const SHAKE_DECAY_RATE: float = 10

@export var noise_texture: FastNoiseLite
@export var shake_strength: float
@export var enable_auto_zoom: bool = true
@export var max_zoom: float = 2.3 # Most zoomed-in (shows less world)
@export var min_zoom: float = 2.0 # Most zoomed-out (shows more world)

static var instance: GameCamera

var noise_offset_x: float
var noise_offset_y: float

var current_shake_percentage: float

# Cache the initial position so camera remains fixed there (unless moved manually in editor)
var _fixed_center: Vector2


func _ready() -> void:
	instance = self
	_fixed_center = global_position

func _physics_process(delta: float) -> void:
	if enable_auto_zoom:
		_refresh_camera() 
	
	if current_shake_percentage == 0:
		return
	
	noise_offset_x += NOISE_GROWTH * delta
	noise_offset_y += NOISE_GROWTH * delta
	
	var offset_sample_x := noise_texture.get_noise_2d(noise_offset_x, 0)
	var offset_sample_y := noise_texture.get_noise_2d(0, noise_offset_y)
	
	offset = Vector2(offset_sample_x, offset_sample_y) * shake_strength * current_shake_percentage * current_shake_percentage
	
	current_shake_percentage = max(current_shake_percentage - (SHAKE_DECAY_RATE * delta), 0)


static func shake(shake_percent: float):
	instance.current_shake_percentage = clamp(shake_percent, 0, 1)


func _refresh_camera():
	global_position = _calculate_position()
	
	zoom = _calculate_zoom()


func _calculate_position():
	var players = get_tree().get_nodes_in_group("player")
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
	var players = get_tree().get_nodes_in_group("player")
	
	for player in players:
		for control_player in players:
			var distance = player.global_position.distance_to(control_player.global_position)
			
			if distance > max_distance:
				max_distance = distance
		
	return max_distance
