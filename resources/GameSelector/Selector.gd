extends Control

signal leave
signal selected

var playlists
var playlist = 0
var column = 0
var item = 0

var state = "picker"
var enabled = false setget setEnabled
var locked

var superbTexture = preload("res://assets/menu/superbMedal.png")
var perfectTexture = preload("res://assets/menu/perfectMedal.png")

onready var ex = $Example
onready var scroller = $Scroller

onready var pm = $PlaylistMenu
onready var pmscroller = $PlaylistMenu/Bounds/Scroller
onready var pmex = $PlaylistMenu/Bounds/Scroller/Example

onready var examine = $Examine

func _ready():
	remove_child(ex)
	pmscroller.remove_child(pmex)
	pm.position = Vector2(-120,180)
	pm.visible = true
	examine.position = Vector2(920,180)
	examine.visible = true
	
	playlists = Playlists.playlists
	var c = 0
	for playlist in playlists:
		var playlistNode = Node2D.new()
		playlistNode.name = str(c)
		playlistNode.visible = false
		get_node("Scroller/Playlists").add_child(playlistNode)
		
		var npmex = pmex.duplicate()
		pmscroller.add_child(npmex)
		npmex.name = str(c)
		npmex.get_node("Name").text = playlist.name
		npmex.get_node("Desc").text = playlist.desc
		npmex.position = Vector2(0,100 * c)
		
		var x = 0
		for column in playlist.games:
			var y = 0
			for game in column:
				var nex = ex.duplicate()
				nex.position = Vector2(x,y)
				nex.name = str(round(x/60)) + " " + str(round(-y/60))
				nex.get_node("Tooltip/Label").text = game.name
				var tsz = nex.get_node("Tooltip/Label").get_font("font").get_string_size(game.name).x
				nex.get_node("Tooltip").size = Vector2(tsz + 16,16)
				if (game.icon):
					nex.get_node("Sprite").texture = game.icon
					var isz = game.icon.get_size()
					nex.get_node("Sprite").scale = Vector2(48.0/isz.x,48.0/isz.y)
				playlistNode.add_child(nex)
				y -= 60
			x += 60
		c += 1
	
	get_node("Scroller/Playlists/" + str(playlist)).visible = true

func changePlaylist():
	state = "playlist"

func changeMods():
	pass

func setPlaylist(new):
	get_node("Scroller/Playlists/" + str(playlist)).visible = false
	playlist = new
	get_node("Scroller/Playlists/" + str(playlist)).visible = true

func updateGames():
	var count = 0
	for p in playlists:
		var playlistNode = get_node("Scroller/Playlists/" + str(count))
		var column = 0
		for c in p.games:
			var row = 0
			for game in c:
				var nex = playlistNode.get_node(str(column) + " " + str(row))
				nex.get_node("Medal").visible = false
				nex.get_node("Star").visible = false
				if (game.action == "gameInfo"):
					var id = game.id
					var ptype = Data.getSave().completed.get(id)
					if (ptype != null):
						match int(ptype):
							1:
								nex.get_node("Medal").visible = true
								nex.get_node("Medal").texture = superbTexture
							2:
								nex.get_node("Medal").visible = true
								nex.get_node("Medal").texture = perfectTexture
					if (Data.getSave().skillStars.get(id)):
						nex.get_node("Star").visible = true
				row += 1
			column += 1
		count += 1
				

func direction(x,y):
	match state:
		"picker":
			column += x
			item += y
			if (column < 0):
				column = playlists[playlist].games.size() - 1
			if (column >= playlists[playlist].games.size()):
				column = 0
			if (item < 0):
				item = playlists[playlist].games[column].size() - 1
			if (item >= playlists[playlist].games[column].size()):
				item = 0
		"playlist":
			if (y != 0):
				var np = playlist - y
				if (np < 0):
					np = playlists.size() - 1
				elif (np >= playlists.size()):
					np = 0
				setPlaylist(np)

