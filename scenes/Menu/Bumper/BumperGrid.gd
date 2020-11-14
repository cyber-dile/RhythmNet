tool
extends CanvasItem

export var gridn = 0
export var flash = 0.0
export var beat = 0

var stars = [
	[.5, Vector2(-150,-50), 125, Color.from_hsv(.6,.75,1),0],
	[1, Vector2(125,-50), 100, Color.from_hsv(.15,.75,1),1],
	[2, Vector2(-100,100), 75, Color.from_hsv(.9,.75,1),2],
	[3, Vector2(100,50), 125, Color.from_hsv(.3,.5,1),3],
]

func drawStar(star):

	var pos = star[1]
	var rad = star[2]
	var col = star[3]
	var rot = star[4]
	rad *= (.5 + flash)
	var array = PoolVector2Array()
	var arrayt = PoolVector2Array()
	var colors = PoolColorArray([col])
	var colorst = PoolColorArray([Color(col.r,col.g,col.b,.3)])
	for point in range(10):
		var angle = rot + point/10.0 * PI * 2.0
		var radius = rad
		if fmod(point,2) == 1:
			radius /= 2
		array.push_back(pos + Vector2(cos(angle) * radius, sin(angle) * radius))
		arrayt.push_back(pos + Vector2(cos(angle) * radius * 1.5, sin(angle) * radius * 1.5))
	draw_polygon(arrayt,colorst)
	draw_polygon(array,colors)

func _draw():
	var col1 = Color.from_hsv(.6,1,.15)
	var col2 = Color.from_hsv(.6,1,.2)
	for x in range(-12,12):
		for y in range(-8,8):
			var color = (col1 if fmod(x+8+y+5+gridn, 2) == 0 else col2)
			draw_rect(Rect2(x*32,y*32,32,32),color)
	for star in stars:
		if (beat > star[0]):
			drawStar(star)

func _process(_dt):
	update()
