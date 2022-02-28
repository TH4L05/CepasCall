extends Button

signal modified_Pressed(node)

export var event = ""


func _on_KeyButton_pressed():
	emit_signal("modified_Pressed", self)
