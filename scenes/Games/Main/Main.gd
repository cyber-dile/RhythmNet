extends Node2D

onready var bg = $Background
onready var ex = $Menus/Example

var enabled = false setget setEnabled
var parent
var track

var menus = [
	{
		"color": Color(1,.27,.27),
		"text": "Singleplayer",
		"desc": "Play some rhythm games!",
		"sprite": preload("res://assets/menu/playGames.svg"),
		"do": "toGames"
	},
	{
		"color": Color(.3,.6,1),
		"text": "Netplay",
		"desc": "Play with your friends!",
		"sprite": preload("res://assets/menu/netplay.svg"),
		"do": "toNetplay"
	},
	{
		"color": Color(.27,1,.27),
		"text": "Bar",
		"desc": "Check out the mementos you've found along the way.",
		"sprite": preload("res://assets/menu/bar.svg"),
		"do": "toBar"
	},
	{
		"color": Color(.1,.1,.5),
		"text": "Settings",
		"desc": "Change some of the game's settings.",
		"sprite": preload("res://assets/menu/settings.svg"),
		"do": "toSettings"
	},
	{
		"color": Color(1,.9,.27),
		"text": "Credits",
		"desc": "See who helped make RhythmNet possible.",
		"sprite": preload("res://assets/menu/credits.svg"),
		"do": "toCredits"
	},
	{
		"color": Color(.9,.5,.27),
		"text": "Back to Menu",
		"desc": "Go back to the file select menu.",
		"sprite": preload("res://assets/menu/backToMenu.svg"),
		"do": "toMenu"
	}
]
var menuObjs = []
var selected = 0

var inputStopped = true
func toMenu():
	inputStopped = true
	parent.fadeMusic()
	parent.fadeTo(Color(1,1,1,0),Color(1,1,1,1))
	Sound.play(preload("res://assets/sfx/select.ogg"))
	yield(get_tree().create_timer(1),"timeout")
	Scenes.change(load("res://scenes/Menu/Menu.tscn"))

func toSettings():
	inputStopped = true
	parent.fadeTo(Color(1,1,1,0),Color(1,1,1,1))
	Sound.play(preload("res://assets/sfx/select.ogg"))
	yield(get_tree().create_timer(1),"timeout")
	setEnabled(false)

func toGames():
	inputStopped = true
	parent.fadeTo(Color(1,1,1,0),Color(1,1,1,1))
	Sound.play(preload("res://assets/sfx/select.ogg"))
	yield(get_tree().create_timer(1),"timeout")
	setEnabled(false)
	get_node("../RhythmGames").enabled = true

func toNetplay():
	inputStopped = true
	parent.fadeTo(Color(1,1,1,0),Color(1,1,1,1))
	Sound.play(preload("res://assets/sfx/select.ogg"))
	yield(get_tree().create_timer(1),"timeout")
	setEnabled(false)
	#enabled = true

func toBar():
	inputStopped = true
	parent.fadeMusic()
	parent.fadeTo(Color(1,1,1,0),Color(1,1,1,1))
	Sound.play(preload("res://assets/sfx/select.ogg"))
	yield(get_tree().create_timer(1),"timeout")
	Scenes.change()

func toCredits():
	inputStopped = true
	parent.fadeMusic()
	parent.fadeTo(Color(1,1,1,0),Color(1,1,1,1))
	Sound.play(preload("res://assets/sfx/select.ogg"))
	yield(get_tree().create_timer(1),"timeout")
	Scenes.change(preload("res://scenes/Credits/Credits.tscn"))

func toEditor():
	inputStopped = true
	parent.fadeMusic()
	parent.fadeTo(Color(1,1,1,0),Color(1,1,1,1))
	Sound.play(preload("res://assets/sfx/select.ogg"))
	yield(get_tree().create_timer(1),"timeout")
	Scenes.change(preload("res://scenes/RemixEditor/RemixEditor.tscn"))

func colorMenu(obj, dat):
	var sz = dat.sprite.get_size()
	obj.get_node("ColorRect").self_modulate = dat.color
	obj.get_node("Label").text = dat.text
	obj.get_node("Sprite").texture = dat.sprite
	obj.get_node("Sprite").scale = Vector2(60/sz.x,60/sz.y)

func _ready():
	parent = get_node("..")
	get_node("Menus").remove_child(ex)
	var OSs = ["Windows","OSX","HTML5","UWP","X11"] # PC operating systems
	if (OSs.has(OS.get_name())):
		menus.insert(2,{
			"color": Color(1,.27,.75),
			"text": "Remix Editor",
			"desc": "Make your own remixes!",
			"sprite": preload("res://assets/menu/editor.svg"),
			"do": "toEditor"
		})
	for i in range(0,7):
		var nex = ex.duplicate()
		get_node("Menus").add_child(nex)
		nex.name = str(i)
		nex.position = Vector2(160 * (i - 3), (i - 3) * 160 * tan(5 * PI/180))
		menuObjs.append(nex)
	updateMenus()

func updateMenus():
	var c = 0
	for obj in menuObjs:
		var this = Util.Math.pmod(selected, menus.size()) + c - 3
		if this < 0:
			this += menus.size()
		elif this >= menus.size():
			this -= menus.size()
		colorMenu(obj, menus[this])
		if (c == 3):
			get_node("Desc").text = menus[this].desc
		c += 1

func move(off):
	selected = selected + off
	get_node("Menus").position = get_node("Menus").position + Vector2(160 * off, 0)
	updateMenus()

var t = 0
func _process(dt):
	if (enabled):
		t += dt
		t = fmod(t,32)
		var beat = track.getBeat()
		bg.gridn = floor(fmod(beat/2,2))
		bg.self_modulate = Color.from_hsv(t/32,.75,1)
		var c = 0
		get_node("Menus").position = get_node("Menus").position.linear_interpolate(Vector2(320,180),Util.Math.aLerp(.25,1.0/30.0,dt))
		for obj in menuObjs:
			var off = sin((t/4.0 + (c + selected)/4.0) * 2 * PI) * 16
			var globalX = get_node("Menus").position.x + obj.position.x - 320
			obj.position = Vector2(obj.position.x,globalX * tan(5 * PI/180) + off)
			var wrongColor = obj.get_node("ColorRect").self_modulate.linear_interpolate(Color(0,0,0,1),.5)
			obj.get_node("BG").self_modulate = (Color(1,1,1,1) if c == 3 else wrongColor)
			c += 1
		bg.shift = Vector2(get_node("Menus").position.x - 320 + selected * 32,0)

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

func _input(ev):
	if (!inputStopped):
		if ev.is_action_pressed("left"):
			move(-1)
		elif ev.is_action_pressed("right"):
			move(1)
		if ev.is_action_pressed("a"):
			var currentMenu = Util.Math.pmod(selected,menus.size())
			call(menus[currentMenu].do)
