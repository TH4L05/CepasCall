extends Sprite3D

onready var bar = $Viewport/Healthbar2D

func _ready():
	texture = $Viewport.get_texture()
	
func update(health):
	bar.update_bar(health)
