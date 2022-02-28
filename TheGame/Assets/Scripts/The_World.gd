extends Spatial

export var game_progress :Array
var areas :Array
var enemygroup :Array
var enemy_groups :Array
var enemies :Array
var enemy_amount :int
var area_enemy_amount :int
var num :int
var trigger_areas :Array
var trigger_area_name  :Array
var triggernumber :int
var barriers :Array
var godtext :Array
export var cut_scene :bool
var show_full_text :bool
var finish_cutscene :bool
var cutscenenumber :int
var linenumber :int
var endlinenumber :int
var area_name :String
var can_click :bool
var show_butterfly_move :bool
var player_is_dead :bool
var player_in_combat :bool
var cursor = load("res://Assets/Textures/Cursor/CustomCursor_60x60_01.png")
export (PackedScene) var enemy_range
export (PackedScene) var enemy_melee
var wave :int
var final_stage :bool
var wait :bool
var start_final_stage :bool
var start_final_stage_cutscene :bool
var reset_position
var rng = RandomNumberGenerator.new()
export var final_wave_2 :PoolIntArray
export var final_wave_3 :PoolIntArray
export var final_wave_4 :PoolIntArray
export var final_wave_5 :PoolIntArray
export var final_wave_6 :PoolIntArray
var object_scene

func _input(_event):
	if not player_is_dead:
		if Input.is_action_just_pressed("ATTACK"):
			if cut_scene and can_click and not final_stage:
					set_god_text_line()
			if start_final_stage:
				start_final_stage = false
				play_cutscene(4)
			if start_final_stage_cutscene:
				start_final_stage_cutscene = false
				$Final/Area/CollisionShape.disabled = true
				play_cutscene(5)

func start_god_text():
	show_full_text = false
	$Cutscene/TextfromGod/Text.percent_visible = 0
	$Cutscene/TextfromGod/Text.bbcode_text = godtext[linenumber]
	$Cutscene/AnimationPlayerText.play("anim_show_text")

func set_god_text_line():
	if not player_is_dead:
		if not show_full_text:
			show_text_full()
		else:
			if linenumber >= endlinenumber:
				stop_god_text_anim()
			else:
				show_full_text = true
				linenumber += 1
				start_god_text()
	else:
		start_god_text()

func show_text_full():
	show_full_text = true
	$Cutscene/AnimationPlayerText.stop()
	$Cutscene/TextfromGod/Text.percent_visible = 1.0

func stop_god_text_anim():
	$Cutscene/AnimationPlayerMain.stop()
	$Cutscene/AnimationPlayerMain.play("anim_stop")
	$Cutscene/TextfromGod/Text.bbcode_text = ""
	$Cutscene/TextfromGod/Text.percent_visible = 0
	cut_scene = false
	check_for_butterflies()
	if game_progress[0] == true and game_progress[1] == false:
		first_attack()

func play_random_god_audio():
		var audiofiles :Array = get_node("Cutscene/Audio").get_children()
		rng.randomize()
		var number = rng.randi_range(0, 5)
		audiofiles[number].play()

func check_for_butterflies():
	if show_butterfly_move:
		show_and_move_butterflies()
		show_butterfly_move = false

#========================================================================

func load_object_scene():
	object_scene = ResourceLoader.load("res://Assets/Scene_Level/Objects.tscn")
	var instanced_scene = object_scene.instance()
	get_node("/root/").call_deferred("add_child",instanced_scene)

func _ready():
	load_object_scene()
	$Cutscene/Camera_Cutscene.environment = null
	$Cutscene/Camera_Cutscene.current = false
	$Player/CameraPivot/Camera.current = true
	$Special/Fade/AnimationFade.play("anim_fade_in")
	set_cursor()
	set_audio_volume()
	read_text_lines_from_file()
	set_trigger_areas()
	connect_signals()
	set_player_var_in_enemies()
	reset_position = $Object/Points_Reset/Position_Reset_0

func set_cursor():
	Input.set_custom_mouse_cursor(cursor ,0 ,Vector2(30,30))

func set_audio_volume():
	AudioServer.set_bus_volume_db(2,GlobalVariables.music_volume)
	AudioServer.set_bus_volume_db(3,GlobalVariables.sound_volume)
	
func _process(_delta):
	if wait:
		$Cutscene/Area_Clean/CenterContainer/VBoxContainer/Label.text = "%0d" %$Final/Timer_Spawn.time_left

