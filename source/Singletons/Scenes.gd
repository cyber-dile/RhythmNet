extends Node

var scene
var data = {}

func change(newScene = null):
	if (scene != null):
		if (scene.has_method("exit")):
			yield(scene.exit(), "completed")
		scene.queue_free()
	scene = null
	if (newScene != null):
		scene = newScene.instance()
		get_tree().get_root().add_child(scene)

func _ready():
	scene = get_tree().current_scene
