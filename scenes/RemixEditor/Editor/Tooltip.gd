extends Node2D

export var size = Vector2(320,80)
export var arcLength = 16

onready var tx = $FG/Label
onready var inner = $FG

func circle(quadrant,col):
	var cx = arcLength
	var cy = arcLength
	var angle = PI/2 + quadrant * PI/2 # Q0 is at PI/2, Q1 is at PI
	if quadrant >= 2:
		cx = size[0] - arcLength
		angle = -(quadrant - 2) * PI/2 # Q2 is at 0, Q3 is at -PI/2 or 3PI/2
	if fmod(quadrant,2) == 1:
		cy = size[1] - arcLength #top left, bottom left, top right, bottom right
	var center = Vector2(cx,cy)
	draw_circle(center,arcLength,col)

func _draw():
	var rwidth = size[0] - arcLength * 2
	var rheight = size[1] - arcLength * 2
	var col = Color(1,1,1,1)
	draw_set_transform(-size/2, 0, Vector2(1,1)) # start drawing from the topleft instead of center
	draw_rect(Rect2(arcLength,0,rwidth,size[1]), col)
	draw_rect(Rect2(0,arcLength,size[0],rheight), col)
	for i in range(4):
		circle(i,col)

var text = ""

func _process(dt):
	visible = (text.length() > 0)
	if (visible and get_node("..").visible):
		var mp = get_viewport().get_mouse_position()
		tx.text = text
		var tb = tx.get_font("font").get_string_size(text)
		inner.size = Vector2(tb.x + 16, 16)
		size = Vector2(tb.x + 18, 18)
		inner.update()
		update()
		mp += size/2 + Vector2(2,2)
		position = mp
		if (position.x + size.x > 640):
			position -= Vector2(size.x + 4,0)
		if (position.y + size.y > 360):
			position -= Vector2(0,size.y + 4)
