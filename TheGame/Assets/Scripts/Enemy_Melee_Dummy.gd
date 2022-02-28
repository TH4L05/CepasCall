extends KinematicBody

export var dummy_mode :bool
export var health :float = 100
export var speed :float = 5
export var attack_frequence :float = 0.30
export var damage_from_player = 30
export var damage_from_grenade = 80
var move :Vector3
var player = null
var start_attack :bool
var can_attack :bool
var dead :bool
var animation_state
var gravity = 15

export (PackedScene) var flower
export (PackedScene) var pickup
export (PackedScene) var get_hit_fx

signal Dummy_Killed

enum { MOVE_TO_PLAYER, STOP}
var state = STOP

func _ready():
	animation_state = $anim_enemy_melee_dummy/AnimationTree.get("parameters/playback")

func update_health(damage):
	#if not start_attack:
		#start_attacking()
	print("An Enemy take damage")
	health -= damage
	state = STOP
	can_attack = false
	$Healthbar.update(health)
	var get_hit_fx_instance = get_hit_fx.instance()
	add_child(get_hit_fx_instance)
	get_hit_fx_instance.global_transform.origin = global_transform.origin
	if health >0:
		pass
	else:
		dead = true
		$anim_enemy_melee_dummy/AnimationTree.active = false
		emit_signal("Dummy_Killed")
		$AnimationPlayer.play("anim_die")

func spawn_flower_or_pick_up_flower_on_death():
	var number = randi() %100
	if number < 40 :
		var new_pickup = pickup.instance()
		get_parent().add_child(new_pickup)
		new_pickup.global_transform.origin = $Position_Spawn_Plant.global_transform.origin
	else:
		var flower_instance = flower.instance()
		get_tree().get_root().add_child(flower_instance)
		flower_instance.global_transform.origin = $Position_Spawn_Plant.global_transform.origin

func _on_Hit_Area_area_entered(area):
	if area.is_in_group("Grenade"):
		update_health(damage_from_grenade)
	if area.is_in_group("Player_Bullet"):
		update_health(damage_from_player)
