extends Control

var game_is_paused :bool
var options :bool

func _ready():
	$Label_Text.visible = false
	$Options/Buttons/ButtonOptions_Return.connect("pressed" ,self ,"hide_options")

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		if game_is_paused == false:
			get_tree().paused = true
			game_is_paused = true
			$AnimationPlayer.play("anim_show")
		else:
			if not options:
				get_tree().paused = false
				game_is_paused = false
				$AnimationPlayer.play("anim_hide")
			
func _on_Button_Resume_pressed():
	$AudioClick.play()
	get_tree().paused = false
	game_is_paused = false
	$AnimationPlayer.play("anim_hide")

func _on_Button_Options_pressed():
	options = true
	$AudioClick.play()
	$Label_Text.visible = false
	$AnimationPlayer.play("anim_options")

func _on_Button_Quit_pressed():
	$AudioClick.play()
	get_tree().paused = false
	get_node("/root/Objects").queue_free()
	get_tree().change_scene("res://Assets/Scene_Level/MenuV2.tscn")


func _on_Button_Options_mouse_entered():
	$AudioSnap.play()
	$Label_Text.visible = true
	$Label_Text.text = "Options"
	
func _on_Button_Resume_mouse_entered():
	$AudioSnap.play()
	$Label_Text.visible = true
	$Label_Text.text = "Resume"
	
func _on_Button_Quit_mouse_entered():
	$AudioSnap.play()
	$Label_Text.visible = true
	$Label_Text.text = "Back to menu"

func hide_options():
	options = false
	$AnimationPlayer.play_backwards("anim_options")