#========================================================================

func no_health():
	player_is_dead = true
	$Music/CombatMusic.stop()
	$Music/CombatMusic2.stop()
	$Music/Timer_Fight_Music.stop()
	linenumber = 13
	endlinenumber = 13
	play_cutscene(99)
	get_tree().paused = true

func try_again():
	player_is_dead = false
	$Player.global_transform = reset_position.global_transform
	$Player.camera_pivot.global_transform = reset_position.global_transform
	$Cutscene/Camera_Cutscene.environment = null
	$Cutscene/Camera_Cutscene.current = false
	$Player/CameraPivot/Camera.current = true
	$Special/No_health/Control.visible = false
	$Cutscene/TextfromGod.visible = false
	if not final_stage:
		$Music/AmbientMusic1.stream_paused = false
		$Music/AmbientMusic1.volume_db = -10
	else:
		$Music/CombatMusic2.play()
		#$Music/AmbientMusic2.stream_paused = false
		#$Music/AmbientMusic2.volume_db = -10
	stop_enemy()
	$Player.reset()

func stop_enemy():
	enemy_amount = 0
	enemy_groups.clear()
	enemygroup.clear()
	if not final_stage:
		enemy_groups = get_node("Enemy").get_children()
		for group in enemy_groups.size():
			enemygroup = get_node("Enemy/" + str(enemy_groups[group].name)).get_children()
			for enemy in enemygroup.size():
				if not enemygroup[enemy] == null:
					enemygroup[enemy].reset_status()
	else:
		enemygroup = get_node("Final/Enemy/").get_children()
		for enemy in enemygroup.size():
			if not enemygroup[enemy] == null:
				enemygroup[enemy].reset_status()

func _on_Button1_pressed():
	get_tree().paused = false
	try_again()
	set_player_var_in_enemies()
	
func _on_Button2_pressed():
	get_tree().paused = false
	load_scene()

func load_scene():
	get_node("/root/Objects").queue_free()
	get_tree().change_scene("res://Assets/Scene_Level/MenuV2.tscn")

#========================================================================

func read_text_lines_from_file():
	var file = File.new()
	file.open("res://god_text.txt", File.READ)
	while !file.eof_reached():
		var line = file.get_line()
		godtext.append(line)
	file.close()
	print("godtexts load done - read " + str(godtext.size()) + " lines")

func set_trigger_areas():
	trigger_areas = get_node("TriggerAreas").get_children()
	for area in trigger_areas.size():
		trigger_area_name.append(trigger_areas[area].name)
		trigger_areas[area].connect("player_is_in_area",self,"set_trigger_values")
		areas.append(false)
	print("trigger areas signals set - amount = " + str(areas.size()) + "x")

func connect_signals():
	var count1 :int = 0
	var count2 :int = 0
	enemy_groups = get_node("Enemy").get_children()
	for group in enemy_groups.size():
		count1 +=1
		enemygroup = get_node("Enemy/" + str(enemy_groups[group].name)).get_children()
		for enemy in enemygroup.size():
			count2 +=1
			enemygroup[enemy].connect("Enemy_Killed", self, "area_enemy_is_dead")
			enemygroup[enemy].connect("Player_is_detected", self, "enemy_detect_player")
	print("enemygroups = " + str(count1))
	print("enemies = " + str(count2))
	$Player.connect("player_is_dead",self,"no_health")
	$Enemy_Melee_Dummy.connect("Dummy_Killed",self,"first_enemy_is_dead")
	print("SIGNALS DONE")

func set_player_var_in_enemies():
	enemy_groups = get_node("Enemy").get_children()
	for group in enemy_groups.size():
		enemygroup = get_node("Enemy/" + str(enemy_groups[group].name)).get_children()
		for enemy in enemygroup.size():
			enemygroup[enemy].player = $Player

