tool
extends CanvasItem

export var gridn = 0
export var beat = 0.0
export var mod = 0.0

var time = 0

func _draw():
	draw_set_transform(Vector2(360,180),time/32 * PI,Vector2(1+mod/10,1+mod/10))
	var col1 = Color(1,1,1)
	var col2 = Color(.9,.9,.9)
	for x in range(-15,15):
		for y in range(-15,15):
			var color = (col1 if fmod(x+8+y+5+gridn, 2) == 0 else col2)
			draw_rect(Rect2(x*32,y*32,32,32),color)

func _process(dt):
	time += dt
	update()
