class_name PlayerSkin
extends Resource

## Nom du skin pour identification
@export var skin_name: String = "Default"

## ID du skin (0 = ligne 0, 1 = ligne 1, etc.)
@export var skin_id: int = 0

## Retourne la région pour le sprite au repos (frame 0)
func get_idle_region() -> Rect2:
	return Rect2(0, skin_id * 24, 96, 96)

## Retourne la région pour un sprite d'animation spécifique
func get_animation_region(frame: int) -> Rect2:
	return Rect2(frame * 96, skin_id * 96, 96, 96)

## Retourne toutes les régions pour les animations
func get_all_frames() -> Array[Rect2]:
	var frames: Array[Rect2] = []
	for i in 4:  # 4 frames par personnage
		frames.append(Rect2(i * 96, skin_id * 96, 96, 96))
	return frames
