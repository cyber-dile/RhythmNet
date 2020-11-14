extends Control

onready var bg = $Background
onready var zoom = $Zoom
onready var exTick = $Zoom/Tick
onready var scroller = $Bounds/Scroller
onready var error = $Error
onready var thisBeat = $ThisBeat
onready var fade = $Fade
onready var props = $Properties
onready var markerex = $Bounds/Scroller/Markers/Marker
onready var markers = $Bounds/Scroller/Markers
onready var tagex = $Bounds/Scroller/Tags/Tag
onready var tags = $Bounds/Scroller/Tags
onready var trackend = $Bounds/Scroller/TrackEnd
onready var trackbegin = $Bounds/Scroller/TrackBegin
onready var tooltip = $Tooltip
onready var remixSettings = $RemixSettings
onready var settings = $EditorSettings
onready var tagMenu = $NewTag
onready var markerMenu = $NewMarker

onready var gameScroller = $NewTag/Panel/Games/Scroller
onready var gameEx = $NewTag/Panel/Games/Scroller/GameEx
onready var gameBar = $NewTag/Panel/Games/VScrollBar
onready var tagScroller = $NewTag/Panel/Tags/Scroller
onready var tagBar = $NewTag/Panel/Tags/VScrollBar
onready var newTagEx = $NewTag/Panel/Tags/Scroller/TagEx

var enabled = false setget setEnabled
var parent
var parentTrack

var snaps = [
	1,2,3,4,6,8,12,16,24,32
]

var remix
var track
var state = "track"
var bgscroll = Vector2()
var pos = 0
var speed = 4
var tickSZ = 80
var moveDir = 0
var snapIndex = 0
var snapDenom = 1
var hasMusic = false
var selected = []
var shiftHeld = false
var remixDir
var beautifier
var themes
var thm = 0 # default
var propertyTypes = {}

var defaultRemix = {
	"name": "Custom Remix",
	"icon": "res://assets/icons/remix.svg",
	"description": "A custom remix!",
	"id": "custom-remix",
	"intro": "",
	"music": "",
	"bpm": [],
	"map": {}
}

var topbuttons = [
	[
		"Settings",
		"Editor Settings",
		"openSettings",
		null
	],
	[
		"Remix",
		"Remix Settings",
		"openRemixSettings",
		null
	],
	[
		"Test",
		"Test Remix",
		"testRemix",
		null
	],
	[
		"Beginning",
		"Beginning of Song",
		"seekBeginning",
		null
	],
	[
		"Play",
		"Play Song",
		"togglePlaying",
		null
	],
	[
		"End",
		"End of Song",
		"seekEnd",
		null
	],
	[
		"Snap",
		"Beat Snap",
		"increaseSnap",
		"decreaseSnap"
	],
	[
		"Quit",
		"Quit Editor",
		"toMenu",
		null
	],
	[
		"Save",
		"Save Remix",
		"saveRemix",
		null
	]
]

var bottombuttons = [
	[
		"Marker",
		"Add Marker",
		"openMarkers",
		null
	],
	[
		"Tag",
		"Add Tag",
		"openTags",
		null
	],
	[
		"Properties",
		"Change Properties",
		"openProperties",
		null
	],
	[
		"Duplicate",
		"Duplicate Selection",
		"duplicateSelection",
		null
	],
	[
		"Delete",
		"Delete Selection",
		"deleteSelection",
		null
	],
	[
		"Move",
		"Move Selection",
		"moveSelection",
		null
	]
]

var inputStopped = true
func toMenu():
	inputStopped = true
	parent.fadeTo(Color(1,1,1,0),Color(1,1,1,1))
	Sound.play(preload("res://assets/sfx/back.ogg"))
	yield(get_tree().create_timer(1),"timeout")
	setEnabled(false)
	get_node("../Menu").enabled = true

