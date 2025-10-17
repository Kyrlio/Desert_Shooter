class_name StateMachine
extends Node

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	await owner.ready
	for child in get_children():
		if child is State:
			child.player = owner
			states[child.name] = child
	
	# Activer le premier état
	if get_child_count() > 0:
		change_state(get_child(0).name)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func change_state(state_name: String) -> void:
	if current_state:
		current_state.exit()
	
	current_state = states.get(state_name)
	
	if current_state:
		current_state.enter()
