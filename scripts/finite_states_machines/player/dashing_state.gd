class_name DashingState extends State

@onready var dash_stream_player: AudioStreamPlayer = $"../../DashStreamPlayer"

const DASH_SPEED: float = 300.0
const DASH_TIME: float = 0.12
const DASH_RELOAD_COST: float = 0.8

var dash_dir: Vector2 = Vector2.ZERO


func enter() -> void:
	# Activer le cooldown dans le player
	player.dash_reload_timer = DASH_RELOAD_COST
	player.dash_timer = DASH_TIME
	
	dash_stream_player.play()
	
	# Déterminer la direction du dash
	var movement_vector := player.get_movement_vector()
	dash_dir = movement_vector
	if dash_dir.length_squared() == 0:
		# Si pas de mouvement, dash dans la direction de visée
		if player.input_controller:
			dash_dir = player.input_controller.get_effective_aim(player.aim_root)
	
	# Appliquer la vitesse de dash
	player.velocity = dash_dir * DASH_SPEED
	
	if player.has_node("AnimationPlayer"):
		player.animation_player.play("dash")


func physics_update(delta: float) -> void:
	# Utiliser le timer du player
	if player.dash_timer > 0.0:
		player.dash_timer -= delta
		player.velocity = dash_dir * DASH_SPEED
		player.move_and_slide()
	else:
		dash_end()


func dash_end():
	var movement_vector := player.get_movement_vector()
	if movement_vector.length_squared() > 0:
		get_parent().change_state("RunningState")
	else:
		get_parent().change_state("IdleState")


func exit() -> void:
	pass
