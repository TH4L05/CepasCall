extends Control

export var hit_visualizer_speed = 2

var seconds = 0
var minutes = 0
var grenade_cooldown_time = 0.0
var dash_cooldown_time = 0.0
var d = false
var g = false

func _process(delta):
	#Weiß grad nicht wie ich das nur dann aufrufe, wenn das Optionsmenu geschlossen wird,
	#oder die Szene abgespielt, ohne von außen einzuwirken.
	update_skill_label_text()
	
	hit_visualizer(delta)
	if g:
		$ui_hud_skills_background/Grenade.value = int(($Timer_Cool_Grenade.time_left / grenade_cooldown_time) *100)
	if d:
		$ui_hud_skills_background/Dash.value = int(($Timer_Cool_Dash.time_left / dash_cooldown_time) *100)

func _on_Timer_timeout():
	time()

func time():
	seconds +=1
	if seconds > 59:
		minutes += 1
		seconds = 0
	$Time.text = "%02d:%02d" %[minutes, seconds]

func grenade_cooldown(time_value):
	grenade_cooldown_time = time_value
	$ui_hud_skills_background/TextureRect.visible = false
	$Timer_Cool_Grenade.start(grenade_cooldown_time)
	g = true
	$ui_hud_skills_background/Grenade/CPUParticles2D.emitting = false

func dash_cooldown(time_value):
	dash_cooldown_time = time_value
	$ui_hud_skills_background/TextureRect2.visible = false
	$Timer_Cool_Dash.start(dash_cooldown_time)
	d = true
	$ui_hud_skills_background/Dash/CPUParticles2D.emitting = false

func _on_Timer_Cool_Grenade_timeout():
	$ui_hud_skills_background/TextureRect.visible = true
	$ui_hud_skills_background/Grenade.value = int(0)
	g = false
	$ui_hud_skills_background/AnimationPlayerGrenade.play("recovered_grenade")


func _on_Timer_Cool_Dash_timeout():
	$ui_hud_skills_background/Dash.value = int(0)
	d = false
	$ui_hud_skills_background/AnimationPlayerDash.play("recovered_dash")

func update_Health(health):
	$PlayerHealth.value = health
	var remaining_health_percentage = health / $PlayerHealth.max_value
	var newPosition = $PlayerHealth.rect_size.x * remaining_health_percentage
	if newPosition < $PlayerHealth/HitVisualizer.margin_left:
		$PlayerHealth/AnimationPlayer.stop()
		$PlayerHealth/AnimationPlayer.play("hurt")
	$PlayerHealth/HitVisualizer.margin_left = newPosition

func hit_visualizer(delta):
	if abs($PlayerHealth/HitVisualizer.margin_right) + abs($PlayerHealth/HitVisualizer.margin_left) <= $PlayerHealth.rect_size.x:
		$PlayerHealth/HitVisualizer.margin_right -= hit_visualizer_speed * delta
	else:
		$PlayerHealth/HitVisualizer.margin_right = $PlayerHealth/HitVisualizer.margin_left - $PlayerHealth.rect_size.x

func robot_count(remaining_robots):
	$AnimationPlayer.play("robot_scaling")
	$Robot_Texture/Robots_Left.text = str(remaining_robots)


func update_skill_label_text():
	$ui_hud_skills_background/TextureRect2/CenterContainer/Label.text = InputMap.get_action_list("RUN")[0].as_text()
	$ui_hud_skills_background/TextureRect/CenterContainer/Label.text = InputMap.get_action_list("GRENADE")[0].as_text()
	$ui_hud_skills_background/TextureRect2/CenterContainer/Label.rect_size.x = 0
	$ui_hud_skills_background/TextureRect/CenterContainer/Label.rect_size.x = 0
	$ui_hud_skills_background/TextureRect2/CenterContainer/Label.rect_pivot_offset = $ui_hud_skills_background/TextureRect2/CenterContainer/Label.rect_size / 2
	$ui_hud_skills_background/TextureRect/CenterContainer/Label.rect_pivot_offset = $ui_hud_skills_background/TextureRect/CenterContainer/Label.rect_size / 2
