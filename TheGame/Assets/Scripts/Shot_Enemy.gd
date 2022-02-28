extends RigidBody

export var bullet_speed = 5000

func _physics_process(delta):
	add_central_force(get_global_transform().basis.z * -bullet_speed * delta)

func _on_Hit_Detect_Area_body_entered(_body):
	queue_free()
