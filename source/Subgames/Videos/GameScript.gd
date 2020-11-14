extends VideoPlayer

onready var bg = $Zoom/Background

var playfield
var game
var sequencer
var bobbing
var ingame = false

func _ready():
	set_process(false)
	sequencer = Sequencer.new()

func startVideo(path):
	var dat = VideoStreamWebm.new()
	dat.set_file(Data.global(playfield.directory.get_current_dir() + "/",path))
	stream = dat
	play()
	visible = true
	return true

func stopVideo(path):
	stop()
	visible = false
	return true

func setup(pf, gm):
	playfield = pf
	game = gm
	for i in range(game.tags.size()):
		var tag = game.tags[i]
		if (tag.category == "Videos"):
			match tag.tag:
				"Start Video":
					if (pf.startPos <= tag.beat):
						playfield.sequencer.add(tag.beat,self,"startVideo",tag.get("File Path"))
				"Stop Video":
					if (pf.startPos <= tag.beat):
						playfield.sequencer.add(tag.beat,self,"stopVideo",null)