func set_trigger_values(name):
	triggernumber = trigger_area_name.find(name)
	enemy_groups = trigger_areas[triggernumber].enemy_groups
	#***********************************************************************
	if trigger_areas[triggernumber].set_section:
		area_enemy_amount = trigger_areas[triggernumber].section_amount
		$Player/HUD/Robot_Texture/Robots_Left.text = str(area_enemy_amount)
	#***********************************************************************
	if trigger_areas[triggernumber].set_barriers:
		barriers = trigger_areas[triggernumber].barriergroup
	#***********************************************************************	
	show_butterfly_move = trigger_areas[triggernumber].show_butterflies
	#***********************************************************************
	if trigger_areas[triggernumber].cutscene:
		if trigger_areas[triggernumber].god_text:
			linenumber = trigger_areas[triggernumber].godtext_start_line
			endlinenumber = trigger_areas[triggernumber].godtext_end_line
		play_cutscene(trigger_areas[triggernumber].cutscene_number)
	#***********************************************************************	
	areas[triggernumber] = true
	special_area_settings_check()
	#***********************************************************************
	if trigger_areas[triggernumber].enemy_start_attack:
		enemy_amount = trigger_areas[triggernumber].enemy_amount
		$Music/AnimationPlayer_Music.play("fade_amient_to_combat")

func special_area_settings_check():
	print(areas)
	if areas[0] == true:
		areas[0] = false
		area_enemy_amount +=1
		$Player/HUD/Robot_Texture/Robots_Left.text = str(area_enemy_amount)
	if areas[1] == true:
		areas[1] = false
	if areas[2] == true:
		areas[2] = false
		if is_instance_valid(trigger_areas[1]):
			trigger_areas[1].queue_free()
			areas[1] = true
	if areas[3] == true:
		areas[3] = false
		reset_position = $Object/Points_Reset/Position_Reset_1
		game_progress[3] = true
		show_butterfly_move = true
		$Special/Tween1.stop_all()
		$Special/Tween2.stop_all()
		$Special/Position1.global_translate(Vector3(-9, 0, -71))
		$Special/Position2.global_translate(Vector3(-3, 0, -69))
	if areas[4] == true:
		areas[4] = false
		game_progress[4] = true
		$Music/AnimationPlayer_Music.play("fade_amient_to_ambient2")
	if areas[5] == true:
		areas[5] = false
		final_stage = true
		print(final_stage)
		game_progress[5] = true
		reset_position = $Object/Points_Reset/Position_Reset_2

func disable_barriers():
	for b in barriers.size():
		barriers[b].get_node("AnimationPlayer").play("anim_disable")
	barriers.clear()

#========================================================================

func area_enemy_is_dead():
	area_enemy_amount -= 1
	print("=====================================")
	print("Enemies in section left: " +str(area_enemy_amount))
	update_enemy_amount()
	$Player/HUD.robot_count(area_enemy_amount)
	if area_enemy_amount == 0 and final_stage:
		if wave < 7:
			$Final/Timer_Spawn.start()
			$Cutscene/AnimationPlayerMain.play("wait")
			wait = true
		else:
			game_progress[6] = true
			$Music/AnimationPlayer_Music.play("fade_combat_to_sting_2b")
			$Final/Area/CollisionShape.disabled = false
			$Final/Area.visible = true
	elif area_enemy_amount == 0:
		if game_progress[1] == true:
			game_progress[1] = false
			play_cutscene(3)
		print("=====================================")
		print("SECTION is cleared")
		if game_progress[2] == false:
			game_progress[2] = true
			#show_and_move_butterflies()
			trigger_areas[1].enabled = true
			trigger_areas[2].enabled = true
		if game_progress[3] == true:
			linenumber = 14
			endlinenumber = 14
			play_cutscene(2)
			disable_barriers()


func update_enemy_amount():
	if not final_stage:
		enemy_amount -=1
		print("Enemies on attack left: " +str(enemy_amount))
		$Music/Timer_Fight_Music.start()

func check_combat_status():
	if enemy_amount == 0:
		$Music/AnimationPlayer_Music.play("fade_combat_to_sting")
	else:
		$Music/Timer_Fight_Music.start()

func _on_Timer_Fight_Music_timeout():
	check_combat_status()


func enemy_detect_player():
	if not $Music/CombatMusic.is_playing() and not final_stage:	
		$Music/AnimationPlayer_Music.play("fade_amient_to_combat")
	enemy_amount +=1

func display_area_clean_text(): #unused
	$Cutscene/AnimationPlayerMain.play("anim_area_cleared")

#========================================================================

func play_cutscene(number):
	cut_scene = true
	$Cutscene/TextfromGod/Text.percent_visible = 0
	$Cutscene/AnimationPlayerMain.play("anim_play_scene_"+str(number))

func timer_start():
	$Timer.start(1)

func _on_Timer_timeout():
	can_click = true

