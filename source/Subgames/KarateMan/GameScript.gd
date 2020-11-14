extends Control

onready var bg = $Zoom/Background
onready var zoom = $Zoom
onready var joe = $Zoom/Joe
onready var obex = $Zoom/Object
onready var snowbg = $Zoom/BGSnow
onready var snowfg = $Zoom/FGSnow

var playfield
var game
var sequencer
var bobbing = -1
var zoomed = true
var ingame = false
var hitLast = false
var punchTime = 0
var lastPunch
var rpunchTime = 0
var currentHead = "Normal"

var objects = []

var zoomInPos = Vector2(320,140)
var zoomInScale = Vector2(1.25,1.25)
var zoomOutPos = Vector2(320,172)
var zoomOutScale = Vector2(1,1)

var faces = {
	"Normal": preload("res://source/Subgames/KarateMan/images/joeHead.png"),
	"Blush": preload("res://source/Subgames/KarateMan/images/joeBlush.png"),
	"Bold": preload("res://source/Subgames/KarateMan/images/joeBold.png"),
	"Distraught": preload("res://source/Subgames/KarateMan/images/joeDistraught.png"),
	"Excited": preload("res://source/Subgames/KarateMan/images/joeExcited.png"),
	"Frowning": preload("res://source/Subgames/KarateMan/images/joeFrown.png"),
	"Shocked": preload("res://source/Subgames/KarateMan/images/joeShocked.png"),
	"Smiling": preload("res://source/Subgames/KarateMan/images/joeSmile.png")
}

func _ready():
	set_process(false)
	zoom.remove_child(obex)
	sequencer = Sequencer.new()

func setHead(tag):
	var head = (tag.get("Hit?") if hitLast else tag.get("Missed?"))
	joe.get_node("Head").texture = faces[head]
	if (tag.get("Duration") <= 0):
		currentHead = head
	return true

func resetHead(tag):
	joe.get_node("Head").texture = faces[currentHead]
	return true

func punchAnim(right):
	lastPunch = playfield.track.getBeat()
	if (right):
		punchTime = 0 # 4 2 2 1
		rpunchTime = 9.0/60
	else:
		punchTime = 5.0/60 # 2 1 1 1
		rpunchTime = 0

func doPunch():
	var closest
	joe.get_node("Torso/Punch1/Effect").visible = false
	joe.get_node("RPunch1/Effect").visible = false
	for obj in objects:
		if (obj.type == "normal" and obj.state == "air" and (not closest or obj.tag.beat < closest.tag.beat)):
			closest = obj
	if (closest):
		var check = closest.hit()
		var shape = closest.tag.get("Shape")
		punchAnim(shape != "Pot" and shape != "Lightbulb" and shape != "Orange Lightbulb" and shape != "Blue Lightbulb")
		return check
	else:
		punchAnim(false)
		return [0,"Miss"]

func setVisible(new):
	visible = new
	return true

func setBackground(tag):
	bg.modulate = Color(tag.get("Red")/255.0,tag.get("Green")/255.0,tag.get("Blue")/255.0,1)
	for child in bg.get_children():
		child.visible = false
	match tag.get("Type"):
		"Solid":
			pass
		"Lines":
			bg.get_node("Lines").visible = true
		"Circles":
			bg.get_node("Circles").visible = true
		"Custom":
			var tx = Data.loadImage(Data.global(playfield.directory.get_current_dir(),tag.get("Image Path")))
			if (tx):
				var sz = tx.get_size()
				bg.get_node("Custom").texture = tx
				bg.get_node("Custom").scale = Vector2(640/sz.x,344/sz.y)
				bg.get_node("Custom").visible = true
	return true

func setSnow(tag):
	var snowEnabled = tag.get("Enabled")
	var windSpeed = tag.get("Wind Speed")
	var windAngle = 90 + tag.get("Wind Angle")
	snowbg.emitting = snowEnabled
	snowfg.emitting = snowEnabled
	snowbg.process_material.direction = Vector3(cos(windAngle * PI/180),sin(windAngle * PI/180),0)
	snowbg.process_material.initial_velocity = windSpeed
	return true

func setTint(tag):
	joe.modulate = Color(tag.get("Red")/255.0,tag.get("Green")/255.0,tag.get("Blue")/255.0,1)
	obex.modulate = joe.modulate
	return true

func setTheme(tag):
	return true

func setObjVisible(dat):
	get_node("Zoom/" + dat[0]).visible = dat[1]
	return true