func view():
	var game = playlists[playlist].games[column][item]
	var thisIcon = get_node("Scroller/Playlists/" + str(playlist) + "/" + str(column) + " " + str(item))
	var icon = examine.get_node("Icon")
	icon.get_node("Sprite").texture = thisIcon.get_node("Sprite").texture
	icon.get_node("Sprite").scale = thisIcon.get_node("Sprite").scale
	icon.get_node("Medal").visible = thisIcon.get_node("Medal").visible
	icon.get_node("Medal").texture = thisIcon.get_node("Medal").texture
	icon.get_node("Star").visible = thisIcon.get_node("Star").visible
	
	examine.get_node("Name").text = game.name
	examine.get_node("Desc").text = game.description
	examine.get_node("Controls").visible = !locked
	examine.get_node("Locked").visible = locked

func aPressed():
	match state:
		"picker":
			Sound.play(preload("res://assets/sfx/select.ogg"))
			var frame = playlists[playlist].games[column][item]
			match frame.action:
				"call":
					call(frame.data)
				"locked":
					state = "viewing"
					locked = true
					view()
				"gameInfo":
					state = "viewing"
					locked = false
					view()
		"playlist":
			Sound.play(preload("res://assets/sfx/select.ogg"))
			state = "picker"
		"viewing":
			if (!locked): # Let the spawner of this pick whether to use select.ogg or enter_game.ogg
				setEnabled(false)
				emit_signal("selected", playlist, column, item)
			else:
				Sound.play(preload("res://assets/sfx/back.ogg"))

func bPressed():
	Sound.play(preload("res://assets/sfx/back.ogg"))
	match state:
		"picker":
			setEnabled(false)
			emit_signal("leave")
		"playlist":
			state = "picker"
		"viewing":
			state = "picker"

func setEnabled(new):
	if (new):
		state = "picker"
		updateGames()
	enabled = new

var t = 0
func _process(dt):
	if (enabled):
		t += dt
		t = fmod(t,1)
		for panel in scroller.get_node("Playlists/" + str(playlist)).get_children():
			if (panel.position == Vector2(60 * column,-60 * item)):
				panel.get_node("BG").modulate = Color(1,1,.5 + .125 * sin(t * 2 * PI),1)
				panel.get_node("Tooltip").visible = (state == "picker")
			else:
				panel.get_node("BG").modulate = Color(1,1,1,1)
				panel.get_node("Tooltip").visible = false
		for panel in pmscroller.get_children():
			if (panel.name == str(playlist)):
				panel.get_node("BG").modulate = Color(1,1,.5 + .125 * sin(t * 2 * PI),1)
			else:
				panel.get_node("BG").modulate = Color(0,0,0,1)
		var npos
		var ppos = Vector2(-120,180)
		var pspos = pmscroller.position
		var expos = Vector2(920,180)
		match state:
			"picker":
				npos = Vector2(320 - 60 * column,300)
			"playlist":
				npos = Vector2(480,300) # the right 3/4 of the screen
				ppos = Vector2(240,180)
				pspos = Vector2(180,40 - 100 * playlist + 200 * (playlist/(playlists.size() - 1.0)))
			"viewing":
				npos = Vector2(180 - column * 60,180 + item * 60)
				expos = Vector2(440,180)
		var L = Util.Math.aLerp(.25,1.0/30.0,dt)
		scroller.position = scroller.position.linear_interpolate(npos,L)
		pm.position = pm.position.linear_interpolate(ppos,L)
		pmscroller.position = pmscroller.position.linear_interpolate(pspos,L)
		examine.position = examine.position.linear_interpolate(expos,L)
		if get_node("../Background"):
			get_node("../Background").shift = Vector2((scroller.position.x - 320) * .75,(scroller.position.y - 300) * .75)

func _input(ev):
	if (enabled):
		if (ev.is_action_pressed("a")):
			aPressed()
		elif (ev.is_action_pressed("b")):
			bPressed()
		elif (ev.is_action_pressed("left")):
			direction(-1,0)
		elif (ev.is_action_pressed("right")):
			direction(1,0)
		elif (ev.is_action_pressed("down")):
			direction(0,-1)
		elif (ev.is_action_pressed("up")):
			direction(0,1)
