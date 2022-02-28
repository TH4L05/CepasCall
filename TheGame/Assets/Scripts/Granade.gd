extends RigidBody

export (PackedScene) var particle
var speed = 150
var can_throw :bool
var exploded :bool

func _physics_process(delta):
	if not exploded:
		if can_throw:
			apply_impulse(get_global_transform().basis.z , global_transform.basis.z * -speed  * delta)
	else:
		self.linear_damp = 100
		self.angular_damp = 100
		self.gravity_scale = 128
 
func throw():
	set_as_toplevel(true)
	can_throw = true

func explode():
	if not exploded:
		$BlastRadius/CollisionShape.disabled = false
		$AnimationPlayer.play("anim_explode")
		var new_particle = particle.instance()
		get_tree().get_root().add_child(new_particle)
		new_particle.global_transform.origin = self.global_transform.origin
		exploded = true

func _on_Grenade_body_entered(_body):
	explode()

func _on_BlastRadius_area_entered(_area):
	pass
