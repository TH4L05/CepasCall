extends KinematicBody

onready var camera = $CameraPivot/Camera
#var mouse_sensitivity = 0.1
onready var camera_pivot = $CameraPivot
#onready var gunpivot = $Position3D

var can_shoot :bool = true
var can_throw :bool = true
var g_anim :bool = true
var d_anim :bool = true
var can_dash :bool = true
var playing :bool = true
var take_damage :bool
var dead :bool
var move: Vector3
export var health :float = 600
export var health_max :float = 600
export var shot_frequence: float = 0.50
var shot_count :int = 0
export var max_speed = 4
export var speed =  1
export var dash_speed_multiply = 6
var acceleration = 0.5
var gravity = 15
export var dash_cool_time :float = 1.5
export var grenade_cool_time :float = 3.0
var new_grenade = null
export var damage_from_melee = 20.0
export var damage_from_range = 30.0
export var health_form_flower = 30.0

export (PackedScene) var bullet
export (PackedScene) var flower1
export (PackedScene) var flower2
export (PackedScene) var grass
export (PackedScene) var grenade

signal player_is_dead

func _ready():
	camera_pivot.set_as_toplevel(true)
	$HUD/PlayerHealth.max_value = health_max
	$HUD/PlayerHealth.value = health
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta):
	shoot()
	throw_grenade()
	#if Input.is_action_just_pressed("ui_cancel"):
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func cam_follows_player():
	var player_pos = global_transform.origin
	camera_pivot.global_transform.origin = player_pos

func _physics_process(_delta):
	if playing:
		cam_follows_player()
		look_at_cursor()
		calculate_movement()
		play_animations()
		play_audio()
		
#func _input(event):
	#if Input.is_action_pressed("ui_cancel"):
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#if event is InputEventMouseMotion:
		#rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		#pivot.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		#pivot.rotation.x = clamp(pivot.rotation.x, deg2rad(-90),deg2rad(90))
		#gunpivot.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		#gunpivot.rotation.x = clamp(pivot.rotation.x, deg2rad(-90),deg2rad(90))

#************************************************************************

func get_input():
	var input = Vector3(
		-int(Input.is_action_pressed("LEFT")) +int(Input.is_action_pressed("RIGHT")),
		0,
		-int(Input.is_action_pressed("UP")) +int(Input.is_action_pressed("DOWN"))
	)
	input = input.normalized()
	return input

func calculate_movement():
	var movement = get_input()
	if movement != Vector3.ZERO:
		if Input.is_action_just_pressed("RUN") and can_dash:
			dash()
		speed += acceleration
		if speed > max_speed:
			speed = max_speed
	move =  movement * speed
	move.y -= gravity
	move_and_slide_with_snap(move,Vector3.UP)

#************************************************************************

func play_animations():
	if not can_shoot:
		$AnimationTree.set("parameters/BlendGrenade/blend_amount",0.0)
		$AnimationTree.set("parameters/Blend2/blend_amount",1.0)
		$AnimationTree.set("parameters/Seekshoot1/seek_position",0)
		if not shot_count == 3:
			$AnimationTree.set("parameters/BlendShoot/blend_amount",0.0)
			$AnimationTree.set("parameters/Seekshoot2/seek_position",0)
		else:
			$AnimationTree.set("parameters/BlendShoot/blend_amount",1.0)
	elif not g_anim:
		$AnimationTree.set("parameters/Blend2/blend_amount",1.0)
		$AnimationTree.set("parameters/BlendGrenade/blend_amount",1.0)
		shot_count = 0
	elif not d_anim:
		$AnimationTree.set("parameters/Blend2/blend_amount",0.0)
		$AnimationTree.set("parameters/BlendDash/blend_amount",1.0)
	else:
		$AnimationTree.set("parameters/BlendDash/blend_amount",0.0)
		$AnimationTree.set("parameters/Blend2/blend_amount",0.0)
		shot_count = 0
		if move.z > 0.1:
			
			$AnimationTree.set("parameters/TS_Walk/scale",2.0) #back
			$AnimationTree.set("parameters/Walk/blend_position",Vector2(0, -1))
		elif move.z < -0.1:
			
			$AnimationTree.set("parameters/TS_Walk/scale",2.0) #for
			$AnimationTree.set("parameters/Walk/blend_position",Vector2(0, 1))
		elif move.x > 0.1:
			
			$AnimationTree.set("parameters/TS_Walk/scale",2.0) #left
			$AnimationTree.set("parameters/Walk/blend_position",Vector2(1, 0))
		elif move.x < -0.1:
			
			$AnimationTree.set("parameters/TS_Walk/scale",2.0) #right
			$AnimationTree.set("parameters/Walk/blend_position",Vector2(-1, 0))
		else:
			$AnimationTree.set("parameters/TS_Walk/scale",0.7) #idle
			$AnimationTree.set("parameters/Walk/blend_position",Vector2(0, 0))

