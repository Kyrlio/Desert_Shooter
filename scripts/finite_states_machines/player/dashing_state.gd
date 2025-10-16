class_name DashingState extends State

const DASH_SPEED: float = 300.0
const DASH_TIME: float = 0.12
const DASH_RELOAD_COST: float = 0.8

var dash_dir: Vector2 = Vector2.ZERO


func enter() -> void:	
	# Activer le cooldown dans le player
	player.dash_reload_timer = DASH_RELOAD_COST
	player.dash_timer = DASH_TIME
	
	# Déterminer la direction du dash
	dash_dir = player.movement_vector
	if dash_dir.length_squared() == 0:
		# Si pas de mouvement, dash dans la direction de visée
		dash_dir = player.aim_vector
	
	# Appliquer la vitesse de dash
	player.velocity = dash_dir * DASH_SPEED
	
	if player.has_node("AnimationPlayer"):
		player.animation_player.play("dash")


func physics_update(delta: float) -> void:
	# Utiliser le timer du player
	if player.dash_timer > 0.0:
		player.dash_timer -= delta
		# Maintenir la vitesse de dash
		player.velocity = dash_dir * DASH_SPEED
		player.move_and_slide()
	else:
		# Dash terminé, sortir
		if player.movement_vector.length_squared() > 0:
			get_parent().change_state("RunningState")
		else:
			get_parent().change_state("IdleState")


func exit() -> void:
	pass
