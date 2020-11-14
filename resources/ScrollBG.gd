tool
extends CanvasItem

export var gridn = 0
export var shift = Vector2()

# Positive modulo is defined in-script so the lack of Singletons.Util doesn't impact the editor use
func pmod(num, mod):
	if (num < 0):
		num = num + ceil(abs(num/mod)) * mod
	return fmod(num, mod)

func _draw():
	draw_set_transform(Vector2(360,180),0,Vector2(1,1))
	var col1 = Color(1,1,1)
	var col2 = Color(.8,.8,.8)
	for x in range(-14,12):
		for y in range(-8,8):
			var color = (col1 if fmod(x+8+y+5+gridn, 2) == 0 else col2)
			draw_rect(Rect2(x*32+pmod(shift.x,64.0),y*32+pmod(shift.y,64.0),32,32),color)

func _process(dt):
	update()