func openProperties():
	for prop in props.get_node("Panel").get_children():
		prop.free()
	if (selected.size() == 1):
		selected[0].getProperties()
	if (selected.size() == 0):
		err("You need to select an object to edit its properties!")
	elif (selected.size() > 1):
		err("You can only edit one object at a time!")
	elif (selected[0].properties.size() == 0):
		err("This object has no editable properties!")
	else:
		Sound.play(preload("res://assets/sfx/select.ogg"))
		fade.visible = true
		props.visible = true
		state = "properties"
		props.get_node("Topbar/Object").text = selected[0].toString()
		var properties = selected[0].properties
		for c in range(properties.size()):
			var prop = properties[c]
			var type = prop[1]
			var data = null
			if (prop.size() > 3):
				data = prop[3]
			var newObj = propertyTypes[type].duplicate()
			newObj.name = prop[0]
			props.get_node("Panel").add_child(newObj)
			newObj.rect_position = Vector2(10,10 + 30 * c)
			newObj.get_node("Label").text = prop[0]
			newObj.setValue(prop[2], data)

func closeProperties():
	var obj = selected[0]
	var properties = obj.properties
	for prop in props.get_node("Panel").get_children():
		for v in properties:
			if (v[0] == prop.name):
				v[2] = prop.getValue()
		prop.free()
	obj.updateProps(self)
	Sound.play(preload("res://assets/sfx/back.ogg"))
	fade.visible = false
	props.visible = false
	state = "track"

func openRemixSettings():
	Sound.play(preload("res://assets/sfx/select.ogg"))
	fade.visible = true
	remixSettings.visible = true
	remixSettings.get_node("Panel/RemixName").setValue(remix.name)
	remixSettings.get_node("Panel/RemixDesc").setValue(remix.description)
	remixSettings.get_node("Panel/RemixIcon").setValue(remix.icon)
	remixSettings.get_node("Panel/RemixMusic").setValue(remix.music)
	remixSettings.get_node("Panel/RemixID").setValue(remix.id)
	remixSettings.get_node("Panel/RemixIntro").setValue(remix.intro)
	state = "remixSettings"

func closeRemixSettings():
	Sound.play(preload("res://assets/sfx/back.ogg"))
	fade.visible = false
	remixSettings.visible = false
	remix.name = remixSettings.get_node("Panel/RemixName").getValue()
	remix.description = remixSettings.get_node("Panel/RemixDesc").getValue()
	remix.icon = remixSettings.get_node("Panel/RemixIcon").getValue()
	setMusic(remixSettings.get_node("Panel/RemixMusic").getValue())
	remix.id = remixSettings.get_node("Panel/RemixID").getValue()
	remix.intro = remixSettings.get_node("Panel/RemixIntro").getValue()
	state = "track"

func openSettings():
	Sound.play(preload("res://assets/sfx/select.ogg"))
	fade.visible = true
	settings.visible = true
	var list = []
	for t in themes:
		list.append(t[0])
	settings.get_node("Panel/Theme").setValue(themes[thm][0],list)
	state = "settings"

func closeSettings():
	Data.getSave().editor.theme = thm
	Data.saveGame()
	Sound.play(preload("res://assets/sfx/back.ogg"))
	fade.visible = false
	settings.visible = false
	state = "track"

func openMarkers():
	Sound.play(preload("res://assets/sfx/select.ogg"))
	fade.visible = true
	markerMenu.visible = true
	state = "newMarker"

func closeMarkers():
	fade.visible = false
	markerMenu.visible = false
	state = "track"

func pickTag(tag):
	var nt = newTag()
	nt.deserialize(tag.serialize())
	nt.place(self)
	nt.update(self)
	Sound.play(preload("res://assets/sfx/back.ogg"))
	closeTags()

func pickGame(game):
	for child in tagScroller.get_children():
		child.free()
	for i in range(game[2].size()):
		var tag = game[2][i]
		var nt = newTagEx.duplicate()
		nt.get_node("Tag").text = tag.tag
		nt.get_node("Category").text = tag.category.to_upper()
		nt.rect_position = Vector2(0,17 * i)
		if (fmod(i,2) == 1):
			nt.color = nt.color.linear_interpolate(Color(0,0,0,1),.1)
		tagScroller.add_child(nt)
		nt.get_node("Button").connect("button_down", self, "pickTag", [tag])

