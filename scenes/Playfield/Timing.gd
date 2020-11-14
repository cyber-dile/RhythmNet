extends Control

onready var ex = $Circle
onready var tw = $Tween

func _ready():
	remove_child(ex)
	ex.visible = true

func time(acc, rank):
	var color
	match rank:
		"Ace":
			color = Color(1,.75,0)
			acc = 0
		"Good":
			color = Color(0,1,0)
		"Barely":
			color = Color(.5,.5,0)
		"Miss":
			color = Color(1,0,0)
	
	var nc = ex.duplicate()
	add_child(nc)
	nc.color = color
	nc.position = Vector2(acc/63 * 320 + 320,8)
	
	tw.interpolate_property(nc,"size",64,128,.25,Tween.TRANS_SINE,Tween.EASE_OUT)
	tw.start()
	yield(get_tree().create_timer(.1),"timeout")
	tw.interpolate_property(nc,"color",color,Color(color.r,color.g,color.b,0),.5,Tween.TRANS_SINE,Tween.EASE_OUT)
	tw.start()
	
	yield(get_tree().create_timer(.25),"timeout")
	nc.free()
