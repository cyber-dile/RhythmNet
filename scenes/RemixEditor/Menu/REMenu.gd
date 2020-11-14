extends Node2D

onready var bg = $Background
onready var ex = $Bounds/Scroller/Example
onready var scroller = $Bounds/Scroller

var enabled = false setget setEnabled
var parent
var track
var remixes = []
var selected = 0
var state = "picker"

var defaultRemix = {
	"name": "Custom Remix",
	"icon": "res://assets/icons/remix.svg",
	"description": "A custom remix!",
	"id": "custom-remix",
	"intro": "",
	"music": "",
	"bpm": [],
	"tags": [],
	"markers": []
}

func toEditor():
	inputStopped = true
	parent.editing = remixes[selected].directory
	parent.fadeTo(Color(1,1,1,0),Color(1,1,1,1))
	yield(get_tree().create_timer(1),"timeout")
	setEnabled(false)
	get_node("../Editor").enabled = true

var inputStopped = true
func back():
	inputStopped = true
	parent.fadeMusic()
	parent.fadeTo(Color(1,1,1,0),Color(1,1,1,1))
	Sound.play(preload("res://assets/sfx/back.ogg"))
	yield(get_tree().create_timer(1),"timeout")
	Scenes.change(load("res://scenes/Games/Games.tscn"))

func _ready():
	scroller.remove_child(ex)
	parent = get_node("..")

func newRemix():
	var dat = parse_json(to_json(defaultRemix))
	dat.id = Util.Math.uuid()
	var dir = Directory.new()
	dir.open("user://remixes/")
	if (!dir.dir_exists(dat.id)):
		dir.make_dir(dat.id)
	Data.write("user://remixes/" + dat.id + "/data.json",dat)
	updateRemixes()

func createPanel(count, remix = null):
	if (remix == null):
		remix = {
			"name": "Create Remix",
			"icon": "res://assets/icons/create.svg",
			"directory": ""
		}
	remix.icon = Data.loadImage(Data.global(remix.directory, remix.icon))
	
	var x = 130 + 60 * fmod(count,5)
	var y = 30 + 60 * floor(count/5)
	var nex = ex.duplicate()
	nex.position = Vector2(x,y)
	nex.name = str(count)
	nex.get_node("Tooltip/Label").text = remix.name
	var tsz = nex.get_node("Tooltip/Label").get_font("font").get_string_size(remix.name).x
	nex.get_node("Tooltip").size = Vector2(tsz + 16,16)
	if (remix.icon):
		nex.get_node("Sprite").texture = remix.icon
		var isz = remix.icon.get_size()
		nex.get_node("Sprite").scale = Vector2(48.0/isz.x,48.0/isz.y)
	scroller.add_child(nex)

func scrollBy(n): selected = clamp(selected + n, 0, remixes.size())

func aPressed():
	match state:
		"picker":
			Sound.play(preload("res://assets/sfx/select.ogg"))
			if (selected != remixes.size()):
				toEditor()
			else:
				newRemix()

func bPressed():
	match state:
		"picker":
			back()
			Playlists.refreshRemixes()

func dir(x,y):
	match state:
		"picker":
			scrollBy(x - 5 * y)

func updateRemixes():
	for child in scroller.get_children():
		child.free()
	
	var dir = Directory.new()
	dir.open("user://remixes/")
	dir.list_dir_begin()
	remixes = []
	while true:
		var remix = dir.get_next()
		if (remix == ""):
			break
		elif (remix != "." and remix != ".."):
			var data = Data.read("user://remixes/" + remix + "/data.json")
			data.directory = "user://remixes/" + remix + "/"
			remixes.append(data)
	var c = 0
	for remix in remixes:
		createPanel(c, remix)
		c += 1
	createPanel(c)

var t = 0
func _process(dt):
	if (enabled):
		t += dt
		var beat = track.getBeat()
		bg.gridn = floor(fmod(beat/2,2))
		bg.get_node("Border").scroll = fmod(t/4.0,1.0)
		bg.get_node("Border2").scroll = -fmod(t/4.0,1.0)
		bg.shift = Vector2(fmod(t/8,1) * 64,fmod(t/8,1) * 64)
		for panel in scroller.get_children():
			if (panel.name == str(selected)):
				panel.get_node("BG").modulate = Color(1,1,.5 + .125 * sin(t * 2 * PI),1)
				panel.get_node("Tooltip").visible = (state == "picker")
			else:
				panel.get_node("BG").modulate = Color(1,1,1,1)
				panel.get_node("Tooltip").visible = false
		var L = Util.Math.aLerp(.25,1.0/30.0,dt)
		var npos = Vector2(0,-60 * clamp(floor(selected/5 - 1),0,max(1,floor((scroller.get_children().size() - 6)/5)) - 1))
		scroller.position = scroller.position.linear_interpolate(npos,L)

func setEnabled(new):
	match (new):
		true:
			visible = true
			inputStopped = false
			parent.fadeTo(Color(1,1,1,1),Color(1,1,1,0))
		false:
			visible = false
	enabled = new
	track = parent.track
	updateRemixes()

func _input(ev):
	if (!inputStopped):
		if (ev.is_action_pressed("a")):
			aPressed()
		elif (ev.is_action_pressed("b")):
			bPressed()
		elif (ev.is_action_pressed("left")):
			dir(-1,0)
		elif (ev.is_action_pressed("right")):
			dir(1,0)
		elif (ev.is_action_pressed("up")):
			dir(0,1)
		elif (ev.is_action_pressed("down")):
			dir(0,-1)
