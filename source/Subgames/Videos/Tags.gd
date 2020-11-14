extends Node

var category = "Videos"

func createTag(name, duration, hits, properties):
	var newTag = Tag.new()
	newTag.tag = name
	newTag.category = category
	newTag.duration = duration
	newTag.hits = hits
	newTag.properties = properties
	return newTag

func getTags():
	return [category, preload("res://assets/icons/playset.svg"),
	[
		createTag("Start Video", 1, [], [
			["File Path","string",""]
		]),
		createTag("Stop Video", 1, [], [])
	],
	{
		#
	}
	]
