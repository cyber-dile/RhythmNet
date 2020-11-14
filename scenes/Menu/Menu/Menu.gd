extends Control

onready var bg = $BG
var track
var circles = []
var directions = []
var positions = []
var lastBeat = 0
var t = 0

func _ready():
	circles.append($R)
	circles.append($H)
	circles.append($Y)
	circles.append($T)
	circles.append($H2)
	circles.append($M)
	circles.append($Net)
	for i in range(circles.size()):
		directions.append(Vector2())
		positions.append(circles[i].position)

func aPressed():
	var scene = get_node("..")
	if (scene.state == "menu"):
		Sound.play(preload("res://assets/sfx/majorSelect.ogg"))
		scene.state = "transition"
		scene.fadeTo(Color(1,1,1,0),Color(1,1,1,1))
		yield(get_tree().create_timer(1),"timeout")
		visible = false
		scene.state = "files"
		get_node("../Files").visible = true
		get_node("../Files").updateFiles()
		scene.fadeTo(Color(1,1,1,1),Color(1,1,1,0))

func _input(ev):
	if (ev.is_action_pressed("a")):
		aPressed()

func _process(dt):
	t += dt
	if (track == null):
		track = get_node("..").track
	var beat = track.getBeat()
	var rounded = floor(beat)
	var mod = 1 - sin(fmod(beat,1) * PI/2)
	bg.beat = beat
	bg.mod = mod
	bg.gridn = floor(fmod(beat/2,2))
	bg.self_modulate = Color.from_hsv(t/32+.5,.25,1)
	if rounded > lastBeat:
		for i in range(directions.size()):
			directions[i] = Vector2(randf() - .5,randf() - .5).normalized()
		lastBeat = rounded
	for i in range(circles.size()):
		var circle = circles[i]
		circle.position = positions[i] + directions[i] * 10 * mod
		circle.scale = Vector2(1 + mod/10,1 + mod/10)
