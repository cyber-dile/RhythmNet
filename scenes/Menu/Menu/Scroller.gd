extends Sprite

var t = 0
func _process(dt):
	t += dt
	var pos = fmod(t,16)/16 * 1000
	region_rect = Rect2(-pos,0,3000,200)
