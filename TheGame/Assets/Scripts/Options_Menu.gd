extends Control

var hover_positions :Array = [Vector2(12,429), Vector2(12,543), Vector2(12,657), Vector2(12,890)]

func _ready():
	$AnimationPlayer.play("anim_audio")
	$Hover.rect_position = hover_positions[0]
	$Settings_Audio/VBoxContainer/Music/HSlider_Music.value = GlobalVariables.music_volume
	$Settings_Audio/VBoxContainer/Sound/HSlider_Sound.value = GlobalVariables.sound_volume

func _on_HSlider_Music_value_changed(value):
	GlobalVariables.music_volume = value
	AudioServer.set_bus_volume_db(2,value)

func _on_HSlider_Sound_value_changed(value):
	GlobalVariables.sound_volume = value
	AudioServer.set_bus_volume_db(3,value)

func _on_ButtonOptions_Settings_pressed():
	$AudioClick.play()
	$AnimationPlayer.play("anim_settings")

func _on_ButtonOptions_Audio_pressed():
	$AudioClick.play()
	$AnimationPlayer.play("anim_audio")

func _on_ButtonOptions_Controls_pressed():
	$AudioClick.play()
	$AnimationPlayer.play("anim_control")

func _on_ButtonOptions_Return_pressed():
	$AudioClick.play()
	self.visible =false

func _on_ButtonOptions_Reset_pressed():
	$AudioClick.play()
	if $Settings_Audio.visible == true:
		$Settings_Audio/VBoxContainer/Music/HSlider_Music.value = GlobalVariables.default_music_volume
		GlobalVariables.music_volume = GlobalVariables.default_music_volume
		$Settings_Audio/VBoxContainer/Sound/HSlider_Sound.value = GlobalVariables.default_sound_volume
		GlobalVariables.sound_volume = GlobalVariables.default_sound_volume
	if $Controls.visible == true:
		InputMap.load_from_globals()
		$Controls.start()

func _on_ButtonOptions_Settings_mouse_entered():
	$AudioSnap.play()
	$Hover.rect_position = hover_positions[0]
	$Hover.visible = true

func _on_ButtonOptions_Audio_mouse_entered():
	$AudioSnap.play()
	$Hover.rect_position = hover_positions[1]
	$Hover.visible = true

func _on_ButtonOptions_Controls_mouse_entered():
	$AudioSnap.play()
	$Hover.rect_position = hover_positions[2]
	$Hover.visible = true

func _on_ButtonOptions_Return_mouse_entered():
	$AudioSnap.play()
	$Hover.rect_position = hover_positions[3]
	$Hover.visible = true

func _on_ButtonOptions_Reset_mouse_entered():
	$AudioSnap.play()

#**************************************************************

func _on_CheckBox_toggled(button_pressed:bool):
	OS.window_fullscreen = button_pressed
	
func _on_CheckBox_Border_toggled(button_pressed:bool):
	OS.window_borderless = button_pressed

func _on_CheckBox_Vsync_toggled(button_pressed:bool):
	OS.vsync_enabled = button_pressed

func _on_OptionButton_item_selected(_index):
	var text :String = $Settings_Video/GridContainer/OptionButton.text
	var values := text.split_floats("x")
	var resolution = Vector2(values[0],values[1])
	if OS.window_fullscreen == true:
		OS.window_fullscreen = false
		OS.window_size = resolution
		OS.window_fullscreen = true
	else:
		OS.window_size = resolution
