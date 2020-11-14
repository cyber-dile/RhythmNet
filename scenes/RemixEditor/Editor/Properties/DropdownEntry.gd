extends Control

onready var scroller = $DropdownBox/VScrollBar
onready var scroll = $Entries/Scroller
onready var box = $DropdownBox
onready var entries = $Entries
onready var entry = $Entry
onready var ex = $DropdownEx

func getValue():
	return entry.text

func picked(tx):
	entry.text = tx
	entries.visible = false
	box.visible = false

func setValue(val, data = null):
	entry.text = val
	for child in scroll.get_children():
		child.free()
	for i in range(data.size()):
		var newEx = ex.duplicate()
		newEx.rect_position = Vector2(0,15 * i)
		newEx.text = data[i]
		newEx.get_node("Button").connect("button_down",self,"picked",[data[i]])
		newEx.visible = true
		scroll.add_child(newEx)
	scroller.visible = data.size() > 5
	scroller.max_value = 15 * data.size() - 30
	color()

func toggleOpen():
	entries.visible = not entries.visible
	box.visible = not box.visible

func color():
	var color = get_node("../../Topbar/Top").self_modulate
	get_node("Node2D").self_modulate = color
	get_node("DropdownBox").self_modulate = color
	entries.visible = false
	box.visible = false

func _ready():
	color()
	entry.get_node("Button").connect("button_down",self,"toggleOpen")

func _process(dt):
	scroll.position = Vector2(0,-scroller.value)