#========================================================================

func show_and_move_butterflies():
	$Special/Tween1.stop_all()
	$Special/Tween2.stop_all()
	$Special/fx_buttfly_group.visible = true
	var position =$Player.translation + Vector3(0 ,2 ,0)
	$Special/Tween1.interpolate_property($Special/fx_buttfly_group, "translation" ,position ,$Special/Position1.translation ,4 ,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Special/Tween1.start()

func _on_Tween1_tween_completed(_object, _key):
	$Special/Tween2.interpolate_property($Special/fx_buttfly_group, "translation" ,$Special/Position1.translation ,$Special/Position2.translation ,4 ,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Special/Tween2.start()
	
func _on_Tween2_tween_completed(_object, _key):
	$Special/fx_buttfly_group.visible = false
	
#========================================================================

func  first_enemy_is_dead():
	linenumber = 4
	endlinenumber = 4
	play_cutscene(2)
	game_progress[0] = true

func first_attack():
	if game_progress[0] == true:
		game_progress[0] = false
		area_enemy_amount = 2
		$Player/HUD/Robot_Texture/Robots_Left.text = str(area_enemy_amount)
		$Music/AnimationPlayer_Music.play("fade_amient_to_combat")
		for enemy in $Enemy/Group01.get_children():
			enemy.visible = true
			enemy.start_attacking()
		game_progress[1] = true
	
#========================================================================

func set_spawnpositions():
	var spawnpositions :Array
	if wave == 6:
		spawnpositions  = get_node("Object/Points_Spawn2").get_children()
	else:
		spawnpositions  = get_node("Object/Points_Spawn1").get_children()
	return spawnpositions


func final_stage_enemy_attack_start():
	start_final_stage = false
	$Music/AnimationPlayer_Music.play("fade_amient_to_combat_2")
	wave = 1
	for enemy in get_node("Final/Enemy").get_children():
		enemy.visible = true
		enemy.connect("Enemy_Killed",self,"area_enemy_is_dead")
		enemy.connect("Player_is_detected", self, "enemy_detect_player")
		enemy.player = $Player
		enemy.start_attacking()
		area_enemy_amount += 1
		$Player/HUD/Robot_Texture/Robots_Left.text = str(area_enemy_amount)
	wave = 1
	$Cutscene/Area_Clean/CenterContainer/VBoxContainer/Label.text = "Wave " + str(wave)
	$Cutscene/AnimationPlayerMain.play("wave")
	wave += 1
	
func enemy_spawn():
	var positions :Array = set_spawnpositions()
	var wavetypes :Array = [final_wave_2, final_wave_3, final_wave_4, final_wave_5, final_wave_6]
	var new_enemy
	var type = wavetypes[wave-2]
	for e in positions.size():
		if type[e] == 1:
			new_enemy = enemy_melee.instance()
		else:
			new_enemy = enemy_range.instance()
		get_node("Final/Enemy").add_child(new_enemy)
		new_enemy.transform = positions[e].transform
		new_enemy.connect("Enemy_Killed",self,"area_enemy_is_dead")
		new_enemy.connect("Player_is_detected", self, "enemy_detect_player")
		new_enemy.player = $Player
		new_enemy.start_attacking()
		area_enemy_amount += 1
		$Player/HUD/Robot_Texture/Robots_Left.text = str(area_enemy_amount)
	print("final_stagewave " + str(wave))
	$Cutscene/Area_Clean/CenterContainer/VBoxContainer/Label.text = "Wave " + str(wave)
	$Cutscene/AnimationPlayerMain.play("wave")
	wave += 1

func _on_Timer_Spawn_timeout():
	enemy_spawn()
	wait = false

func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		$Final/plant_text.visible = true
		if game_progress[6] == true:
			start_final_stage_cutscene = true
		else:
			start_final_stage = true

func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		$Final/plant_text.visible = false
		start_final_stage = false
		start_final_stage_cutscene = false

func _on_AreaLighting1_body_entered(body):
	if body.is_in_group("Player"):
		$Lighting/AnimationPlayerLighting.play("Lighting beginning")
		$Lighting/AreaLighting1/CollisionShape.disabled=true

func _on_AreaLighting2_body_entered(body):
	if body.is_in_group("Player"):
		$Lighting/AnimationPlayerLighting.play("Lighting Final before")
		$Lighting/AreaLighting2/CollisionShape.disabled=true
