class_name WeaponPickup
extends Area2D

## Arme ramassable dans le monde du jeu
## Permet au joueur de changer son arme actuelle

@export var weapon_scene: PackedScene  # La scène de l'arme à donner
@export var weapon_name: String = "Weapon"  # Nom affiché
@export var auto_pickup: bool = true  # Ramassage automatique ou manuel ?
@export var weapon_sprite: CompressedTexture2D

@onready var sprite: Sprite2D = $Sprite2D  # Optionnel: sprite de l'arme au sol
@onready var label: Label = $Label  # Optionnel: label avec le nom

var _player_nearby: Player = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	sprite.texture = weapon_sprite
	
	if label:
		label.text = weapon_name


func _process(_delta: float) -> void:
	# Si ramassage manuel, vérifier l'input
	if not auto_pickup and _player_nearby and Input.is_action_just_pressed("player0_interact"):
		_pickup_weapon()


func _on_body_entered(body: Node2D) -> void:
	print("yers")
	if body is Player:
		print("hello")
		_player_nearby = body
		
		# Afficher une indication visuelle (optionnel)
		if label:
			label.visible = true
		
		# Ramassage automatique si activé
		if auto_pickup:
			_pickup_weapon()


func _on_body_exited(body: Node2D) -> void:
	print("AAALLOOO")
	if body is Player and body == _player_nearby:
		_player_nearby = null
		
		if label:
			label.visible = false


func _pickup_weapon() -> void:
	if _player_nearby == null or weapon_scene == null:
		return
	
	print("💎 %s ramasse : %s" % [_player_nearby.name, weapon_name])
	
	# Donner l'arme au joueur
	_player_nearby.change_weapon(weapon_scene)
	
	# Détruire le pickup (ou le désactiver temporairement)
	queue_free()
	
	# Alternative: cacher et réapparaître plus tard
	# visible = false
	# monitoring = false
	# await get_tree().create_timer(30.0).timeout
	# visible = true
	# monitoring = true
