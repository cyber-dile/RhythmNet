extends Node

var defaultData = {
	"saveSlots": []
}
var defaultSave = {
	"name": "Save Name",
	"recent": [],
	"tags": {},
	"completed": {},
	"skillStars": {},
	"settings": {
		"perfect": false
	},
	"editor": {
		"theme": 0
	},
	"progress": 0
}
var thisSlot: int = 0
var saveData: Dictionary

func getSave():
	return saveData.saveSlots[thisSlot]

func read(path):
	var file: File = File.new()
	if (not file.file_exists(path)):
		return
	file.open(path, File.READ)
	var data = file.get_as_text()
	file.close()
	return parse_json(data)

func global(parentPath, path):
	if (path.begins_with("res://") or path.begins_with("user://")):
		return path
	return parentPath + path

func readRaw(path):
	var file: File = File.new()
	if (not file.file_exists(path)):
		return
	file.open(path, File.READ)
	var data = file.get_as_text()
	file.close()
	return data

func readOgg(path):
	var a = load(path)
	if (a != null):
		return a.data
	var file: File = File.new()
	if (not file.file_exists(path)):
		return
	file.open(path, File.READ)
	var data = file.get_buffer(file.get_len())
	file.close()
	return data

func loadImage(path):
	var i = load(path)
	if (i != null):
		return i
	var dir = Directory.new()
	if (!dir.file_exists(path)):
		return
	var image = Image.new()
	var err = image.load(path)
	if (err != OK):
		return
	var tex = ImageTexture.new()
	tex.create_from_image(image, 0)
	return tex

func write(path, data):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(to_json(data))
	file.close()

func writeRaw(path, data):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(data)
	file.close()

func fixSave(save):
	for i in defaultSave.keys():
		var v = defaultSave[i]
		if (!save.get(i)):
			save[i] = parse_json(to_json(v))

func loadGame():
	var data = read("user://save.json")
	if (!data):
		data = parse_json(to_json(defaultData))
	for slot in data.saveSlots:
		fixSave(slot)
	saveData = data

func saveGame():
	write("user://save.json", saveData)

func newSave(name):
	var save = parse_json(to_json(defaultSave))
	save.name = name
	saveData.saveSlots.append(save)
	saveGame()

func deleteSave(slot):
	saveData.saveSlots.remove(slot)
	saveGame()

func _ready():
	loadGame()
