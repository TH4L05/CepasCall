extends Spatial

export (PackedScene) var bullet_player
export (PackedScene) var bullet_enemy
export (PackedScene) var fx_grenade
export (PackedScene) var fx_enemy_get_hit
export (PackedScene) var fx_hit_particle


func _ready():
	var object1 = bullet_player.instance()
	get_node("O").add_child(object1)
	object1.global_transform = $O/Position3D.global_transform
	
	var object2 = bullet_enemy.instance()
	get_node("O").add_child(object2)
	object2.global_transform = $O/Position3D.global_transform
	
	var object3 = fx_grenade.instance()
	get_node("O").add_child(object3)
	object3.global_transform = $O/Position3D.global_transform
	
	var object4 = fx_enemy_get_hit.instance()
	get_node("O").add_child(object4)
	object4.global_transform = $O/Position3D.global_transform
	
	var object5 = fx_hit_particle.instance()
	get_node("O").add_child(object5)
	object5.global_transform = $O/Position3D.global_transform
	
