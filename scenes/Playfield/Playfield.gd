extends Node

signal input(off, rank)
signal done(data)
signal intro()

onready var perfect = $Game/Perfect
onready var skillStar = $Game/SkillStar
onready var videoPlayer = $Intro
onready var subGames = $Subgames
onready var tw = $Tween
onready var fade = $Fade
onready var pauseMenu = $Paused
onready var artist = $Artist

var playing = false
var paused = false
var isPerfect = true
var gotStar = false
var gettingStar
var autoplay = false
var punish = true
var lastHit
var directory
var game
var track
var introFile
var sequencer
var pauseInd = 0
var totalHits = 0
var totalOffset = 0
var actualHits = 0
var startPos = 0 # beat
var activeGames = []
var gameInfo = {
	"reason": "N/A",
	"completed": false,
	"perfect": false,
	"star": false,
	"percent": 0,
	"id": ""
}
var beat

func tagSort(a,b):
	return (a.beat <= b.beat)

func displayTiming(o,r):
	get_node("TimingTop").time(o,r)
	get_node("TimingBottom").time(o,r)

func startGame(name):
	var sub = subGames.get_node(name)
	if (activeGames.find(sub) < 0):
		activeGames.append(sub)
		sub.ingame = true
		sub.set_process(true)
	return true

func endGame(name):
	var sub = subGames.get_node(name)
	var ind = activeGames.find(sub)
	if (ind >= 0):
		activeGames.remove(ind)
		sub.sequencer.update(beat)
		sub.ingame = false
		sub.set_process(false)
	return true

func setup(dir):
	directory.open(dir)
	game = Data.read(dir + "data.json")
	gameInfo.id = game.id
	var newTags = []
	for i in range(game.tags.size()):
		var v = game.tags[i]
		var t = Tag.new()
		t.deserialize(v)
		newTags.append(t)
	newTags.sort_custom(self,"tagSort")
	var newMarkers = []
	for i in range(game.markers.size()):
		var v = game.markers[i]
		var m = Marker.new()
		newMarkers.append(m)
		m.deserialize(v)
	game.markers = newMarkers
	game.tags = newTags

func setMusic():
	var path = Data.global(directory.get_current_dir() + "/", game.music)
	var audio = AudioStreamOGGVorbis.new()
	var data = Data.readOgg(path)
	audio.set_data(data)
	track.setAudio(audio)

func beatOffset(beat): # returns the time (in beat form) DIRECTLY AFTER the beat provided has been input
	return track.getBeat(track.getTime(beat) + 64) # 64ms is right after the cutoff of 63ms

func updateSkillStar(tag):
	if (gettingStar == null):
		gettingStar = true
		skillStar.visible = true
	if (gettingStar == false):
		skillStar.visible = false
		return true
	if (tag.get("Animation")):
		var sz = (beat - tag.beat)/tag.duration
		skillStar.scale = Vector2(.1,.1) * sz
		skillStar.rotation = fmod(beat,2) * PI
	if (beat > beatOffset(tag.beat + tag.duration)):
		awardSkillStar(tag)
		return true

func awardSkillStar(tag):
	if (gettingStar == true):
		gotStar = true # sfx
		Sound.play(preload("res://assets/sfx/skillStar.ogg"))
		skillStar.scale = Vector2(.1,.1)
		skillStar.rotation = 0
		tw.interpolate_property(skillStar, "rotation", 0, 2 * PI, .5, Tween.TRANS_SINE, Tween.EASE_OUT)
		tw.start()
	else:
		skillStar.visible = false

func setAutoplay(enabled):
	autoplay = enabled
	return true

func punishMisses(val):
	punish = true

func forgiveMisses(val):
	punish = false

func displayArtist(tag):
	artist.visible = true
	var songN = artist.get_node("Song")
	var artN = artist.get_node("Artist")
	var songL = songN.get_node("Label")
	var artL = artN.get_node("Label")
	songL.text = "♪ " + tag.get("Song")
	artL.text = tag.get("Artist")
	tw.interpolate_property(songN,"self_modulate",Color(1,1,1,1),Color(0,0,0,1),.5,Tween.TRANS_SINE,Tween.EASE_OUT)
	tw.interpolate_property(artN, "self_modulate",Color(1,1,1,1),Color(0,0,0,1),.5,Tween.TRANS_SINE,Tween.EASE_OUT)
	tw.interpolate_property(songN,"position",Vector2(-187.5,285),Vector2(187.5,285),.5,Tween.TRANS_SINE,Tween.EASE_OUT)
	tw.interpolate_property(artN, "position",Vector2(827.5,330),Vector2(452.5,330),.5,Tween.TRANS_SINE,Tween.EASE_OUT)
	tw.start()
	return true

func closeArtist(val = null):
	var songN = artist.get_node("Song")
	var artN = artist.get_node("Artist")
	tw.interpolate_property(songN,"position",Vector2(187.5,285),Vector2(-187.5,285),.5,Tween.TRANS_SINE,Tween.EASE_IN)
	tw.interpolate_property(artN, "position",Vector2(452.5,330),Vector2(827.5,330),.5,Tween.TRANS_SINE,Tween.EASE_IN)
	tw.start()
	return true

