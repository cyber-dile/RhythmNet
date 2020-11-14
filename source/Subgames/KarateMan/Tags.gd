extends Node

var category = "Karate Man"

func createTag(name, duration, hits, properties):
	var newTag = Tag.new()
	newTag.tag = name
	newTag.category = category
	newTag.duration = duration
	newTag.hits = hits
	newTag.properties = properties
	return newTag

func fixBackground(tag, scene):
	tag.set("Red",clamp(tag.get("Red"),0,255))
	tag.set("Blue",clamp(tag.get("Blue"),0,255))
	tag.set("Green",clamp(tag.get("Green"),0,255))

func snowBounds(tag, scene):
	tag.set("Snow Angle",clamp(tag.get("Wind Angle"),-90,90))

func getTags():
	return [category, preload("res://resources/Games/RT/KarateManRT/icon.png"),
	[
		createTag("Enter Game", 1, [], []),
		createTag("Leave Game", 1, [], []),
		createTag("Game Invisible", 1, [], []),
		createTag("Game Visible", 1, [], []),
		createTag("Set Theme", 1, [1], [
			["Theme","dropdown","Karate Joe",["Karate Joe","Senior","Custom"]],
			["JSON Path","string",""]
		]),
		createTag("Set Tint", 1, [], [
			["Red","integer",255],
			["Green","integer",255],
			["Blue","integer",255]
		]),
		createTag("Set Background", 1, [], [
			["Type","dropdown","Solid",["Solid","Lines","Circles","Image"]],
			["Image Path","string",""],
			["Red","integer",255],
			["Green","integer",255],
			["Blue","integer",255]
		]),
		createTag("Set Snow", 1, [], [
			["Enabled","boolean",false],
			["Wind Angle","number",0],
			["Wind Speed","number",50]
		]),
		createTag("Start Bobbing", 1, [], []),
		createTag("Stop Bobbing", 1, [], [
			["Head Down","boolean",false]
		]),
		createTag("Zoom Out", 1, [], []),
		createTag("Normal Zoom", 1, [], []),
		createTag("Set Face", 1, [], [
			["Missed?","dropdown","Normal",["Normal","Blush","Bold","Distraught","Excited","Frowning","Shocked","Smiling"]],
			["Hit?","dropdown","Normal",["Normal","Blush","Bold","Distraught","Excited","Frowning","Shocked","Smiling"]],
			["Duration","number",2]
		]),
		createTag("Object", 1, [1], [
			["Shape","dropdown","Pot",["Pot","Rock","Ball","Cooking Pot","Lightbulb","Orange Lightbulb","Blue Lightbulb","Alien"]],
			["Sound","dropdown","Throw",["Throw","Offbeat","Lightbulb"]]
		]),
		createTag("Kick", 1.75, [1,1.75], []),
		createTag("Combo", 2.5, [1,2.5], [
			["Jump","boolean",false]
		]),
		createTag("Grr!", 1, [], []),
		createTag("Hit 3!", .5, [], []),
		createTag("Hit 4!", .5, [], []),
		createTag("!", .5, [], []),
	],
	{
		"Set Background": "fixBackground",
		"Set Snow": "snowBounds"
	}
	]
