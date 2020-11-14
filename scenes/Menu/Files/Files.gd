extends Control

onready var ex = $Scroller/Example
onready var bar = $ScrollBar
onready var fade = $Fade
onready var tween = $Tween

var selected = 0
var maxFiles = -1
var button = 2
var newName = ""
var substate = "pick"
var beatsLeft = 8
var files = -1

func updateFiles():
	for child in get_node("Scroller").get_children():
		child.free()
	files = Data.saveData.saveSlots.size()
	for n in range(files):
		var file = Data.saveData.saveSlots[n]
		var nex = ex.duplicate()
		nex.name = str(n)
		get_node("Scroller").add_child(nex)
		nex.position = Vector2(320,80 + 120 * n)
		nex.modulate = Color(1,1,1,1 if selected == n else 0)
		nex.get_node("File").visible = true
		nex.get_node("File/Filename").text = file.name
		nex.get_node("File/Completion").text = str(file.progress) + "%"
	maxFiles = files - 1
	if (files < 10):
		var nex = ex.duplicate()
		nex.name = str(files)
		get_node("Scroller").add_child(nex)
		nex.get_node("NewGame").visible = true
		nex.position = Vector2(320,80 + 120 * files)
		nex.modulate = Color(1,1,1,1 if selected == files else 0)
		maxFiles = files

func _ready():
	get_node("Scroller").remove_child(ex)
	ex.visible = true
	ex.get_node("File").visible = false
	ex.get_node("NewGame").visible = false

func backToMenu():
	var scene = get_node("..")
	Sound.play(preload("res://assets/sfx/back.ogg"))
	scene.state = "transition"
	scene.fadeTo(Color(1,1,1,0),Color(1,1,1,1))
	yield(get_tree().create_timer(1),"timeout")
	visible = false
	scene.state = "menu"
	get_node("../Intro").visible = true
	scene.fadeTo(Color(1,1,1,1),Color(1,1,1,0))

func makeNewGame():
	Sound.play(preload("res://assets/sfx/select.ogg"))
	Data.newSave("New File")
	updateFiles()

func startGame():
	var scene = get_node("..")
	Sound.play(preload("res://assets/sfx/enter_game.ogg"))
	scene.state = "transition"
	scene.fadeTo(Color(1,1,1,0),Color(1,1,1,1))
	var stream = get_node("..").track.stream
	tween.interpolate_property(stream, "volume_db", 0, -80, 1, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(1),"timeout")
	Data.thisSlot = selected
	Scenes.change(preload("res://scenes/Games/Games.tscn"))

func deleteFile():
	pass

func keyInput(ev: InputEventKey):
	if (substate == "rename"):
		if (ev.pressed):
			var scancode = OS.get_scancode_string(ev.scancode)
			var unicode = char(ev.unicode)
			if (scancode == "BackSpace"):
				newName = newName.substr(0,newName.length() - 1)
			elif (scancode == "Enter" or scancode == "Kp Enter"):
				Data.saveData.saveSlots[selected].name = newName
				Data.saveGame()
				updateFiles()
				changeState("file", true)
			else:
				var oldName = newName
				newName = newName + unicode
				var font = fade.get_node("Rename/FileName").get_font("font")
				if (font.get_string_size(newName).x > 320):
					newName = oldName
			fade.get_node("Rename/FileName").text = newName

func changeState(new,back = false):
	if (back):
		Sound.play(preload("res://assets/sfx/back.ogg"))
	else:
		Sound.play(preload("res://assets/sfx/select.ogg"))
	substate = new

