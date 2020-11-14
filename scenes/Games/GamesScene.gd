extends Node

var track

onready var fade = $Fade
onready var tween = $Tween

func fadeTo(from, to, t = .125):
	tween.interpolate_property(fade, "self_modulate", from, to, t)
	tween.start()

func fadeMusic():
	tween.interpolate_property(track.stream, "volume_db", 7, -80, 1)
	tween.start()

func _ready():
	get_node("MainMenu").enabled = false
	get_node("RhythmGames").enabled = false
	track = Track.new()
	add_child(track)
	track.setAudio(preload("res://assets/ost/selection.ogg"))
	track.setBPM([
		[0,150]
	])
	track.stream.volume_db = 7
	track.play()
	
	get_node("MainMenu").enabled = true
