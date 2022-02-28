extends RigidBody

export var bullet_speed = 5000
export (PackedScene) var particle


func _physics_process(delta):
	add_central_force(get_global_transform().basis.z * -bullet_speed * delta)

func _on_Bullet_Player_body_entered(_body):
	queue_free()
	show_particle()

func _on_Hit_Detect_Area_body_entered(_body):
	queue_free()
	show_particle()	

func show_particle():
	var new_particle = particle.instance()
	get_tree().get_root().get_node("Objects/Particle").add_child(new_particle)
	new_particle.global_transform = self.global_transform


func _on_VisibilityNotifier_screen_exited():
	pass

func _on_VisibilityNotifier_camera_exited(_camera):
	queue_free()