func aPressed():
	match substate:
		"pick":
			if (selected == maxFiles and (files == 0 or maxFiles == files)):
				makeNewGame()
			else:
				changeState("file")
		"file":
			match button:
				1:
					fade.get_node("Rename").visible = true
					fade.get_node("Delete").visible = false
					newName = Data.saveData.saveSlots[selected].name
					fade.get_node("Rename/FileName").text = newName
					changeState("rename")
				2:
					startGame()
				3:
					fade.get_node("Delete").visible = true
					fade.get_node("Rename").visible = false
					beatsLeft = 8
					fade.get_node("Delete/Beats").text = str(beatsLeft)
					changeState("delete")
		"delete":
			var track = get_node("..").track
			var beat = floor(track.getBeat() + .5)
			var offset = track.getAudioTime() - track.getTime(beat)
			if (abs(offset) < 100):
				beatsLeft -= 1
				fade.get_node("Delete/Beats").text = str(beatsLeft)
				if (beatsLeft == 0):
					Data.deleteSave(selected)
					updateFiles()
					changeState("pick",true)

func bPressed():
	match substate:
		"pick":
			backToMenu()
		"file":
			changeState("pick",true)
		"delete":
			changeState("file",true)

func direction(x,y):
	match substate:
		"pick":
			if (y != 0):
				selected -= y
				if (selected < 0):
					selected = maxFiles
				elif (selected > maxFiles):
					selected = 0
		"file":
			if (x != 0):
				button += x
				if (button > 3):
					button = 1
				if (button < 1):
					button = 3

func _input(ev):
	var state = get_node("..").state
	if (state == "files"):
		if (ev is InputEventKey):
			keyInput(ev)
		if (ev.is_action_pressed("a")):
			aPressed()
		elif (ev.is_action_pressed("b")):
			bPressed()
		elif (ev.is_action_pressed("up")):
			direction(0,1)
		elif (ev.is_action_pressed("left")):
			direction(-1,0)
		elif (ev.is_action_pressed("down")):
			direction(0,-1)
		elif (ev.is_action_pressed("right")):
			direction(1,0)

var t = 0.0
func _process(dt):
	t += dt
	match substate:
		"pick":
			bar.modulate = Color(1,1,1,min(1,bar.modulate.a + 8 * dt))
			for n in range(0,maxFiles+1):
				var file = get_node("Scroller/" + str(n))
				file.visible = true
				if (n == selected):
					file.modulate = Color(1,1,.75 + .125 * sin(t * 2 * PI),1)
				else:
					file.modulate = Color(1,1,1,min(1,file.modulate.a + 8 * dt))
				file.get_node("File/Buttons").visible = false
		_:
			bar.modulate = Color(1,1,1,max(0,bar.modulate.a - 8 * dt))
			for n in range(0,maxFiles+1):
				var file = get_node("Scroller/" + str(n))
				if (n == selected):
					file.modulate = Color(1,1,1,1)
					file.get_node("File/Buttons").visible = true
					for i in range(3):
						var j = i + 1
						var b = file.get_node("File/Buttons/" + str(j))
						if (j == button):
							b.modulate = Color(1,1,.75 + .125 * sin(t * 2 * PI),1)
						else:
							b.modulate = Color(1,1,1,1)
				else:
					file.modulate = Color(1,1,1,max(0,file.modulate.a - 8 * dt))
	
	if (maxFiles >= 0):
		var pos = clamp(-120 * (selected - 1),-120 * maxFiles,0)
		if (maxFiles <= 1):
			pos = 0
		if (substate != "pick"):
			pos = -120 * selected
		var cur = get_node("Scroller").position.y
		get_node("Scroller").position = Vector2(0,cur + (pos - cur) * Util.Math.aLerp(.5,1.0/30.0,dt))
	
	bar.position = Vector2(560,180 - maxFiles * 15)
	for n in range(10):
		var i = n + 1
		var diamond = bar.get_node(str(i))
		diamond.visible = n <= maxFiles
		diamond.scale = Vector2(10,10) * (2 if n == selected else 1)
	
	if (substate == "rename" or substate == "delete"):
		fade.modulate = Color(1,1,1,min(1,fade.modulate.a + 8 * dt))
	else:
		fade.modulate = Color(1,1,1,max(0,fade.modulate.a - 8 * dt))