func openTags():
	var games = EditorEnums.categories
	for child in gameScroller.get_children():
		child.free()
	for i in range(games.size()):
		var game = games[i]
		var ng = gameEx.duplicate()
		ng.get_node("Label").text = game[0]
		ng.get_node("Sprite").texture = game[1]
		var sz = game[1].get_size()
		ng.get_node("Sprite").scale = Vector2(13/sz.x,13/sz.y)
		ng.rect_position = Vector2(0,17 * i)
		if (fmod(i,2) == 1):
			ng.color = ng.color.linear_interpolate(Color(0,0,0,1),.1)
		gameScroller.add_child(ng)
		ng.get_node("Button").connect("button_down", self, "pickGame", [game])
	Sound.play(preload("res://assets/sfx/select.ogg"))
	fade.visible = true
	tagMenu.visible = true
	state = "newTag"

func closeTags():
	fade.visible = false
	tagMenu.visible = false
	state = "track"

func _ready():
	parent = get_node("..")
	markers.remove_child(markerex)
	tags.remove_child(tagex)
	zoom.remove_child(exTick)
	gameScroller.remove_child(gameEx)
	tagScroller.remove_child(newTagEx)
	for n in range(-10,11):
		var ntick = exTick.duplicate()
		zoom.add_child(ntick)
		ntick.name = str(n)
		ntick.rect_position = Vector2(n * 80 - .5,0)
	for child in props.get_node("Panel").get_children():
		props.get_node("Panel").remove_child(child)
		child.visible = true
		propertyTypes[child.name] = child
	
	remixDir = Directory.new()
	track = Track.new()
	track.stream.connect("finished",self,"stopPlaying")
	add_child(track)
	beautifier = JSONBeautifier.new()
	themes = get_node("Settings").themes

var errors = 0
func err(tx):
	Sound.play(preload("res://assets/sfx/back.ogg"))
	errors += 1
	var thisError = errors
	error.text = tx
	yield(get_tree().create_timer(1.5),"timeout")
	if (thisError == errors):
		error.text = ""

func setMusic(newDir):
	remix.music = newDir
	hasMusic = false
	if (remixDir.file_exists(newDir) and newDir.ends_with(".ogg")):
		var path = Data.global(parent.editing, newDir)
		var audio = AudioStreamOGGVorbis.new()
		var data = Data.readOgg(path)
		audio.set_data(data)
		track.setAudio(audio)
		hasMusic = track.stream.stream != null

func deleteSelection():
	Sound.play(preload("res://assets/sfx/back.ogg"))
	for obj in selected:
		if (obj.canDelete()):
			obj.delete(self)
		else:
			obj.obj.get_node("Selected").visible = false
	selected = []

func moveSelection():
	Sound.play(preload("res://assets/sfx/blip.ogg")).volume_db = 7
	var toBeat = round(pos * snapDenom)/snapDenom
	var earliest = INF
	for obj in selected:
		if (obj is Tag):
			earliest = min(earliest, obj.beat)
	var off = toBeat - earliest
	for obj in selected:
		if (obj is Tag):
			obj.beat += off
			obj.update(self)

func duplicateSelection():
	Sound.play(preload("res://assets/sfx/select.ogg"))
	var newSelected = []
	for obj in selected:
		var duplicated = obj.copy(self)
		if (duplicated):
			newSelected.append(duplicated)
		obj.obj.get_node("Selected").visible = false
	selected = newSelected
	for obj in selected:
		obj.obj.get_node("Selected").visible = true

func sortBPM(a,b):
	return a.time < b.time

func updateBPM():
	remix.bpm = []
	var markers = []
	for marker in remix.markers:
		if (marker.id == "bpm" or marker.id == "zero"):
			markers.append(marker)
	markers.sort_custom(self,"sortBPM")
	for marker in markers:
		remix.bpm.append([marker.time,marker.bpm])
	var newBPM = parse_json(to_json(remix.bpm))
	track.setBPM(newBPM)

