extends StaticBody


func _ready():
	pass
	
func play_animation():
	$AnimationPlayer.play("anim_move_up")

func play_animation_reverse():
	$AnimationPlayer.play_backwards("anim_move_up")
