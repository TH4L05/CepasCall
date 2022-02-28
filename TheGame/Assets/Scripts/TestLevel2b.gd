extends Spatial

var enemygroup = Array()
var enemygroup_range = Array()
var enemy_amount = 0
var enemy_count = 0
var cursor = load("res://Assets/Textures/Cursor/CustomCursor_60x60_01.png")

func _ready():
	Input.set_custom_mouse_cursor(cursor,0,Vector2(30,30))

	$Player.connect("player_is_dead",self,"show_dead_screen")
	settings()
	pass

func show_dead_screen():
	$Dead_Screen/AnimationPlayer.play("anim_show")
	get_tree().paused = true
	

func settings():
	enemygroup = get_node("Enemy/Group1").get_children()
		
	for i in enemygroup.size():
		enemygroup[i].connect("Enemy_Killed",self,"enemy_is_dead")
		enemygroup[i].player = $Player
		#if enemygroup[i].has_signal("Player_is_detected"):
			#enemygroup[i].connect("Player_is_detected",self,"enemygroup_start_attack")
			#enemygroup_range.append(enemygroup[i])
		enemy_amount += 1


func _on_Trigger_01_body_entered(body):
	if body.is_in_group("Player"):
		$Trigger_01/CollisionShape.disabled = true
		$TEST_Door1/AnimationPlayer.play("anim_move_up")
		#print("Player entered zone")

func enemygroup_start_attack():
	for i in enemygroup_range.size():
		enemygroup_range[i].start_attacking()

func enemy_is_dead():
	enemy_amount -= 1


func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		#$Path.following()
		var position = $Player.translation + Vector3(0 ,2 ,0)
		$Cam.current = true
		$Path/AnimationPlayer.play("New Anim")
		$Tween2.interpolate_property($CPUParticles2, "translation" ,position ,$Position3D2.translation ,8 ,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween2.start()


func _on_Tween2_tween_completed(_object, _key):
	$Tween3.interpolate_property($CPUParticles2, "translation" ,$Position3D1A.translation ,$Position3D1B.translation ,8 ,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween3.start()
