extends Control

onready var bg = $BG
var track

var beats = [.5,1.0,2.0,3.0,3.5,3.66,3.83,4]

func _process(_dt):
	if (track == null):
		track = get_node("..").track
	var beat = max(track.getBeat(),0)
	var rounded = floor(beat)
	var mod = 1 - sin(fmod(beat,1) * PI/2)
	var timeSince = 100
	for nbeat in beats:
		if (beat > nbeat):
			timeSince = min(timeSince,beat - nbeat)
	var tmod = 1 - sin(min(timeSince,1) * PI/2)
	bg.gridn = floor(fmod(beat,2))
	bg.flash = tmod
	bg.beat = beat
	bg.self_modulate = Color(1 + mod,1 + mod,1 + mod,1)
	set_rotation((rounded + mod + tmod) * PI/24)
	var sz = 1 + (rounded/8 + mod/4 + tmod/4)
	rect_scale = Vector2(sz,sz)
	if (beat > 4):
		queue_free()
