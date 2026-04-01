class_name Magnetic
extends Node

@export_subgroup("Settings")
@export var mass: float = 4

@export_subgroup("Outline")
@export var pulse_speed: float = 3.0

var _sprite: Node
var _base_color: Color
var _active: bool = false
var _outline_color: Color

func _ready() -> void:
	_sprite = _get_sprite()

func _process(delta: float) -> void:
	if _active and _sprite != null:
		var pulse = (sin(Time.get_ticks_msec() * 0.001 * pulse_speed) * 0.5 + 0.5)
		_sprite.modulate = _outline_color * (0.7 + 0.3 * pulse)
	
func set_outline(active: bool, color: Color) -> void:
	if _sprite == null:
		return
	_active = active
	_outline_color = color
	if not active:
		_sprite.modulate = _base_color

func _get_sprite() -> Node:
	var parent = get_parent()
	for child in parent.get_children():
		if child is Sprite2D or child is AnimatedSprite2D or child is NinePatchRect:
			_base_color = child.modulate
			return child
	return null

func get_mass() -> float:
	return mass
