extends Control


@onready var massLabel = $HBoxContainer/HBoxContainer/Label
@onready var polarityTexture = $HBoxContainer/TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.polarityChanged.connect(_on_polarity_changed)
	EventBus.massChanged.connect(_on_mass_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_polarity_changed(value):
	if(value):
		polarityTexture.texture = load("res://PositiveIconTemp.png")
	else:
		polarityTexture.texture = load("res://NegativeIconTemp.png")

func _on_mass_changed(value):
	massLabel.text = str(value)
