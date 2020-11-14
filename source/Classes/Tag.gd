extends Node
class_name Tag

var main = false
var obj
var category = ""
var tag = ""
var beat = 0
var duration = 0
var layer = 0
var hits = []
var properties = [] # property format: ["name", "type", currentValue, editorValues...]

func canDelete():
	return true

func delete(scene):
	obj.free()
	scene.remix.tags.remove(scene.remix.tags.find(self))

func copy(scene):
	var newTag = scene.newTag()
	newTag.deserialize(serialize())
	newTag.update(scene)
	return newTag

func toString():
	return tag

func getProperties():
	pass

func updateProps(scene):
	for list in Tags.categories:
		if (list[0] == category):
			if (list[3].get(tag)):
				list[4].call(list[3][tag],self,scene)
				update(scene)
			return

func nudge(scene, dir):
	var track = scene.track
	var snapDenom = scene.snapDenom
	beat = round(beat * snapDenom + dir)/snapDenom
	update(scene)

func shift(scene, dir):
	layer = clamp(layer + dir,0,5)
	update(scene)

func place(scene):
	var snapDenom = scene.snapDenom
	beat = round(scene.pos * snapDenom)/snapDenom

func deserialize(t):
	for key in t.keys():
		self[key] = t[key]
	var cat
	for c in EditorEnums.categories:
		if (c[0] == category):
			cat = c
			break
	for t in cat[2]:
		if (t.tag == tag):
			var newProperties = parse_json(to_json(t.properties))
			for i in range(properties.size()):
				var p = properties[i]
				for v in newProperties:
					if (v[0] == p[0]):
						v[2] = p[1]
						break
			properties = newProperties
			break

func serialize():
	var fixedProperties = []
	for property in properties:
		fixedProperties.append([property[0], property[2]])
	return {
		"tag": tag,
		"category": category,
		"hits": hits,
		"beat": beat,
		"duration": duration,
		"layer": layer,
		"properties": fixedProperties
	}

func get(name):
	for prop in properties:
		if prop[0] == name:
			return prop[2]

func set(name, val):
	for prop in properties:
		if prop[0] == name:
			prop[2] = val
			return

func update(scene): # scene is the remix editor script
	match tag:
		_:
			obj.rect_position = Vector2(80 * beat,20 * layer)
			obj.rect_size = Vector2(80 * duration,20)
			obj.get_node("Selected").rect_size = obj.rect_size + Vector2(4,4)
			obj.get_node("Button").rect_size = obj.rect_size
			obj.get_node("Category").rect_size = obj.rect_size - Vector2(4,0)
			obj.get_node("Tag").rect_size = obj.rect_size - Vector2(4,0)
			var color = scene.get_node("Track/Color" + str(layer + 1)).color
			obj.color = Color.from_hsv(color.h,min(1,color.s * 2),min(1,color.v * 1.5))
			obj.get_node("Selected").color = Color.from_hsv(color.h,min(1,color.s * 2),color.v / 2)
			obj.get_node("Left").color = Color.from_hsv(color.h,min(1,color.s * 2),color.v / 2)
			obj.get_node("Category").text = category.to_upper()
			obj.get_node("Tag").text = tag
			obj.get_node("Tag").self_modulate = (Color(0,0,0,1) if (obj.color.s < .2 and obj.color.v > .8) else Color(1,1,1,1))
			obj.get_node("Category").self_modulate = obj.get_node("Tag").self_modulate
			
			obj.get_node("Hits").position = Vector2(0,120 - obj.rect_position.y)
			for hit in obj.get_node("Hits").get_children():
				hit.free()
			for hit in hits:
				var newHit = obj.get_node("Hit").duplicate()
				obj.get_node("Hits").add_child(newHit)
				newHit.position = Vector2(80 * hit - .5,0)
				newHit.visible = true
