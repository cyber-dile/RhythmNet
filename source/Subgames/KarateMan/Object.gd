extends Node2D

var ready = false
var type
var state
var tag
var playfield
var game
var rspeed

func _ready():
	playfield = get_node("../..").playfield
	game = get_node("../..")

func h(t, start, end, height):
	height = height + (end - start)/2
	return start + (end - start) * t + (-4 * pow(t,2) + 4 * t) * height

func setupNormal(t):
	type = "normal"
	state = "air"
	tag = t
	get_node("Object/" + tag.get("Shape")).visible = true
	get_node("Object").rotation = 4 * PI * randf()
	get_node("Shadow").visible = true
	var mod = randf() - .5
	mod = abs(mod)/mod + mod
	rspeed = PI * mod
	ready = true

func handleAir(beat,dt):
	var since = beat - tag.beat
	since = clamp(since,0,1.5)
	var width = 150 - 150 * since
	var height = h(since, 250, 0, -10)
	var scale = 5 * pow(.05,since) + .75
	if (since > 1):
		height = h(2 * (since - 1),0,90,-45)
		width = -50 * (since - 1)
	get_node("Object").position = Vector2(width,height)
	get_node("Object").scale = Vector2(scale,scale)
	get_node("Object").rotation += dt * rspeed
	get_node("Shadow").position = Vector2(-10,110) + Vector2(30,60) * (1.5 - since)

func handleMiss(beat,dt):
	var since = beat - tag.beat - 1
	since = clamp(since,0,1)
	var width = 100 * since
	var height = h(since, 0, 90, -45 - 40)
	get_node("Object").position = Vector2(width,height)
	get_node("Object").rotation += dt * rspeed
	get_node("Shadow").position = Vector2(-10,130) + Vector2(110,-20) * since

func hit():
	var off = playfield.getOffset(tag.beat + 1)
	if abs(off) <= 63:
		var rank = playfield.getRank(off)
		match rank:
			"Ace", "Good":
				game.hitSound(tag)
				state = "hit"
				rspeed = 2 * PI
				game.joe.get_node("Torso/Punch1/Effect").visible = true
				game.joe.get_node("RPunch1/Effect").visible = true
				get_node("Object").scale = Vector2(1,1)
				game.hitLast = true
			_:
				state = "hitMiss"
				Sound.play(preload("res://assets/sfx/miss1.ogg"))
				rspeed = PI
				get_node("Object").scale = Vector2(1,1)
				game.hitLast = false
		return [off, rank]

func upd(beat, dt):
	match type:
		"normal":
			match state:
				"air":
					handleAir(beat,dt)
					
					var off = playfield.getOffset(tag.beat + 1)
					if (off > 63):
						state = "airMiss"
						playfield.push(64)
						playfield.displayTiming(64,"Miss")
						game.hitLast = false
				"airMiss":
					handleAir(beat,dt)
					
					var since = beat - tag.beat
					if (since > 1.5):
						state = "ground"
				"ground":
					get_node("Object").position = Vector2(-25,90)
					get_node("Shadow").position = Vector2(-25,110)
					if (beat - tag.beat > 3):
						var b = fmod(floor((beat - tag.beat) * 4),2)
						get_node("Object").modulate = (Color(1,1,1,0) if (b == 0) else Color(1,1,1,1))
				"groundHit":
					get_node("Object").position = Vector2(100,90)
					get_node("Shadow").position = Vector2(100,110)
					if (beat - tag.beat > 3):
						var b = fmod(floor((beat - tag.beat) * 4),2)
						get_node("Object").modulate = (Color(1,1,1,0) if (b == 0) else Color(1,1,1,1))
				"hit":
					var since = beat - (tag.beat + 1)
					var height = 150 * pow(since,2) - 75 * since
					var spd = 360
					match tag.get("Shape"):
						"Ball":
							spd = 640
						"Rock","Cooking Pot","Alien":
							spd = 480
					if (tag.get("Shape") == "Cooking Pot"):
						get_node("Object/Cooking Pot/Bottom").rotation += dt * rspeed
					get_node("Shadow").position = Vector2(spd * since,140)
					get_node("Object").position = Vector2(spd * since,height)
					get_node("Object").rotation += dt * rspeed
				"hitMiss":
					handleMiss(beat,dt)
					
					var since = beat - tag.beat
					if (since > 2):
						state = "groundHit"
		"combo":
			pass
		"kick":
			pass
