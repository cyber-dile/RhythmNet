extends Node2D

var track

onready var fade = $Fade
onready var tween = $Tween
onready var bg = $BG

onready var scroll = $BG/Scroller

func fadeTo(from, to, t = .125):
	tween.interpolate_property(fade, "self_modulate", from, to, t)
	tween.start()

func fadeMusic():
	tween.interpolate_property(track.stream, "volume_db", 0, -80, 1)
	tween.start()

func _ready():
	track = Track.new()
	add_child(track)
	track.setAudio(preload("res://assets/ost/credits.ogg"))
	track.setBPM([
		[0,111]
	])
	track.play()
	fadeTo(Color(1,1,1,1),Color(1,1,1,0))

var inputStopped = false
func back():
	inputStopped = true
	fadeMusic()
	fadeTo(Color(1,1,1,0),Color(1,1,1,1))
	Sound.play(preload("res://assets/sfx/back.ogg"))
	yield(get_tree().create_timer(1),"timeout")
	Scenes.change(load("res://scenes/Games/Games.tscn"))

var t = 0
var speed = 32 # pixels per sec
func _process(dt):
	t += dt
	if (t > 2 and t < 3):
		scroll.position = Vector2(0,-speed + speed * sin((3 - t) * PI/2))
	elif (t > 3):
		scroll.position = Vector2(0,-speed * (t - 2))
	var beat = track.getBeat()
	bg.gridn = floor(fmod(beat/2,2))
	bg.shift = scroll.position/4

func _input(ev):
	if (!inputStopped):
		if (ev.is_action_pressed("b")):
			back()