func testRemix():
	if (hasMusic and remix.bpm.size() >= 1):
		Sound.play(preload("res://assets/sfx/enter_game.ogg"))
		visible = false
		state = "testing"
		parentTrack.pause()
		var newPlayfield = Game.play(parent.editing)
		var startPos = -10000
		if (shiftHeld):
			startPos = pos
		newPlayfield.start(startPos)
		var data = yield(newPlayfield, "done")
		newPlayfield.queue_free()
		parentTrack.play()
		visible = true
		state = "track"
	else:
		err("The remix needs a sound file to do this!")

func startPlaying():
	if (hasMusic and remix.bpm.size() >= 1):
		updateBPM()
		track.play(max(track.getTime(pos)/1000,0))
		parentTrack.pause()
		state = "playing"
	else:
		err("The remix needs a sound file to do this!")

func stopPlaying():
	Sound.play(preload("res://assets/sfx/back.ogg"))
	track.stop()
	parentTrack.resume()
	state = "track"

func seekBeginning():
	Sound.play(preload("res://assets/sfx/blip.ogg")).volume_db = 7
	pos = track.getBeat(0)

func seekEnd():
	if (hasMusic):
		Sound.play(preload("res://assets/sfx/blip.ogg")).volume_db = 7
		pos = track.getBeat(track.stream.stream.get_length() * 1000)
	else:
		err("The remix needs a sound file to do this!")

func setSelection(obj):
	if selected.size() > 0 and not shiftHeld:
		for ob in selected:
			ob.obj.get_node("Selected").visible = false
		selected = [obj]
		obj.obj.get_node("Selected").visible = true
	elif shiftHeld:
		var ind = selected.find(obj)
		if (ind >= 0):
			selected.remove(ind)
			obj.obj.get_node("Selected").visible = false
		else:
			selected.append(obj)
			obj.obj.get_node("Selected").visible = true
	else:
		selected = [obj]
		obj.obj.get_node("Selected").visible = true

func increaseSnap():
	Sound.play(preload("res://assets/sfx/blip.ogg")).volume_db = 7
	var tx = get_node("Topbar/Snap/Label")
	if (!shiftHeld):
		snapIndex += 1
		if (snapIndex >= snaps.size()):
			snapIndex = snaps.size() - 1
		snapDenom = snaps[snapIndex]
	else:
		snapDenom = min(snapDenom + 1,32)
		var ind = snaps.find(snapDenom)
		if (ind > 0):
			snapIndex = ind
	tx.text = "1/" + str(snapDenom)

func decreaseSnap():
	Sound.play(preload("res://assets/sfx/blip.ogg")).volume_db = 7
	var tx = get_node("Topbar/Snap/Label")
	if (!shiftHeld):
		snapIndex -= 1
		if (snapIndex < 0):
			snapIndex = 0
		snapDenom = snaps[snapIndex]
	else:
		snapDenom = max(snapDenom - 1,1)
		var ind = snaps.find(snapDenom)
		if (ind > 0):
			snapIndex = ind
	tx.text = "1/" + str(snapDenom)

func nudge(dir):
	if (shiftHeld):
		dir *= 4
	var markers = 0
	for obj in selected:
		if (obj is Marker):
			markers +=1
			if (markers > 1):
				err("You can only shift one marker at a time!")
				return
	Sound.play(preload("res://assets/sfx/blip.ogg")).volume_db = 7
	for obj in selected:
		obj.nudge(self, dir)

func shift(dir):
	if (dir < 0):
		var least = 6
		for obj in selected:
			if (obj is Tag):
				least = min(least,obj.layer)
		if (least == 0):
			return
	else:
		var most = -1
		for obj in selected:
			if (obj is Tag):
				most = max(most,obj.layer)
		if (most == 5):
			return
	Sound.play(preload("res://assets/sfx/blip.ogg")).volume_db = 7
	for obj in selected:
		obj.shift(self, dir)

