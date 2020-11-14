extends Node # doesn't extend Object because 1) convenience, 2) AudioStreamPlayers need to be a part of the scene tree
class_name Track

var bpm: Array
var pitch = 1
var stream: AudioStreamPlayer
var pausedTime: float
var playing = false

func setBPM(table):
	bpm = table
	Util.Music.initBPM(bpm)

func setPitch(newPitch):
	stream.pitch_scale = newPitch
	var mod = newPitch/pitch
	pitch = newPitch
	if (mod != 1):
		for beat in bpm:
			beat[0] = beat[0]/mod # if mod is 2x, half the amount of time
			beat[1] = beat[1]*mod # if mod is 2x, double the BPM

func getBeat(ms = getAudioTime()):
	return Util.Music.getBeat(self.bpm, ms)

func getTime(beat):
	return Util.Music.getTime(self.bpm, beat)

func getAudioTime(): # tries to get the exact time in seconds, regardless of pitch, to adjust for input offset
	return (Util.Music.getAccuratePos(stream))/pitch * 1000

func setAudio(newStream):
	stream.set_stream(newStream)

func play(t = 0):
	playing = true
	stream.play(t)

func pause():
	playing = false
	pausedTime = Util.Music.getAccuratePos(stream)
	stream.stop()

func resume():
	playing = true
	stream.play(pausedTime)

func stop():
	playing = false
	stream.stop()

func _init():
	stream = AudioStreamPlayer.new()
	stream.bus = "Music"
	add_child(stream)
