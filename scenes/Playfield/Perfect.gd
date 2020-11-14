extends Sprite

onready var tw = $Tween
onready var light = $Light
onready var failed = $Failed
onready var text = $Label

func hit():
	if (!isFailed):
		tw.interpolate_property(light,"self_modulate",Color(1,1,1,1),Color(1,1,1,0),.25,Tween.TRANS_SINE,Tween.EASE_OUT)
		tw.interpolate_property(light,"offset",Vector2(0,-24),Vector2(),.25,Tween.TRANS_SINE,Tween.EASE_OUT)
		tw.interpolate_property(self,"offset",Vector2(0,-24),Vector2(),.25,Tween.TRANS_SINE,Tween.EASE_OUT)
		tw.start()

var isFailed
func failed():
	if (not isFailed):
		Sound.play(preload("res://assets/sfx/perfect_fail.ogg")).volume_db = -7
		isFailed = true
		failed.visible = true
		light.visible = false
		text.visible = false
		set_process(true)

func _ready():
	set_process(false)

var t = 0
func _process(dt):
	t += dt
	if (t < .5):
		var rad = 8 * (1 - sin(t * PI))
		position = Vector2(16,16) + Vector2(randf() - .5,randf() - .5).normalized() * rad
	else:
		position = Vector2(16,16)
		if (t > .75):
			position = position - Vector2(64 * sin((t - .75) * PI * 2),0)
			if (t > 1):
				free()
