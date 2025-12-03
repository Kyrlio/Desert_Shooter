class_name Enemy
extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

@export var damage: int = 5

func _ready() -> void:
	health_component.died.connect(_on_died)
	hurtbox_component.knockbacked.connect(_on_knockbacked)
	hitbox_component.damage = damage


func _physics_process(delta: float) -> void:
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
	else:
		velocity = velocity.lerp(knockback, 1 - exp(-25 * delta))
	
	move_and_slide()


func _on_knockbacked(direction: Vector2, force: float, knockback_duration: float):
	knockback = direction * force
	knockback_timer = knockback_duration
	

func _on_died():
	queue_free.call_deferred()
