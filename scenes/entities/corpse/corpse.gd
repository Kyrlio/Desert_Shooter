extends RigidBody2D

@export var push_impulse: float = 200.0
@export var use_player_velocity: bool = true
@export var sprite: AtlasTexture

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	if sprite != null:
		print("yo")
		sprite_2d.texture = sprite
	contact_monitor = true
	max_contacts_reported = 4
	if has_signal("body_entered"):
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		var p := body as CharacterBody2D
		var impulse: Vector2 = Vector2.ZERO
		if use_player_velocity:
			var vel: Vector2 = p.velocity
			if vel.length() > 0.0:
				impulse = vel.normalized() * push_impulse
		if impulse == Vector2.ZERO:
			var dir: Vector2 = (global_position - p.global_position).normalized()
			impulse = dir * push_impulse
		apply_impulse(impulse)