func play_audio():
	if not move == Vector3(0, -gravity, 0):
		if not is_on_floor(): 
			if !$Audio/Audio_Walk.is_playing():
				$Audio/Audio_Walk.play()

#************************************************************************

func look_at_cursor():
	var player_pos = global_transform.origin
	var drop_plane = Plane(Vector3(0,1,0), player_pos.y)
	var ray_length = 10000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var cursor_pos = drop_plane.intersects_ray(from, to)
	look_at(cursor_pos, Vector3.UP)

#************************************************************************

func dash():
	can_dash = false
	d_anim = false
	$Timer_Dash_Duration.start()
	$Particles/Dash_Particle.emitting = true
	speed *= dash_speed_multiply
	max_speed *= dash_speed_multiply
	$Audio/Audio_Walk.stop()
	$Audio/Audio_Dash.play()

func _on_Timer_timeout():
	d_anim = true
	speed /= dash_speed_multiply
	max_speed /= dash_speed_multiply
	$Timer_Dash_Cooldown.start(dash_cool_time)
	$HUD.dash_cooldown(dash_cool_time)
	move = Vector3(0, -gravity, 0)

func _on_Timer_Dash_Cooldown_timeout():
	can_dash = true

#************************************************************************

func shoot():
	if playing:
		if Input.is_action_pressed("PLAYER_FIRE") and can_shoot:
			can_shoot = false
			shot_count +=1
			if shot_count == 3:
				shot_frequence *= 2
			$Timer_Shoot.start(shot_frequence)
			$Timer_Shoot_Animation.start()


func _on_Timer_Shoot_timeout():
	if shot_count == 3:
		shot_count = 0
	can_shoot = true
	shot_frequence = 0.50
	$AnimationTree.set("parameters/SeekShoot1/seek_position",0)
	$AnimationTree.set("parameters/SeekShoot2/seek_position",0)

func _on_Timer_Shoot_Animation_timeout():
	spawn_bullet()
	$Audio/Audio_Shot.play()

func spawn_bullet():
	var new_bullet = bullet.instance()
	new_bullet.global_transform = $Position_Shoot.global_transform
	get_node("/root/Objects/Bullet_Player").add_child(new_bullet)

#************************************************************************

func throw_grenade():
	if playing:
		if Input.is_action_just_pressed("GRENADE") and can_throw:
			can_throw = false
			g_anim = false
			new_grenade = grenade.instance()
			$anim_player/Armature/Skeleton/BoneAttachment/Position_Grenade2.add_child(new_grenade)
			$Audio/Audio_Summon_Grenade.play()
			$Timer_greanade_anim.start()
			start_grenade_cooldown()

func _on_Timer_greanade_anim_timeout():
		g_anim = true
		if is_instance_valid(new_grenade):
			new_grenade.global_transform = $Position_Grenade.global_transform
			new_grenade.throw()
		$AnimationTree.set("parameters/Blend2/blend_amount",0.0)
		$AnimationTree.set("parameters/BlendGrenade/blend_amount",0.0)
		$AnimationTree.set("parameters/Seek/seek_position",0)

