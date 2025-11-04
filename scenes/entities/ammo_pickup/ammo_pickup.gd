@icon("res://assets/weapons/Ammo.png")
class_name AmmoPickup
extends Area2D

@export var rifle_ammo_amount: int = 20
@export var uzi_ammo_amount: int = 40
@export var shotgun_ammo_amount: int = 6
@export var sniper_ammo_amount: int = 3

@onready var sprite: Sprite2D = $Sprite2D  # Optionnel: sprite de l'arme au sol
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	animation_player.play("spawn")


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		match body.get_current_weapon().name:
			"Rifle": body.add_ammo(rifle_ammo_amount)
			"Uzi": body.add_ammo(uzi_ammo_amount)
			"Shotgun": body.add_ammo(shotgun_ammo_amount)
			"Sniper": body.add_ammo(sniper_ammo_amount)
		
		animation_player.play("despawn")
