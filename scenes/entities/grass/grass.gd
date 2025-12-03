@icon("res://assets/Tiles/New Tiles/tile_0044.png")
class_name Grass
extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var bend_speed: float = 0.6
var back_speed: float = 8.0
@export var skewvalue: float = 15

@export var sprite: CompressedTexture2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	if sprite != null:
		sprite_2d.texture = sprite


func _on_body_entered(body: Node2D) -> void:
	if body is Player or Enemy:
		_bend_from(body.global_position)


func _on_area_entered(area: Area2D):
	if area is HitboxComponent:
		_bend_from(area.global_position)


func _bend_from(pos: Vector2):
	var direction = global_position.direction_to(pos)
	var skew1 = -direction.x * skewvalue
	
	var tween = create_tween()
	tween.tween_property($Sprite2D, "skew", skew1, bend_speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	var tween2 = create_tween()
	tween2.tween_property($Sprite2D, "skew", 0.0, back_speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
