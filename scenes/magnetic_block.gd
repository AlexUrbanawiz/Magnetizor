@tool
class_name MagneticBlock
extends RigidBody2D

@export var block_size: Vector2 = Vector2(48, 48):
	set(value):
		block_size = value
		_update_size()

@export var block_mass: float = 4.0:
	set(value):
		block_mass = value
		_update_mass()

@onready var nine_patch: NinePatchRect = $NinePatchRect
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var magnetic: Magnetic = $Magnetic

func _ready() -> void:
	_update_size()
	_update_mass()

func _update_size() -> void:
	if not is_node_ready():
		return
	if nine_patch == null or collision == null:
		return
	nine_patch.size = block_size
	nine_patch.position = -block_size / 2
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = block_size
	collision.shape = rect_shape

func _update_mass() -> void:
	if not is_node_ready():
		return
	if magnetic == null:
		return
	magnetic.mass = block_mass
