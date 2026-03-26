extends Node


# Called when the node enters the scene tree for the first time.

var scenePath : String;

func _ready() -> void:
	EventBus.loadScene.connect(_on_load_scene)
	EventBus.sceneToLoad.connect(_on_scene_to_load)
	print("Readied")

func _on_scene_to_load(value: Variant) -> void:
	scenePath = value
	print("prepping to load " + scenePath)
	ResourceLoader.load_threaded_request(scenePath)


func _on_load_scene() -> void:
	print("Loading scene")
	var old_level = get_child(0)
	old_level.queue_free()
	var level_scene = ResourceLoader.load_threaded_get(scenePath)
	var level = level_scene.instantiate()
	add_child.call_deferred(level)
	
