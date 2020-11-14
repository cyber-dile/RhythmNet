extends Node2D

onready var bg = $Background
onready var selector = $Selector

var enabled = false setget setEnabled
var parent
var track

var inputStopped = true
func back():
	inputStopped = true
	parent.fadeTo(Color(1,1,1,0),Color(1,1,1,1))
	Sound.play(preload("res://assets/sfx/back.ogg"))
	yield(get_tree().create_timer(1),"timeout")
	setEnabled(false)
	get_node("../MainMenu").enabled = true

func selected(playlist, column, item):
	parent.fadeMusic()
	Sound.play(preload("res://assets/sfx/enter_game.ogg"))
	parent.fadeTo(Color(1,1,1,1),Color(1,1,1,0),.25)
	yield(get_tree().create_timer(1),"timeout")
	parent.fadeTo(Color(0,0,0,0),Color(0,0,0,1),1)
	yield(get_tree().create_timer(2),"timeout")
	visible = false
	get_node("../Fade").visible = false
	
	var game = Playlists.playlists[playlist].games[column][item].data
	var newPlayfield = Game.play(game)
	newPlayfield.start()
	var data = yield(newPlayfield, "done")
	get_node("../Fade").visible = true
	parent.fadeTo(Color(0,0,0,1),Color(0,0,0,0),.5)
	
	if (data.completed):
		var existing = Data.getSave().completed.get(data.id)
		existing = (existing if existing != null else 0)
		if (data.percent >= 80):
			Data.getSave().completed[data.id] = max(existing,1)
		if (data.perfect):
			Data.getSave().completed[data.id] = max(existing,2)
		if (data.star):
			Data.getSave().skillStars[data.id] = true
		Data.saveGame()
	
	newPlayfield.queue_free()
	parent.track.stream.stop()
	parent.track.stream.play()
	parent.track.stream.volume_db = 7
	visible = true
	selector.enabled = true
	selector.playlist = playlist
	selector.column = column
	selector.item = item
	selector.state = "viewing"
	selector.locked = false
	selector.view()

func _ready():
	parent = get_node("..")
	selector.connect("leave", self, "back")
	selector.connect("selected", self, "selected")

func setEnabled(new):
	match (new):
		true:
			visible = true
			inputStopped = false
			parent.fadeTo(Color(1,1,1,1),Color(1,1,1,0))
		false:
			visible = false
	enabled = new
	selector.enabled = new
	track = parent.track

var t = 0
func _process(dt):
	if (enabled):
		t += dt
		t = fmod(t,32)
		var beat = track.getBeat()
		bg.gridn = floor(fmod(beat/2,2))
		bg.self_modulate = Color.from_hsv(t/32,.75,1)

func _input(ev):
	if (!inputStopped):
		pass
