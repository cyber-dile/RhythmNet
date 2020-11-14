tool
extends CanvasItem

export var size = 64
export var color = Color(0,1,1)

func _draw():
	draw_circle(Vector2(),size,color)

func _process(_dt):
	update()