func start(sp = -10000):
	startPos = sp
	yield(get_tree().create_timer(1),"timeout")
	if (game.intro.ends_with(".webm") and directory.file_exists(game.intro)):
		introFile = VideoStreamWebm.new()
		introFile.set_file(Data.global(directory.get_current_dir() + "/",game.intro))
		videoPlayer.stream = introFile
		videoPlayer.play()
		yield(self,"intro") # load intro
		videoPlayer.visible = false
		yield(get_tree().create_timer(.5),"timeout")
	videoPlayer = null
	track.setBPM(game.bpm)
	setMusic()
	if get_node("Game/Perfect"):
		get_node("Game/Perfect").visible = true
	
	EditorEnums.scanTags(self) # skill star, etc
	for sub in subGames.get_children():
		sub.setup(self, game)
	sequencer.sort()
	for sub in subGames.get_children():
		sub.sequencer.sort()
	track.play(max(0,track.getTime(startPos)/1000.0))
	playing = true

func songDone(val = null):
	if (not paused):
		playing = false
		gameInfo.completed = true
		gameInfo.reason = "Finish"
		gameInfo.perfect = isPerfect
		gameInfo.star = gotStar
		if (totalHits > 0):
			gameInfo.percent = round(float(actualHits)/float(totalHits) * 100)
		tw.interpolate_property(track.stream,"volume_db",0,-80,.5)
		tw.interpolate_property(fade,"self_modulate",Color(0,0,0,0),Color(0,0,0,1),.5)
		tw.start()
		yield(get_tree().create_timer(1),"timeout")
		emit_signal("done",gameInfo)

func quit():
	playing = false
	gameInfo.completed = true
	gameInfo.reason = "Quit"
	gameInfo.perfect = false
	gameInfo.star = false
	gameInfo.percent = 0
	tw.interpolate_property(track.stream,"volume_db",0,-80,.5)
	tw.interpolate_property(fade,"self_modulate",Color(0,0,0,0),Color(0,0,0,1),.5)
	tw.start()
	yield(get_tree().create_timer(1),"timeout")
	emit_signal("done",gameInfo)

func _ready():
	directory = Directory.new()
	track = Track.new()
	sequencer = Sequencer.new()
	add_child(track)
	if (not Data.getSave().settings.get("perfect")):
		perfect.free()
		perfect = null
	videoPlayer.connect("finished",self,"emit_signal",["intro"])
	track.stream.connect("finished",self,"songDone")

func _process(dt):
	if (playing):
		match paused:
			false:
				beat = track.getBeat()
				sequencer.update(beat)
				for sub in activeGames:
					sub.sequencer.update(beat)
			true:
				pauseMenu.get_node("Resume/Star").visible = pauseInd == 0
				pauseMenu.get_node("Resume/Star2").visible = pauseInd == 0
				pauseMenu.get_node("Quit/Star").visible = pauseInd == 1
				pauseMenu.get_node("Quit/Star2").visible = pauseInd == 1

func togglePause():
	if (paused):
		Sound.play(preload("res://assets/sfx/pause_exit.ogg"))
	else:
		Sound.play(preload("res://assets/sfx/pause_enter.ogg"))
	paused = not paused
	pauseInd = 0
	pauseMenu.visible = paused
	match paused:
		true:
			track.pause()
		false:
			track.resume()

func getOffset(beat):
	var time = track.getTime(beat)
	var thisTime = track.getAudioTime()
	return thisTime - time

func getRank(offset):
	var a = abs(offset)
	if (a < 8):
		return "Ace"
	elif (a < 42):
		return "Good"
	elif (a < 63):
		return "Barely"
	return "Miss"

func cancelPerfect(dontHit = null):
	if (punish):
		isPerfect = false
		if get_node("Game/Perfect"):
			get_node("Game/Perfect").failed()
	elif (!dontHit):
		hitPerfect()

func hitPerfect():
	if get_node("Game/Perfect"):
		get_node("Game/Perfect").hit()

func push(off):
	totalOffset += off
	totalHits += 1
	var rank = getRank(off)
	match rank:
		"Ace":
			actualHits += 1
			hitPerfect()
		"Good":
			actualHits += .8
			hitPerfect()
		"Barely":
			actualHits += .5
			cancelPerfect()
			if (gettingStar and punish):
				gettingStar = false
		"Miss":
			cancelPerfect(true)
			if (gettingStar and punish):
				gettingStar = false
	lastHit = rank
	emit_signal("input",off,rank)

func _input(ev):
	if (videoPlayer != null and videoPlayer.is_playing() and ev.is_action_pressed("start")):
		Sound.play(preload("res://assets/sfx/back.ogg"))
		videoPlayer.stop()
		emit_signal("intro")
	elif (playing and ev.is_action_pressed("start")):
		togglePause()
	elif (playing and paused and (ev.is_action_pressed("left") or ev.is_action_pressed("right"))):
		Sound.play(preload("res://assets/sfx/blip.ogg")).volume_db = 7
		pauseInd = fmod(pauseInd + 1,2)
	elif (paused and playing and ev.is_action_pressed("a")):
		if (pauseInd == 0):
			togglePause()
		else:
			Sound.play(preload("res://assets/sfx/back.ogg"))
			quit()
