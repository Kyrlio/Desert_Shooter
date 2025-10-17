class_name Weapon
extends Node2D

@export var display_name: String = "Weapon"
@export var damage: int = 5
@export var fire_rate: float = 0.2
@export_range(0.0, 45.0, 0.1, "degrees") var spread: float = 0.0  ## Dispersion des balles en degrés (0 = précis, 45 = très dispersé)
@export var number_bullets: int = 1
@export var use_normal_distribution: bool = false  ## Si true, utilise une distribution normale (gaussienne) pour le spread - Recommandé pour shotgun
@export var barrel_position: Node2D
@export var animation_player: AnimationPlayer

var bullet_scene: PackedScene = preload("uid://ccqop2oca0tcc")
var muzzle_flash_scene: PackedScene = preload("uid://we7xx2omqegd")

var weapon_owner: Player
var _cooldown := 0.0

func _process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta

func can_fire() -> bool:
	return _cooldown <= 0.0 and weapon_owner

func fire(direction: Vector2) -> void:
	if not can_fire():
		return
	
	for i in number_bullets:
		# Appliquer la dispersion (spread)
		var final_direction = _apply_spread(direction)
		
		# Créer et configurer la balle
		var bullet = bullet_scene.instantiate() as Bullet
		bullet.global_position = barrel_position.global_position
		bullet.set_damage(damage)  # Transmettre les dégâts de l'arme à la balle
		bullet.start(final_direction)
		
		weapon_owner.get_parent().add_child(bullet, true)
	_cooldown = fire_rate
	_play_fire_effects()
	

func _play_fire_effects() -> void:
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("fire")
	
	var muzzle_flash: Node2D = muzzle_flash_scene.instantiate()
	muzzle_flash.global_position = barrel_position.global_position
	muzzle_flash.rotation = barrel_position.global_rotation
	weapon_owner.get_parent().add_child(muzzle_flash)
	
	GameCamera.shake(1)


## Applique la dispersion à la direction de tir
## @param direction: Direction de base du tir
## @return: Direction avec dispersion aléatoire appliquée
func _apply_spread(direction: Vector2) -> Vector2:
	if spread <= 0.0:
		return direction.normalized()
	
	# Convertir la dispersion en radians
	var spread_radians = deg_to_rad(spread)
	
	# Générer un angle aléatoire selon le type de distribution
	var random_angle: float
	if use_normal_distribution:
		# Distribution normale (gaussienne) - la plupart des balles au centre
		random_angle = _randfn(0.0, spread_radians / 3.0)
		# Limiter à ±spread pour éviter les valeurs extrêmes
		random_angle = clamp(random_angle, -spread_radians, spread_radians)
	else:
		# Distribution uniforme - toutes les directions équiprobables
		random_angle = randf_range(-spread_radians, spread_radians)
	
	# Obtenir l'angle de la direction de base
	var base_angle = direction.angle()
	
	# Ajouter la dispersion aléatoire
	var final_angle = base_angle + random_angle
	
	# Créer la nouvelle direction
	return Vector2(cos(final_angle), sin(final_angle))


## Génère un nombre aléatoire avec distribution normale (Box-Muller)
## @param mean: Moyenne (centre de la distribution)
## @param std_dev: Écart-type (dispersion)
## @return: Nombre aléatoire suivant une distribution normale
func _randfn(mean: float, std_dev: float) -> float:
	# Algorithme Box-Muller pour générer une distribution normale
	var u1 = randf()
	var u2 = randf()
	var z0 = sqrt(-2.0 * log(u1)) * cos(TAU * u2)
	return mean + z0 * std_dev


# Appelé quand l'arme est équipée
func on_equipped(new_owner: Player) -> void:
	weapon_owner = new_owner
	print("✅ %s équipé" % display_name)

# Appelé quand l'arme est déséquipée
func on_unequipped() -> void:
	print("❌ %s déséquipé" % display_name)
	weapon_owner = null
