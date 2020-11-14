tool
extends Control

export var color0 = Color(0,0,0,1)
export var color1 = Color(1,1,1,1)
export var size = 64
export var scroll = 0.0 # float between 0 and 1

# Positive modulo is defined in-script so the lack of Singletons.Util doesn't impact the editor use
func pmod(num, mod):
	if (num < 0):
		num = num + ceil(abs(num/mod)) * mod
	return fmod(num, mod)

func _draw():
	draw_set_transform(Vector2(320,18),15 * PI/180,Vector2(1,1))
	for i in range(-12,12):
		var c = (color0 if pmod(i,2) == 0 else color1)
		draw_rect(Rect2(i * size + pmod(scroll,1.0) * size * 2,-200,size,400), c)

func _process(_dt):
	update()
