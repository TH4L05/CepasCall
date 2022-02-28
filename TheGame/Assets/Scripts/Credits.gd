extends Control


func _on_Button_pressed():
	$AudioClick.play()
	self.visible = false

func _on_Button_mouse_entered():
	$AudioSnap.play()
