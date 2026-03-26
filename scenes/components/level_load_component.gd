extends Area2D

@export var sceneToLoad : String
@onready var collisionShape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	EventBus.emit_signal.call_deferred("sceneToLoad", sceneToLoad)
	print("Told scene to load")


func _on_body_entered(body: Node2D) -> void:
	print("Body Entered Door")
	if body.is_in_group("player"):
		print("Player entered Door")
		print("Scene to load: " + sceneToLoad)
		EventBus.emit_signal("loadScene")
