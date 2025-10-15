class_name RunningState extends State

func enter() -> void:
	if player.has_node("AnimationPlayer"):
		player.animation_player.play("run")


func physics_update(_delta: float) -> void:
	# If not moving -> goto Idle
	if is_equal_approx(player.movement_vector.length_squared(), 0):
		get_parent().change_state("IdleState")
	
	# Apply movement logic
	var target_velocity = player.movement_vector * player.get_movement_speed()
	player.velocity = player.velocity.lerp(target_velocity, 1 - exp(-25 * _delta))
	
	dash()
	player.move_and_slide()


func exit() -> void:
	player.animation_player.play("RESET")

func dash():
	if Input.is_action_just_pressed("player0_dash"):
		# ✅ Vérifier que le dash est disponible
		if player.dash_reload_timer <= 0.0:
			get_parent().change_state("DashingState")
