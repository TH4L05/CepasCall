extends Spatial

var sound_volume :float = 0.0
var music_volume :float = 0.0
var hover_positions :Array = [Vector2(136,451), Vector2(136,583), Vector2(136,682), Vector2(136,781)]
var cursor = load("res://Assets/Textures/Cursor/MenuCursor_50x50_darkpink_01.png")
var cursor_hover = load("res://Assets/Textures/Cursor/MenuCursor_50x50_pink_01.png")

func _init():
	OS.window_fullscreen = true

func _ready():
	#ResourceLoader.load("res://Assets/Scene_Templates/Bullet.tscn")
	#ResourceLoader.load("res://Assets/Scene_Templates/Bullet_Enemy.tscn")
	#ResourceLoader.load("res://Assets/Effects/fx_explosion.tscn")
	#ResourceLoader.load("res://Assets/Effects/fx_grenade.tscn")
	main()
	set_custom_cursor()
	connect_options_menu_signals()
	AudioServer.set_bus_volume_db(2,GlobalVariables.music_volume)
	AudioServer.set_bus_volume_db(3,GlobalVariables.sound_volume)
	

func _on_Button_Play_pressed():
	$AudioClick.play()
	$AnimationPlayerMain.play("anim_start_game")

func _on_Button_Options_pressed():
	$AudioClick.play()
	$AnimationPlayerMain.play("anim_show_options_menu")

func _on_Button_Credits_pressed():
	$AudioClick.play()
	$AnimationPlayerMain.play("anim_show_credits")

func _on_Button_Quit_pressed():
	$AudioClick.play()
	get_tree().quit()

#*************************************************************

func _on_Button_Play_mouse_entered():
	$AudioSnap.play()
	$Main/Hover.rect_position = hover_positions[0]
	$Main/Hover.visible = true


func _on_Button_Play_mouse_exited():
	$Main/Hover.visible = false

func _on_Button_Options_mouse_entered():
	$AudioSnap.play()
	$Main/Hover.rect_position = hover_positions[1]
	$Main/Hover.visible = true

func _on_Button_Options_mouse_exited():
	$Main/Hover.visible = false

func _on_Button_Credits_mouse_entered():
	$AudioSnap.play()
	$Main/Hover.rect_position = hover_positions[2]
	$Main/Hover.visible = true


func _on_Button_Credits_mouse_exited():
	$Main/Hover.visible = false

func _on_Button_Quit_mouse_entered():
	$AudioSnap.play()
	$Main/Hover.rect_position = hover_positions[3]
	$Main/Hover.visible = true

func _on_Button_Quit_mouse_exited():
	$Main/Hover.visible = false


#*************************************************************

func set_custom_cursor():
	Input.set_custom_mouse_cursor(cursor)
	Input.set_custom_mouse_cursor(cursor_hover,Input.CURSOR_POINTING_HAND)

func connect_options_menu_signals():
	$Credits/CenterContainer/Button.connect("pressed",self,"credits_to_main")
	$Options/Buttons/ButtonOptions_Return.connect("pressed",self,"options_to_main")

func load_scene():
	get_tree().change_scene("res://Assets/Scene_Level/Intro.tscn")

func tween_slide():
	$PlayerDummy.translation = Vector3(2, -0.01, 68.5)
	var endpoint = $PlayerDummy.translation + Vector3(0, 0, -100)
	$Tween.interpolate_property($PlayerDummy,"translation",$PlayerDummy.translation,endpoint,112,Tween.TRANS_LINEAR,0)
	$Tween.start()

func tween_stop():
	$Tween.stop_all()

#*************************************************************

func main():
	$AnimationPlayerMain.play("anim_menu")

func credits_to_main():
	$AnimationPlayerMain.play("anim_credits_to_main")

func options_to_main():
	$AnimationPlayerMain.play("anim_options_to_main")

