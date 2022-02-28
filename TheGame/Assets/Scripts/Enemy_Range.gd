extends KinematicBody

export var dummy_mode :bool
export var health :float = 100
export var speed :float = 2
#export var attack_frequence :float = 0.20
export var damage_from_player :float = 30
export var damage_from_grenade = 80
var move :Vector3
var player = null
var start_attack :bool
var can_attack :bool
var dead :bool
var animation_state
var gravity = 15

export (PackedScene) var flower
export (PackedScene) var bullet
export (PackedScene) var pickup
export (PackedScene) var get_hit_fx

signal Enemy_Killed
signal Player_is_detected

enum { MOVE_TO_PLAYER, STOP, STOP_AND_ATTACK}
var state = STOP

func _ready():
	animation_state = $AT.get("parameters/playback")

func _physics_process(_delta):
	if not dummy_mode and not dead:
		play_animations()
		play_audio()
		match state:
			STOP:
				move = Vector3(0, -gravity, 0)
			MOVE_TO_PLAYER:
				look_at_player()
				follow_player()
			STOP_AND_ATTACK:
				move = Vector3(0, -gravity, 0)
				look_at_player()

func follow_player():
	#state = MOVE_TO_PLAYER
	var facing = -global_transform.basis.z
	move = facing * speed
	move.y -= gravity
	move_and_slide(move,Vector3.UP)

func look_at_player():
	var player_position = player.global_transform.origin
	look_at(player_position, Vector3.UP)

#================================================================

func start_attacking():
	if not start_attack:
		start_attack = true
		$Player_Detect_Area/CollisionShape.disabled = true
		$Timer_Alert.start()
		if player == null:
			player = get_node("/root/TheWorld/Player")
		var player_position = player.global_transform.origin
		look_at(player_position, Vector3.UP)
		animation_state.travel("Alert")
		$FX/fx_exclamation/AnimationPlayer.play("alert")
		emit_signal("Player_is_detected")

func _on_Timer_Alert_timeout():
	$Timer_Attack_Freq.start()
	state = MOVE_TO_PLAYER
	follow_player()

func reset_status():
	state = STOP
	animation_state.travel("Idle")
	player = null
	start_attack = false
	$Timer_Hit.stop()
	$Timer_Attack_Freq.stop()
	$Timer_shot_anim.stop()
	$Player_Detect_Area/CollisionShape.disabled = false

#================================================================

func play_animations():
	if not can_attack and not dead:
		if not move == Vector3(0, -gravity, 0):
			animation_state.travel("Walk")
		else:
			animation_state.travel("Idle")

func play_audio():
	if not move == Vector3(0, -gravity, 0):
		if is_on_floor(): 
			if !$Audio/Audio_Walk.is_playing():
				$Audio/Audio_Walk.play()

#================================================================

func update_health(damage):
	if not dead:
		if not start_attack:
			start_attacking()
		health -= damage
		state = STOP
		$Audio/Audio_Get_Hit.play()
		$Audio/Audio_Walk.stop()
		$Healthbar.update(health)
		if health >0:
			show_get_hit_fx()
			print("ENEMY RANGE - take damage")
			animation_state.travel("Get_hit")
			$Timer_Hit.start()
		else:
			no_health_left()

func no_health_left():
	print("ENEMY RANGE - take damage")
	dead = true
	emit_signal("Enemy_Killed")
	$Timer_Hit.stop()
	$Timer_Attack_Freq.stop()
	$AT.active = false
	$AnimationPlayer.play("anim_die")

func show_get_hit_fx():
	var get_hit_fx_instance = get_hit_fx.instance()
	add_child(get_hit_fx_instance)
	get_hit_fx_instance.global_transform.origin  = global_transform.origin

func _on_TimerHit_timeout():
	state = MOVE_TO_PLAYER

func spawn_flower_or_pick_up_flower_on_death():
	var position = $Position_Spawn_Plant.global_transform
	var number = randf()
	if number < 0.40 :
		var new_pickup = pickup.instance()
		get_tree().get_root().add_child(new_pickup)
		new_pickup.global_transform = position
	else:
		var flower_instance = flower.instance()
		get_tree().get_root().add_child(flower_instance)
		flower_instance.global_transform = position

#================================================================

func _on_Timer_Attack_Freq_timeout():
	if not dead:
		animation_state.travel("Attack")
		$Timer_shot_anim.start()
		can_attack = true

func _on_Timer_shot_anim_timeout():
	$Audio/AudioShoot.play()
	spawn_bullet()

func spawn_bullet():
	var new_bullet = bullet.instance()
	new_bullet.global_transform = $Position_Shoot.global_transform
	get_node("/root/Objects/Bullet_Enemy").add_child(new_bullet)
	can_attack = false
	$Timer_Attack_Freq.start()

#================================================================

func _on_Player_Detect_Area_body_entered(body):
	if body.is_in_group("Player"):
		start_attacking()

func _on_Hit_Area_area_entered(area):
	if area.is_in_group("Grenade"):
		update_health(damage_from_grenade)
	if area.is_in_group("Player_Bullet"):
		update_health(damage_from_player)


#func _on_Attack_Range_Area_body_entered(body):
	#if body.is_in_group("Player"):
		#state = STOP_AND_ATTACK
		#$Timer_Attack_Freq.start()


#func _on_Attack_Range_Area_body_exited(body):
	#if body.is_in_group("Player"):
		#state = MOVE_TO_PLAYER
		#$Timer_Attack_Freq.stop()
