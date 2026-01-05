extends CanvasLayer

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	# Afficher le curseur personnalisé au démarrage
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	sprite_2d.visible = true


func _physics_process(_delta: float) -> void:
	sprite_2d.global_position = sprite_2d.get_global_mouse_position()


func _input(event: InputEvent) -> void:
	# Détecte les entrées manette (joystick ou boutons)
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		# Ignorer les mouvements infimes du joystick
		if event is InputEventJoypadMotion:
			var motion_event = event as InputEventJoypadMotion
			if abs(motion_event.axis_value) < 0.5:  # Deadzone
				return
		_hide_custom_cursor()
	
	# Détecte les entrées clavier/souris
	elif event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		_show_custom_cursor()


func _show_custom_cursor() -> void:
	sprite_2d.visible = true


func _hide_custom_cursor() -> void:
	sprite_2d.visible = false


func change_cursor(sprite: CompressedTexture2D, cursor_scale := Vector2.ONE, cursor_pos := Vector2(-10,-8)):
	sprite_2d.texture = sprite
	sprite_2d.scale = cursor_scale
	sprite_2d.offset = cursor_pos

func show_cursor(visibility: bool):
	sprite_2d.visible = visibility
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func get_actual_cursor() -> CompressedTexture2D:
	return sprite_2d.texture