func outSound(tag):
	match tag.get("Sound"):
		"Throw":
			Sound.play(preload("res://source/Subgames/KarateMan/sfx/potout.ogg"))
		"Offbeat":
			Sound.play(preload("res://source/Subgames/KarateMan/sfx/offbeatpotout.ogg"))
		"Lightbulb":
			Sound.play(preload("res://source/Subgames/KarateMan/sfx/bulbout.ogg"))
	return true

func setZoom(val):
	zoomed = val
	return true

func hitSound(tag):
	match tag.get("Shape"):
		"Pot":
			Sound.play(preload("res://source/Subgames/KarateMan/sfx/pothit.ogg"))
		"Rock":
			Sound.play(preload("res://source/Subgames/KarateMan/sfx/rock.ogg"))
		"Ball":
			Sound.play(preload("res://source/Subgames/KarateMan/sfx/soccerHit.ogg"))
		"Alien":
			Sound.play(preload("res://source/Subgames/KarateMan/sfx/alienhit.ogg"))
		"Cooking Pot":
			Sound.play(preload("res://source/Subgames/KarateMan/sfx/cookingPot.ogg"))
		"Lightbulb", "Orange Lightbulb", "Blue Lightbulb":
			Sound.play(preload("res://source/Subgames/KarateMan/sfx/bulbhit.ogg"))
	return true

func sendObject(tag):
	outSound(tag)
	var new = obex.duplicate()
	new.setupNormal(tag)
	zoom.add_child(new)
	objects.append(new)
	return true

func hit(x):
	Sound.play(preload("res://source/Subgames/KarateMan/sfx/hit3cue1.ogg"))
	return true

func three(x):
	Sound.play(preload("res://source/Subgames/KarateMan/sfx/hit3cue2.ogg"))
	return true

func four(x):
	Sound.play(preload("res://source/Subgames/KarateMan/sfx/hit4.ogg"))
	return true

func punchSFX(x):
	Sound.play(preload("res://source/Subgames/KarateMan/sfx/punchkick1.ogg"))
	return true

func kickSFX(x):
	Sound.play(preload("res://source/Subgames/KarateMan/sfx/punchkick2.ogg"))
	return true

func objectOut(tag):
	outSound(tag)
	return true

func setBobbing(new):
	bobbing = new
	return true

func setup(pf, gm):
	playfield = pf
	game = gm
	for i in range(game.tags.size()):
		var tag = game.tags[i]
		if (tag.category == "Karate Man"):
			match tag.tag:
				"Enter Game":
					playfield.sequencer.add(tag.beat,playfield,"startGame","KarateMan")
				"Leave Game":
					playfield.sequencer.add(tag.beat,playfield,"endGame","KarateMan")
				"Game Visible":
					sequencer.add(tag.beat,self,"setVisible",true)
				"Game Invisible":
					sequencer.add(tag.beat,self,"setVisible",false)
				"Set Theme":
					sequencer.add(tag.beat,self,"setTheme",tag)
				"Set Tint":
					sequencer.add(tag.beat,self,"setTint",tag)
				"Set Background":
					sequencer.add(tag.beat,self,"setBackground",tag)
				"Set Snow":
					sequencer.add(tag.beat,self,"setSnow",tag)
				"Start Bobbing":
					sequencer.add(tag.beat,self,"setBobbing",fmod(tag.beat,1.0))
				"Stop Bobbing":
					var down = (1 if tag.get("Head Down") else 0)
					sequencer.add(tag.beat,self,"setBobbing",-1 - down)
				"Zoom Out":
					sequencer.add(tag.beat,self,"setZoom",false)
				"Normal Zoom":
					sequencer.add(tag.beat,self,"setZoom",true)
				"Set Face":
					sequencer.add(playfield.beatOffset(tag.beat),self,"setHead",tag)
					if (tag.get("Duration") > 0):
						sequencer.add(tag.beat + tag.get("Duration"),self,"resetHead",tag)
				"Object":
					if (pf.startPos <= tag.beat):
						sequencer.add(tag.beat,self,"sendObject",tag)
				"Kick":
					if (pf.startPos <= tag.beat):
						var punchBeat = tag.beat + 1
						var kickBeat = tag.beat + 1.75
						sequencer.add(punchBeat,self,"punchSFX",null)
						sequencer.add(kickBeat,self,"kickSFX",null)
						
				"Combo":
					if (pf.startPos <= tag.beat):
						pass
						# add gameplay
				"Grr!":
					if (pf.startPos <= tag.beat):
						sequencer.add(tag.beat,self,"setObjVisible",["Grr",true])
						sequencer.add(tag.beat+1,self,"setObjVisible",["Grr",false])
				"Hit 3!":
					if (pf.startPos <= tag.beat):
						sequencer.add(tag.beat,self,"hit",null)
						sequencer.add(tag.beat+.5,self,"three",null)
						sequencer.add(tag.beat-.5,self,"setObjVisible",["Hit3",true])
						sequencer.add(tag.beat+1.5,self,"setObjVisible",["Hit3",false])
				"Hit 4!":
					if (pf.startPos <= tag.beat):
						sequencer.add(tag.beat,self,"hit",null)
						sequencer.add(tag.beat+.5,self,"four",null)
						sequencer.add(tag.beat-.5,self,"setObjVisible",["Hit4",true])
						sequencer.add(tag.beat+1.5,self,"setObjVisible",["Hit4",false])
				"!":
					if (pf.startPos <= tag.beat):
						sequencer.add(tag.beat,self,"setObjVisible",["Marks",true])
						sequencer.add(tag.beat+1,self,"setObjVisible",["Marks",false])

