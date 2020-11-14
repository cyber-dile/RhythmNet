extends Node

onready var fade = $Fade
onready var fade2 = $Fade2
onready var tween = $Tween
onready var bumper = $Bumper
onready var intro = $Intro
var track

var state = "bumper"

func fadeTo(from, to, t = .125):
	tween.interpolate_property(fade, "self_modulate", from, to, t)
	tween.start()

func _ready():
	randomize()
	fade.self_modulate = Color(0,0,0,1)
	fadeTo(fade.self_modulate, Color(0,0,0,0))
	bumper.visible = true
	track = Track.new()
	add_child(track)
	track.setAudio(preload("res://assets/ost/title.ogg"))
	track.setBPM([
		[125,116] #125ms offset, 116 bpm
	])
	track.play()

func _process(_dt):
	var beat = track.getBeat()
	if (has_node("Fade2")):
		var alpha = 1 - sin(clamp(abs(beat-4)*2,0,1) * PI/2) # need a separate fade to time it to the beat
		fade2.self_modulate = Color(1,1,1,alpha)
		if (beat > 4):
			intro.visible = true
		if (beat > 5):
			fade2.queue_free()
			state = "menu" # state will NEVER be anything other than 'bumper' by the time this comes
