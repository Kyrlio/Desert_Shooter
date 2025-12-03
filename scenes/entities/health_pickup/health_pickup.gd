@icon("res://assets/Interface/Tiles/Icons/SPR_Icons_11.png")
class_name HealthPickup
extends Area2D

@export var heal_amount: int = 10

@onready var sprite: Sprite2D = $Sprite2D  # Optionnel: sprite de l'arme au sol
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var pickup_stream_player: AudioStreamPlayer = $PickupStreamPlayer

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	animation_player.play("spawn")


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.heal(heal_amount)
		
		animation_player.play("despawn")
		pickup_stream_player.play()