func _process(dt):
	snowbg.speed_scale = 0
	snowfg.speed_scale = 0
	if (!playfield.paused and playfield.playing):
		snowbg.speed_scale = 1
		snowfg.speed_scale = 1
		var beat = playfield.track.getBeat()
		bg.get_node("Lines").texture = (preload("res://source/Subgames/KarateMan/images/lines1.png") if fmod(beat,2) < 1 else preload("res://source/Subgames/KarateMan/images/lines2.png"))
		bg.get_node("Circles").texture = (preload("res://source/Subgames/KarateMan/images/circle1.png") if fmod(beat,2) < 1 else preload("res://source/Subgames/KarateMan/images/circle2.png"))
		var L = Util.Math.aLerp(.125,1.0/30.0,dt)
		zoom.scale = zoom.scale.linear_interpolate((zoomInScale if zoomed else zoomOutScale),L)
		zoom.position = zoom.position.linear_interpolate((zoomInPos if zoomed else zoomOutPos),L)
		
		var bob = 1
		var punchMod = false
		if (bobbing >= 0):
			bob = fmod(beat - bobbing,1.0)
		else:
			bob = 2 + bobbing
		if (lastPunch != null and (beat - lastPunch) < .5):
			bob = beat - lastPunch
			punchMod = true
		else:
			lastPunch = null
		
		joe.get_node("Head").visible = true
		joe.get_node("Torso").visible = true
		for ch in joe.get_node("Torso").get_children():
			ch.visible = false
		joe.get_node("Torso/Arm").visible = true
		joe.get_node("RPunch1").visible = false
		joe.get_node("RPunch2").visible = false
		joe.get_node("RPunch3").visible = false
		joe.get_node("RPunch4").visible = false
		if (punchTime > 0):
			joe.get_node("Torso/Arm").visible = false
			var frame = int(ceil(punchTime * 60))
			match frame:
				5,4:
					joe.get_node("Torso/Punch1").visible = true
				3:
					joe.get_node("Torso/Punch2").visible = true
				2:
					joe.get_node("Torso/Punch3").visible = true
				1:
					joe.get_node("Torso/Punch4").visible = true
			punchTime -= dt
		elif (rpunchTime > 0):
			joe.get_node("Head").visible = false
			joe.get_node("Torso").visible = false
			var frame = int(ceil(rpunchTime * 60))
			match frame:
				9,8,7,6:
					joe.get_node("RPunch1").visible = true
					joe.get_node("RPunch1/Whoosh").visible = (frame >= 8)
				5,4:
					joe.get_node("RPunch2").visible = true
				3,2:
					joe.get_node("RPunch3").visible = true
				1:
					joe.get_node("RPunch4").visible = true
			rpunchTime -= dt
		
		if (bob < .5):
			bob = 1 - sin(bob * PI)
		else:
			bob = 0
		punchMod = (bob if punchMod else 0)
		joe.get_node("Head").position = Vector2(0,-160) + Vector2(3 * bob + 3 * punchMod,3 * bob + 3 * punchMod)
		joe.get_node("Torso").position = Vector2(0,-105) + Vector2(3 * punchMod,3 * bob)
		joe.get_node("RightLeg").position = Vector2(18,-40) + Vector2(punchMod,0)
		
		var removed = 0
		
		for i in range(objects.size()):
			var obj = objects[i - removed]
			obj.upd(beat, dt)
			if (beat > obj.tag.beat + 4):
				obj.queue_free()
				objects.remove(i - removed)
				removed += 1

func _input(ev):
	if (ingame and not playfield.paused and playfield.playing):
		if (ev.is_action_pressed("a")):
			var check = doPunch()
			if (check):
				var off = check[0]
				var rank = check[1]
				if !(off == 0 and rank == "Miss"):
					playfield.displayTiming(off,rank)
					playfield.push(off)
