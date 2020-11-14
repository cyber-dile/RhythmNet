extends Control

onready var entry = $Entry

var isTyping = false

func getValue():
	return int(entry.text)

func setValue(val, data = null):
	entry.text = str(val)
	color()

func color():
	var color = get_node("../../Topbar/Top").self_modulate
	get_node("Node2D").self_modulate = color

func _ready():
	color()

func closed():
	var val = getValue()
	if (val == null):
		val = 1
	entry.text = str(val)

func _input(ev):
	if (ev is InputEventKey and ev.pressed and isTyping):
		var unicode = char(ev.unicode)
		var scancode = OS.get_scancode_string(ev.scancode)
		if (scancode == "BackSpace"):
			entry.text = entry.text.substr(0,entry.text.length() - 1)
		elif (scancode == "Enter" or scancode == "Kp Enter"):
			isTyping = false
			closed()
		else:
			entry.text += unicode
	elif (ev is InputEventMouseButton and ev.button_index == 1 and ev.pressed):
		var last = isTyping
		isTyping = entry.get_node("Button").is_hovered()
		if (!isTyping and last):
			closed()
