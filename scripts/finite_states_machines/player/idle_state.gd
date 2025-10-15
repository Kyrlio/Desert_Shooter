class_name IdleState extends State

func enter() -> void:
	if player.has_node("AnimationPlayer"):
		player.animation_player.play("RESET")

func physics_update(_delta: float) -> void:
	# If player moves
	if player.movement_vector.length_squared() > 0.01:
		get_parent().change_state("RunningState")
	
	# ✅ Vérifier input de dash
	if Input.is_action_just_pressed("player0_dash") and player.dash_reload_timer <= 0.0:
		get_parent().change_state("DashingState")
		return
	
	# Deceleration
	var target_velocity = player.movement_vector * player.get_movement_speed()
	player.velocity = player.velocity.lerp(target_velocity, 1 - exp(-25 * _delta))
	
	player.move_and_slide()
