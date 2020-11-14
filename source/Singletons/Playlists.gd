extends Node

# A playlist should look like this-

# {
#	"name": "Playlist Name",
#	"games": [
#		[
#			{
#				"name": "Game Name",
#				"description": "The description of the game!",
#				"icon": preload("res://assets/icons/template.svg"),
#				"data": "res://link/to/game/json.json",
#				"action": "gameInfo"
#			},
#			{
#				"name": "Game Name 2",
#				"description": "The description of the game!",
#				"icon": preload("res://assets/icons/template.svg"),
#				"data": "res://link/to/game2/json.json",
#				"action": "gameInfo"
#			}
#		]
# }

# It is first separated into an array of columns, which are then separated into arrays of games.
# "Action" tells the selector what to do when the item is selected.
# The actions are as follows:
	# "gameInfo" - Opens the game's information.
	# "locked" - Opens the game's information with a locked screen.
	# "call" - Calls a function in the selector with the same name as the value of the "data" variable.

# Keep each column at most 5 games large!

var playlists = []
	
var blank = {
	"name": "Work In Progress",
	"description": "This game is to be added.",
	"icon": preload("res://assets/icons/template.svg"),
	"data": "",
	"action": "locked"
}
var blankRemix = {
	"name": "Work In Progress",
	"description": "This game is to be added.",
	"icon": preload("res://assets/icons/remix.svg"),
	"data": "",
	"action": "locked"
}

func newPlaylist(name, desc):
	var playlist = {
		"name": name,
		"desc": desc,
		"games": [
			[
				{
					"name": "Change Playlist",
					"description": "Change the playlist currently on screen.",
					"icon": preload("res://assets/icons/playset.svg"),
					"data": "changePlaylist",
					"action": "call"
				},
				{
					"name": "Game Modifiers",
					"description": "Change the game modifiers.",
					"icon": preload("res://assets/icons/modifiers.svg"),
					"data": "changeMods",
					"action": "call"
				}
			]
		]
	}
	playlists.append(playlist)
	return playlist

func refreshRemixes():
	var cg = playlists[playlists.size() - 1]
	cg.games = [cg.games[0]]
	
	var dir = Directory.new()
	dir.open("user://remixes/")
	dir.list_dir_begin()
	var remixes = []
	while true:
		var remix = dir.get_next()
		if (remix == ""):
			break
		elif (remix != "." and remix != ".."):
			var dat = Data.read("user://remixes/" + remix + "/data.json")
			dat.directory = "user://remixes/" + remix + "/"
			remixes.append(dat)
	var thisRow = []
	for remix in remixes:
		thisRow.append(getDict(remix.directory, remix))
		if (thisRow.size() >= 5):
			cg.games.append(thisRow)
			thisRow = []
	if (thisRow.size() > 0):
		cg.games.append(thisRow)
		thisRow = []

func getDict(dir, game):
	return {
		"name": game.name,
		"description": game.description,
		"icon": Data.loadImage(Data.global(dir, game.icon)),
		"data": dir,
		"action": "gameInfo",
		"id": game.id
	}

func getGame(dir):
	var json = dir + "data.json"
	return getDict(dir, Data.read(json))

func generate():
	playlists = []
	var rt = newPlaylist("Rhythm Tengoku", "The games from the first entry in the Rhythm Heaven series, Rhythm Tengoku (GBA).")
	var rh = newPlaylist("Rhythm Heaven", "The games from the second entry in the Rhythm Heaven series, Rhythm Heaven (DS).")
	var rhf = newPlaylist("Rhythm Heaven Fever", "The games from the third entry in the Rhythm Heaven series, Rhythm Heaven Fever (Wii).")
	var mm = newPlaylist("Rhythm Heaven Megamix", "The games from the fourth entry in the Rhythm Heaven series, Rhythm Heaven Megamix (3DS).")
	var cg = newPlaylist("Custom Games", "The games you've created or downloaded.")
	
	rt.games.append([
		getGame("res://resources/Games/RT/KarateManRT/"),
		blank,
		blank,
		blank,
		blankRemix
	])
	for i in range(7):
		rt.games.append([blank,blank,blank,blank,blankRemix])
	
	for i in range(10):
		rh.games.append([blank,blank,blank,blank,blankRemix])
	
	for i in range(10):
		rhf.games.append([blank,blank,blank,blank,blankRemix])
	
	mm.games.append([blank,blank,blank,blank])
	mm.games.append([blank,blank,blank,blank])
	mm.games.append([blankRemix])
	mm.games.append([blank,blank,blank,blank])
	mm.games.append([blank,blank,blank,blank])
	mm.games.append([blankRemix])
	mm.games.append([blank,blank,blank,blank])
	mm.games.append([blank,blank,blank,blank])
	mm.games.append([blankRemix])
	mm.games.append([blank,blank,blank,blank,blankRemix])
	mm.games.append([blank,blank,blank,blank,blankRemix])
	mm.games.append([blank,blank,blank,blank,blankRemix])
	mm.games.append([blank,blank,blank,blank,blankRemix])
	mm.games.append([blank,blank,blank,blank,blankRemix])
	mm.games.append([blank,blank,blank,blank,blankRemix])
	mm.games.append([blank,blank,blank,blank])
	mm.games.append([blank,blank,blank,blank])
	mm.games.append([blank,blank,blank,blank])
	mm.games.append([blankRemix])
	mm.games.append([blank,blank,blank,blank,blankRemix])
	mm.games.append([blank,blank,blank,blank,blankRemix])
	mm.games.append([blank,blank,blank,blank,blankRemix])
	mm.games.append([blank,blank,blank])
	mm.games.append([blank,blank,blank])
	mm.games.append([blank,blank,blank])
	mm.games.append([blank,blank,blank])
	mm.games.append([blank,blank,blank])
	mm.games.append([blank,blank,blank])
	
	refreshRemixes()

func _ready():
	var dir = Directory.new()
	dir.open("user://")
	if (!dir.dir_exists("remixes")):
		dir.make_dir("remixes")
	if (!dir.file_exists("user://theme.json")):
		Data.write("user://theme.json", Data.read("res://scenes/RemixEditor/theme.json"))
	
	generate()
