extends Node

var track
var editing = ""

onready var fade = $Fade
onready var tween = $Tween

func fadeTo(from, to, t = .125):
	tween.interpolate_property(fade, "self_modulate", from, to, t)
	tween.start()

func fadeMusic():
	tween.interpolate_property(track.stream, "volume_db", 0, -80, 1)
	tween.start()

func _ready():
	get_node("Menu").enabled = false
	get_node("Editor").enabled = false
	track = Track.new()
	add_child(track)
	track.setAudio(preload("res://assets/ost/editor.ogg"))
	track.setBPM([
		[0,135]
	])
	track.play()
	
	get_node("Menu").enabled = true
