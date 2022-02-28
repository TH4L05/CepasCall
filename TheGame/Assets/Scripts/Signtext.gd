extends Sprite3D

export var event = "GRENADE"

func _ready():
	texture = $Viewport.get_texture()

func _process(_delta):
	update()
	
func update():
	$Viewport/CenterContainer/Label.setCurrentKeyAsText(event)