func saveRemix():
	var data = {
		"name": remix.name,
		"icon": remix.icon,
		"description": remix.description,
		"id": remix.id,
		"music": remix.music,
		"intro": remix.intro,
		"bpm": remix.bpm,
		"tags": [],
		"markers": []
	}
	for tag in remix.tags:
		data.tags.append(tag.serialize())
	for marker in remix.markers:
		data.markers.append(marker.serialize())
	Data.writeRaw(parent.editing + "data.json", beautifier.beautify_json(to_json(data)))
	Sound.play(preload("res://assets/sfx/enter_game.ogg"))

func togglePlaying():
	match state:
		"track":
			startPlaying()
		"playing":
			stopPlaying()

func aPressed():
	match state:
		"track":
			startPlaying()
		"playing":
			stopPlaying()

func keyEvent(ev):
	if (ev.scancode == KEY_SHIFT):
		shiftHeld = ev.pressed
	if (ev.pressed):
		match ev.scancode:
			KEY_LEFT:
				match state:
					"track":
						nudge(-1)
			KEY_RIGHT:
				match state:
					"track":
						nudge(1)
			KEY_UP:
				match state:
					"track":
						shift(-1)
			KEY_DOWN:
				match state:
					"track":
						shift(1)

func bPressed():
	match state:
		"newMarker":
			Sound.play(preload("res://assets/sfx/back.ogg"))
			closeMarkers()
		"newTag":
			Sound.play(preload("res://assets/sfx/back.ogg"))
			closeTags()

func mouseClicked(ev):
	if (ev.pressed):
		match state:
			"track":
				for tab in topbuttons:
					var node = get_node("Topbar/" + tab[0])
					if (node.is_hovered()):
						if (ev.button_index == 1 and tab[2]):
							call(tab[2])
						elif (ev.button_index == 2 and tab[3]):
							call(tab[3])
						return
				for tab in bottombuttons:
					var node = get_node("Bottombar/" + tab[0])
					if (node.is_hovered()):
						if (ev.button_index == 1 and tab[2]):
							call(tab[2])
						elif (ev.button_index == 2 and tab[3]):
							call(tab[3])
						return
				for marker in remix.markers:
					var node = marker.obj.get_node("Button")
					if (node.is_hovered()):
						if (ev.button_index == 1):
							setSelection(marker)
						return
				for tag in remix.tags:
					var node = tag.obj.get_node("Button")
					if (node.is_hovered()):
						if (ev.button_index == 1):
							setSelection(tag)
						return
				if (ev.button_index == 1):
					for ob in selected:
						ob.obj.get_node("Selected").visible = false
					selected = []
			"playing":
				var node = get_node("Topbar/Play")
				if (node.is_hovered()):
					if (ev.button_index == 1):
						stopPlaying()
					return
			"properties":
				if (ev.button_index == 1):
					var node = props.get_node("Button")
					if (node.is_hovered()):
						closeProperties()
						return
			"remixSettings":
				if (ev.button_index == 1):
					var node = remixSettings.get_node("Button")
					if (node.is_hovered()):
						closeRemixSettings()
						return
					node = remixSettings.get_node("Delete")
					if (node.is_hovered()):
						closeRemixSettings()
						remixDir.list_dir_begin()
						while true:
							var item = remixDir.get_next()
							if (item == ""):
								break
							elif (item != ".." and item != "."):
								remixDir.remove(item)
						remixDir.list_dir_end()
						remixDir.remove("")
						toMenu()
						return
			"settings":
				if (ev.button_index == 1):
					var node = settings.get_node("Button")
					if (node.is_hovered()):
						closeSettings()
						return
			"newMarker":
				if (ev.button_index == 1):
					var node = markerMenu.get_node("Button")
					if (node.is_hovered()):
						Sound.play(preload("res://assets/sfx/back.ogg"))
						closeMarkers()
						return
					node = markerMenu.get_node("Panel/BPM")
					if (node.is_hovered()):
						Sound.play(preload("res://assets/sfx/select.ogg"))
						var marker = newMarker()
						marker.id = "bpm"
						marker.place(self)
						marker.update(self)
						closeMarkers()
						return
			"newTag":
				if (ev.button_index == 1):
					var node = tagMenu.get_node("Button")
					if (node.is_hovered()):
						Sound.play(preload("res://assets/sfx/back.ogg"))
						closeTags()
						return

