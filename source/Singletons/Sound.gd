extends Node

func handleCleanup(stream):
	yield(stream,"finished")
	stream.queue_free()

func play(source): # plays a SFX and removes it upon completion
	var stream = AudioStreamPlayer.new()
	handleCleanup(stream)
	stream.stream = source
	stream.bus = "SFX"
	stream.play()
	add_child(stream)
	return stream