func start_grenade_cooldown():
	$Timer_Grenade_Cooldown.start(grenade_cool_time)
	$HUD.grenade_cooldown(grenade_cool_time)

func _on_Timer_Grenade_Cooldown_timeout():
	can_throw = true

#************************************************************************

func update_health(update_value):
	if not dead:
		if update_value > 0:
			health += update_value
			print("PLAYER gained health")
			$Particles/Heal_Particles/AnimationPlayer.play("process")
			if health > health_max:
				health = health_max
		else:
			$Audio/Audio_Get_hit.play()
			health += update_value
			take_damage = true
			$Damage_Screen/AnimDC.play("anim_player_got_damage")
			$Particles/Hit_particles.emitting = true
			$Timer_Hurt.start()
			$AnimationTree.set("parameters/BlendHurt/blend_amount",1)
		$HUD.update_Health(health)
		if health <= 0:
			dead = true
			disable_playing()
			emit_signal("player_is_dead")

func _on_Timer_Hurt_timeout():
	take_damage = false
	$AnimationTree.set("parameters/BlendHurt/blend_amount",0.0)
	
#************************************************************************

func spawn_plants_while_walking():
	var flower_instance
	var grass_instance
	if randf() >= 0.5: flower_instance = flower1.instance()
	else: flower_instance = flower2.instance()
	grass_instance = grass.instance()
	get_node("/root/Objects/Flower_Player").add_child(flower_instance)
	get_node("/root/Objects/Grass_Player").add_child(grass_instance)
	var spawnpos = Vector3($Position_Flower.global_transform.origin.x + randf() -0.50, 0.1, $Position_Flower.global_transform.origin.z + randf() -0.50)
	flower_instance.global_transform.origin = spawnpos
	grass_instance.global_transform.origin = spawnpos
	grass_instance.rotation_degrees.y = randi()%360

func _on_Timer_Plant_Spawn_timeout():
	if not move == Vector3(0, -gravity, 0):
		spawn_plants_while_walking()

#************************************************************************

func set_neutral_animtree_parameters():
	$AnimationTree.set("parameters/BlendHurt/blend_amount",0.0)
	$AnimationTree.set("parameters/BlendDash/blend_amount",0.0)
	$AnimationTree.set("parameters/Blend2/blend_amount",0.0)
	$AnimationTree.set("parameters/BlendGShoot/blend_amount",0.0)
	$AnimationTree.set("parameters/BlendGrenade/blend_amount",0.0)
	$AnimationTree.set("parameters/TS_Walk/scale",0.7)
	$AnimationTree.set("parameters/Walk/blend_position",Vector2(0, 0))

func disable_playing():
	#$CameraPivot/Camera.current = false
	playing = false
	$HUD.visible = false
	set_neutral_animtree_parameters()
	can_shoot = false
	can_throw = false
	can_dash = false
	$Timer_Plant_Spawn.stop()

func enable_playing():
	$CameraPivot/Camera.current = true
	$HUD.visible = true
	playing = true
	can_shoot = true
	can_throw = true
	can_dash = true
	$Timer_Plant_Spawn.start()

func _on_HitArea_area_entered(area):
	if area.is_in_group("Enemy_Weapon"):
		print("PLAYER take_damage_from_melee")
		update_health(-damage_from_melee)
	if area.is_in_group("Enemy_Bullet"):
		print("PLAYER take_damage_from_range")
		update_health(-damage_from_range)
	if area.is_in_group("Flower_Health_Full"):
		update_health(health_max)
	if area.is_in_group("Flower_Health"):
		update_health(health_form_flower)

func reset():
	dead = false
	health = health_max
	$HUD.update_Health(health)
	$Timer_Hurt.stop()
	set_neutral_animtree_parameters()
	enable_playing()