func dir(x,y):
	match state:
		"track", "playing", "properties":
			if (y == 0):
				moveDir = clamp(moveDir + x,-1,1)
			else:
				speed = clamp(speed * pow(2,y),4,128)

func dirRel(x,y):
	match state:
		"track", "playing", "properties":
			if (y == 0):
				moveDir = clamp(moveDir - x,-1,1)

var t = 0
func _process(dt):
	if (enabled):
		t += dt
		match state:
			"track":
				pos = pos + dt * speed * moveDir
			"playing":
				pos = track.getBeat()
		scroller.position = Vector2(320 - pos * tickSZ,10)
		zoom.rect_position = Vector2(320 - Util.Math.pmod(pos,1) * tickSZ,120)
		bgscroll = Vector2(pos * 120,0)
		bg.region_rect = Rect2(-512 * t/8 + bgscroll.x,-512 * t/8 + bgscroll.y,2560,1440)
		thisBeat.get_node("Beat").text = "Beat " + str(floor(pos))
		if (track.bpm.size() == 0):
			thisBeat.get_node("Time").text = "-:--"
		else:
			var t = floor(track.getTime(pos)/1000)
			var mod = ("-" if t < 0 else "")
			t = abs(t)
			var s = Util.Math.pmod(floor(t),60)
			if (str(s).length() < 2):
				s = "0" + str(s)
			var m = floor(t/60)
			thisBeat.get_node("Time").text = mod + str(m) + ":" + str(s)
		trackend.visible = hasMusic
		trackbegin.visible = hasMusic and abs(track.getBeat(0)) > 1e-4
		if (hasMusic and track.stream.stream):
			trackend.rect_position = Vector2(track.getBeat(track.stream.stream.get_length() * 1000) * 80 - 1,-48)
			trackbegin.rect_position = Vector2(track.getBeat(0) * 80 - 1,-48)
		tooltip.text = ""
		for tab in topbuttons:
			var node = get_node("Topbar/" + tab[0])
			if (node.is_hovered()):
				tooltip.text = tab[1]
		for tab in bottombuttons:
			var node = get_node("Bottombar/" + tab[0])
			if (node.is_hovered()):
				tooltip.text = tab[1]
		match state:
			"properties":
				var node = props.get_node("Button")
				if (node.is_hovered()):
					tooltip.text = "Go Back"
			"settings":
				var node = settings.get_node("Button")
				if (node.is_hovered()):
					tooltip.text = "Go Back"
				var val = settings.get_node("Panel/Theme").getValue()
				for i in range(themes.size()):
					var t = themes[i]
					if (t[0] == val):
						var lastThm = thm
						thm = i
						if (lastThm != thm):
							updateTheme()
			"remixSettings":
				var node = remixSettings.get_node("Button")
				if (node.is_hovered()):
					tooltip.text = "Go Back"
				node = remixSettings.get_node("Delete")
				if (node.is_hovered()):
					tooltip.text = "Delete Remix"
			"newTag":
				var node = tagMenu.get_node("Button")
				if (node.is_hovered()):
					tooltip.text = "Go Back"
				gameBar.visible = gameScroller.get_children().size() > 10
				tagBar.visible = tagScroller.get_children().size() > 10
				gameBar.max_value = 17 * gameScroller.get_children().size()
				tagBar.max_value = 17 * tagScroller.get_children().size()
				gameScroller.position = Vector2(0,-gameBar.value)
				tagScroller.position = Vector2(0,-tagBar.value)
			"newMarker":
				var node = markerMenu.get_node("Button")
				if (node.is_hovered()):
					tooltip.text = "Go Back"

