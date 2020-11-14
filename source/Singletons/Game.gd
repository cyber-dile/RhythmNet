extends Node

func play(dir):
	var newField = preload("res://scenes/Playfield/Playfield.tscn").instance()
	get_tree().get_root().add_child(newField)
	newField.setup(dir)
	return newField
