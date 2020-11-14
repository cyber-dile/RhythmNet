extends Control

onready var entry = $Entry

var value

func getValue():
	return value

func setValue(val, data = null):
	value = val
	entry.text = str(value)
	color()

func color():
	var color = get_node("../../Topbar/Top").self_modulate
	get_node("Node2D").self_modulate = color

func _ready():
	color()

func closed():
	pass

func _input(ev):
	if (ev is InputEventMouseButton and ev.button_index == 1 and ev.pressed and entry.get_node("Button").is_hovered()):
		setValue(!getValue())