func updateTheme():
	var colors = themes[thm]
	if (colors[0] == "Custom Theme"):
		var custom = remixDir.file_exists("user://theme.json")
		if (custom):
			custom = Data.read("user://theme.json")
			for i in range(custom.size()):
				colors[i+1] = custom[i]
	bg.modulate = Color(colors[1])
	get_node("Topbar").color = Color(colors[2])
	get_node("Bottombar").color = Color(colors[2])
	settings.get_node("Topbar/Top").self_modulate = Color(colors[2])
	remixSettings.get_node("Topbar/Top").self_modulate = Color(colors[2])
	markerMenu.get_node("Topbar/Top").self_modulate = Color(colors[2])
	tagMenu.get_node("Topbar/Top").self_modulate = Color(colors[2])
	props.get_node("Topbar/Top").self_modulate = Color(colors[2])
	for node in settings.get_node("Panel").get_children():
		node.color()
	for button in get_node("Topbar").get_children():
		if (button.name != "BG"):
			button.modulate = Color(colors[3])
	for button in get_node("Bottombar").get_children():
		if (button.name != "BG"):
			button.modulate = Color(colors[3])
	markerMenu.get_node("Button").self_modulate = Color(colors[3])
	tagMenu.get_node("Button").self_modulate = Color(colors[3])
	remixSettings.get_node("Button").self_modulate = Color(colors[3])
	remixSettings.get_node("Delete").self_modulate = Color(colors[3])
	settings.get_node("Button").self_modulate = Color(colors[3])
	props.get_node("Button").self_modulate = Color(colors[3])
	for i in range(1,7):
		get_node("Track/Color" + str(i)).color = Color(colors[i+3])
	get_node("Bounds/Scroller/TrackBegin").color = Color(colors[10])
	get_node("Bounds/Scroller/TrackEnd").color = Color(colors[11])
	for marker in remix.markers:
		marker.update(self)
	for tag in remix.tags:
		tag.update(self)

func newTag():
	var tag = Tag.new()
	var obj = tagex.duplicate()
	tags.add_child(obj)
	obj.visible = true
	tag.obj = obj
	remix.tags.append(tag)
	return tag

func newMarker():
	var marker = Marker.new()
	var obj = markerex.duplicate()
	markers.add_child(obj)
	obj.visible = true
	marker.obj = obj
	remix.markers.append(marker)
	return marker

func makeMarkerZero():
	for marker in remix.markers:
		if (marker.id == "zero"):
			return
	
	var newMarker = Marker.new()
	newMarker.id = "zero"
	newMarker.obj = scroller.get_node("Zero")
	
	remix.markers.append(newMarker)
	newMarker.update(self)

func setEnabled(new):
	match (new):
		true:
			visible = true
			inputStopped = false
			parent.fadeTo(Color(1,1,1,1),Color(1,1,1,0))
		false:
			visible = false
	enabled = new
	for child in tags.get_children():
		child.free()
	for child in markers.get_children():
		child.free()
	parentTrack = parent.track
	tooltip.text = ""
	thm = Data.getSave().editor.theme
	remix = null
	selected = []
	if (new):
		pos = 0
		remixDir.open(parent.editing)
		remix = Data.read(parent.editing + "data.json")
		var newTags = []
		for i in range(remix.tags.size()):
			var v = remix.tags[i]
			var t = newTag()
			t.deserialize(v)
			newTags.append(t)
		var newMarkers = []
		for i in range(remix.markers.size()):
			var v = remix.markers[i]
			var m = newMarker()
			newMarkers.append(m)
			m.deserialize(v)
			if (m.id == "zero"):
				m.obj.free()
				m.obj = scroller.get_node("Zero")
		remix.markers = newMarkers
		remix.tags = newTags
		makeMarkerZero()
		setMusic(remix.music)
		updateBPM()
		for m in remix.markers:
			m.update(self)
		for t in remix.tags:
			t.update(self)
		updateTheme()

func _input(ev):
	if (!inputStopped):
		if (ev is InputEventKey):
			keyEvent(ev)
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
		elif (ev.is_action_released("left")):
			dirRel(-1,0)
		elif (ev.is_action_released("right")):
			dirRel(1,0)
		elif (ev.is_action_released("up")):
			dirRel(0,1)
		elif (ev.is_action_released("down")):
			dirRel(0,-1)
		elif (ev is InputEventMouseButton):
			mouseClicked(ev)
