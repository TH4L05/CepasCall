extends Path

var follow = false
onready var follow_path = $PathFollow
var speed = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	follow = false

func _process(delta):
	if follow:
		follow_path.set_offset(follow_path.get_offset() * speed * delta)

func fol():
	$Cam.current = true
	$Tween.interpolate_property(follow_path, "unit_offset", 0 ,1 ,6 ,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	$Tween.start()
