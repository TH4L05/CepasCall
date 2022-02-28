extends StaticBody


func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		$Audio_Collect.play()
		$AnimationPlayer.play("anim_collect")

func _on_Area_area_entered(area):
	if area.is_in_group("Player_Hit_Area"):
		$Audio_Collect.play()
		$AnimationPlayer.play("anim_collect")
