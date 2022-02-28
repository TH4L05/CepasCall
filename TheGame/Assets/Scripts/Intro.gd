extends Control

var skipped :bool

func _input(_event):
	if not skipped:
		if Input.is_action_just_pressed("ATTACK"):
			skipped = true
			$AnimationPlayer.stop()
			$AnimationPlayer.play("anim_cancel")

func load_scene():
	get_tree().change_scene("res://Assets/Scene_Level/The_World.tscn")


