extends Node

var categories = []
var markers = []

func createTag(name, duration, hits, properties):
	var newTag = Tag.new()
	newTag.tag = name
	newTag.category = "Game"
	newTag.duration = duration
	newTag.hits = hits
	newTag.properties = properties
	return newTag

func resizeStar(tag, scene):
	tag.set("Length",max(1,tag.get("Length")))
	tag.duration = tag.get("Length")
	tag.hits[0] = tag.duration

func scanTags(playfield):
	var game = playfield.game
	for i in range(game.tags.size()):
		var tag = game.tags[i]
		if (tag.category == "Game"):
			match tag.tag:
				"Skill Star":
					playfield.sequencer.add(tag.beat, playfield, "updateSkillStar", tag)
				"Display Artist":
					if (playfield.startPos <= tag.beat):
						playfield.sequencer.add(tag.beat, playfield, "displayArtist", tag)
						playfield.sequencer.add(tag.beat+4, playfield, "closeArtist", tag)
				"SFX":
					playfield.sequencer.add(tag.beat, playfield, "playSFX", tag.get("File"))
				"Forgive Misses":
					playfield.sequencer.add(playfield.beatOffset(tag.beat), playfield, "forgiveMisses")
				"Punish Misses":
					playfield.sequencer.add(playfield.beatOffset(tag.beat), playfield, "punishMisses")
				"Autoplay On":
					playfield.sequencer.add(playfield.beatOffset(tag.beat), playfield, "setAutoplay", true)
				"Autoplay Off":
					playfield.sequencer.add(playfield.beatOffset(tag.beat), playfield, "setAutoplay", false)
				"End Game":
					playfield.sequencer.add(playfield.beatOffset(tag.beat), playfield, "songDone")

func _ready():
	var dir = Directory.new()
	dir.open("res://source/Subgames/")
	dir.list_dir_begin()
	
	categories.append([
		"Game", preload("res://assets/game/perfect.svg"),
		[
			createTag("Skill Star",4,[4],[
				["Length","number",4],
				["Animation","boolean",true]
			]),
			createTag("Display Artist",4,[],[
				["Song","string","Song Name"],
				["Artist","string","Song by ARTIST"]
			]),
			createTag("SFX",.5,[],[["File","string","blip.ogg"]]),
			createTag("Forgive Misses",1,[],[]),
			createTag("Punish Misses",1,[],[]),
			createTag("Autoplay On",1,[],[]),
			createTag("Autoplay Off",1,[],[]),
			createTag("End Game",1,[],[])
		],
		{
			"Skill Star": "resizeStar"
		},
		self
	])
	
	while true:
		var game = dir.get_next()
		if (game == ""):
			return
		elif (game != ".." and game != "."):
			var script = load("res://source/Subgames/" + game + "/Tags.gd").new()
			add_child(script)
			var tags = script.getTags()
			tags.append(script)
			categories.append(tags)
	dir.end()
	
	var bpmMarker = Marker.new()
	bpmMarker.id = "bpm"
	markers.append(bpmMarker)
