class_name FallingState extends State

@onready var weapon_root: Node2D = $"../../Visuals/WeaponRoot"
@onready var shadow: Sprite2D = $"../../Shadow"
@onready var reload_sprite: Sprite2D = $"../../ReloadSprite"
@onready var gpu_particles: GPUParticles2D = $"../../Visuals/GPUParticles2D"

func enter() -> void:
	weapon_root.visible = false
	shadow.visible = false
	reload_sprite.visible = false
	gpu_particles.visible = false
	MusicPlayer.play_fall()
	player.animation_player.play("falling")
	await player.animation_player.animation_finished
	player.is_dead = true

func physics_update(_delta: float) -> void:
	pass

func exit() -> void:
	pass
