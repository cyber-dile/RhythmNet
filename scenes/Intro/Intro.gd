extends Node2D

signal skipped

onready var timer = $Timer
onready var tween = $Tween
onready var screenOne = $Screen1
onready var screenTwo = $Screen2

func fade(obj):
	obj.visible = true
	tween.interpolate_property(obj, "modulate", Color(1,1,1,0), Color(1,1,1,1), .25, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()
	timer.start(2.5)
	var timeout = yield(self, "skipped")
	tween.stop(obj)
	timer.stop()
	
	if (timeout):
		tween.interpolate_property(obj, "modulate", Color(1,1,1,1), Color(1,1,1,0), .25, Tween.TRANS_SINE, Tween.EASE_IN)
		tween.interpolate_property(obj, "rotation", 0, 1.25 * PI, .25, Tween.TRANS_SINE, Tween.EASE_IN)
		tween.interpolate_property(obj, "scale", Vector2(1,1), Vector2(.5,.5), .25, Tween.TRANS_SINE, Tween.EASE_IN)
		tween.start()
		timer.start(.5)
		yield(self, "skipped")
		tween.stop(obj)
		timer.stop()
	obj.visible = false

func _input(ev):
	if ev.is_action_pressed("start"):
		emit_signal("skipped")

func timeout():
	emit_signal("skipped", true)

func _ready():
	screenOne.modulate = Color(1,1,1,0)
	screenTwo.modulate = Color(1,1,1,0)
	
	timer.start(.5)
	timer.connect("timeout", self, "timeout")
	yield(timer,"timeout")
	
	yield(fade(screenOne), "completed")
	yield(fade(screenTwo), "completed")
	Scenes.change(preload("res://scenes/Menu/Menu.tscn"))
