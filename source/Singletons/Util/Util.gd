extends Node

func get(script):
	var scr = script.new()
	add_child(scr)
	return scr

func _ready():
	VisualServer.set_default_clear_color(Color())
	OS.min_window_size = Vector2(512,288)

var Music = get(preload("res://source/Singletons/Util/Music.gd"))
var Math = get(preload("res://source/Singletons/Util/Math.gd"))
