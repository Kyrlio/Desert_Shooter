extends Node2D

func _ready() -> void:
	#look_at(get_global_mouse_position())
	$Sprite2D/AnimationPlayer.play("slash")
