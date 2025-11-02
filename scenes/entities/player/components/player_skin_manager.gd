class_name PlayerSkinManager
extends Node

## Gère l'application et le changement de skins pour un joueur

signal skin_changed(skin: PlayerSkin)

@export var sprite: Sprite2D
@export var spritesheet: Texture2D
@export var available_skins: Array[PlayerSkin] = []

var current_index: int = 0


func _ready() -> void:
	if available_skins.is_empty():
		push_warning("PlayerSkinManager: No skins available")
		return
	apply_skin(current_index)


func apply_skin(skin_index: int) -> void:
	if skin_index < 0 or skin_index >= available_skins.size():
		push_error("Invalid skin index: %d" % skin_index)
		return
	
	if not spritesheet:
		push_error("No character spritesheet assigned!")
		return
	
	if not sprite:
		push_error("No sprite assigned!")
		return
	
	current_index = skin_index
	var skin := available_skins[skin_index]
	
	# Créer un AtlasTexture pour extraire la bonne région
	var atlas := AtlasTexture.new()
	atlas.atlas = spritesheet
	atlas.region = skin.get_idle_region()
	
	# Appliquer au sprite
	sprite.texture = atlas
	
	skin_changed.emit(skin)


func cycle_skin(direction: int = 1) -> void:
	if available_skins.is_empty():
		return
	var new_index := wrapi(current_index + direction, 0, available_skins.size())
	apply_skin(new_index)


func set_skin_by_id(skin_id: int) -> void:
	for i in available_skins.size():
		if available_skins[i].skin_id == skin_id:
			apply_skin(i)
			return
	push_error("Skin with ID %d not found" % skin_id)


func set_skin_by_name(skin_name: String) -> void:
	for i in available_skins.size():
		if available_skins[i].skin_name == skin_name:
			apply_skin(i)
			return
	push_error("Skin '%s' not found" % skin_name)


func get_current_skin() -> PlayerSkin:
	if current_index >= 0 and current_index < available_skins.size():
		return available_skins[current_index]
	return null
