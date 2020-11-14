tool
extends CanvasItem

export var width = 8
export var size = Vector2(320,80)
export var arcLength = 16

func drawArc(quadrant):
	var cx = arcLength
	var cy = arcLength
	var angle = PI/2 + quadrant * PI/2 # Q0 is at PI/2, Q1 is at PI
	if quadrant >= 2:
		cx = size[0] - arcLength
		angle = -(quadrant - 2) * PI/2 # Q2 is at 0, Q3 is at -PI/2 or 3PI/2
	if fmod(quadrant,2) == 1:
		cy = size[1] - arcLength #top left, bottom left, top right, bottom right
	var center = Vector2(cx,cy)
	var polygon = PoolVector2Array()
	var color = PoolColorArray([Color(1,1,1,1)])
	for i in range(9):
		var newAngle = angle + i/8.0 * PI/2.0
		polygon.push_back(center + Vector2(cos(newAngle) * arcLength,-sin(newAngle) * arcLength))
	var shortLength = arcLength - width
	for i in range(9):
		var newAngle = angle + PI/2.0 - i/8.0 * PI/2.0
		polygon.push_back(center + Vector2(cos(newAngle) * shortLength,-sin(newAngle) * shortLength))
	draw_polygon(polygon, color)

func _draw():
	var rwidth = size[0] - arcLength * 2
	var rheight = size[1] - arcLength * 2
	var col = Color(1,1,1,1)
	draw_set_transform(-size/2, 0, Vector2(1,1)) # start drawing from the topleft instead of center
	draw_rect(Rect2(arcLength,0,rwidth,width), col)
	draw_rect(Rect2(arcLength,size[1]-width,rwidth,width), col)
	draw_rect(Rect2(0,arcLength,width,rheight), col)
	draw_rect(Rect2(size[0]-width,arcLength,width,rheight), col)
	for i in range(4):
		drawArc(i)
