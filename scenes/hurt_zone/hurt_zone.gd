extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var particles: GPUParticles2D = $GPUParticles2D

var current_radius: float = 500.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not GameManager.activate_zone:
		return
	
	if current_radius > 125.0:
		current_radius -= 102.5 * delta
	
	collision_shape.shape.radius = current_radius
	
	var mat = particles.process_material as ParticleProcessMaterial
	mat.emission_ring_inner_radius = current_radius
