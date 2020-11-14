extends CanvasItem

export var speed = 1

var t = 0
func _process(dt):
	t += dt * speed
	t = fmod(t,1)
	self_modulate = (Color(1,1,1,1) if t < .5 else Color(1,1,1,0))
