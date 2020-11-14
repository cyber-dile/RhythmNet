extends Node
class_name Marker

var properties # property format: ["name", "type", currentValue, editorValues...]
var main = false
var obj
var id
var time = 0
var bpm = 120

func canDelete():
	return id != "zero"

func delete(scene):
	obj.free()
	scene.remix.markers.remove(scene.remix.markers.find(self))
	for marker in scene.remix.markers:
		marker.update(scene)

func getProperties():
	match id:
		"zero":
			properties = [
				["BPM", "number", bpm],
				["Time (ms)", "number", time],
				["Fail", "string", "That wasn't very good."],
				["Just OK", "string", "Eh..."],
				["OK", "string", "That was OK."],
				["Nearly", "string", "That was great!"],
				["Superb", "string", "Superb!"]
			]
		"bpm":
			properties = [
				["BPM", "number", bpm],
				["Time (ms)", "number", time]
			]

func get(name):
	for prop in properties:
		if prop[0] == name:
			return prop[2]

func set(name, val):
	for prop in properties:
		if prop[0] == name:
			prop[2] = val
			return

func updateProps(scene):
	match id:
		"zero", "bpm":
			bpm = properties[0][2]
			time = properties[1][2]
			scene.updateBPM()
			for marker in scene.remix.markers:
				marker.update(scene)

func toString():
	match id:
		"zero":
			return "Main Marker"
		"bpm":
			return "BPM Marker"

func serialize():
	match id:
		"zero":
			return {
				"id": id,
				"time": time,
				"bpm": bpm
			}
		"bpm":
			return {
				"id": id,
				"time": time,
				"bpm": bpm
			}

func deserialize(t):
	for key in t.keys():
		self[key] = t[key]

func copy(scene):
	match id:
		"zero":
			pass
		_:
			var newMarker = scene.newMarker()
			newMarker.deserialize(serialize())
			newMarker.update(scene)
			return newMarker

func nudge(scene, dir):
	match id:
		"bpm":
			var track = scene.track
			var snapDenom = scene.snapDenom
			var beat = track.getBeat(time)
			var newBeat = round(beat * snapDenom + dir)/snapDenom
			self.time = round(track.getTime(newBeat))
			for marker in scene.remix.markers:
				marker.update(scene)
			scene.updateBPM()

func shift(scene, dir):
	pass

func place(scene):
	match id:
		"bpm":
			var snapDenom = scene.snapDenom
			time = round(scene.track.getTime(round(scene.pos * snapDenom)/snapDenom))

func update(scene): # scene is the remix editor script
	var theme = scene.themes[scene.thm]
	match id:
		"zero":
			obj.modulate = Color(theme[12])
			obj.get_node("TopRight").visible = true
			obj.get_node("TopRight").text = str(bpm)
		"bpm":
			obj.modulate = Color(theme[13])
			obj.get_node("TopRight").visible = true
			obj.get_node("TopRight").text = str(bpm)
			if (scene.track.bpm != null and scene.track.bpm.size() > 0):
				var beat = scene.track.getBeat(time)
				obj.rect_position = Vector2(80 * beat - 1,-30)
