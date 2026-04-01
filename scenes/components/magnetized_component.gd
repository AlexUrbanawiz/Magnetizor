class_name MagnetizedComponent
extends Area2D

@export_category("Settings")
@export var charge: float = 100.0
@export var magnetic_field: float = 10.0
@export var polarity: bool = false

@onready var collisionShape: CollisionShape2D = $CollisionShape2D
@onready var selfMagneticComponent = get_node_or_null("../Magnetic")
@onready var objectCollisionShape: CollisionShape2D = get_node_or_null("../CollisionShape2D")

var mass: float = 0
var objectsInRange = []

# Field visual
var _field_line: Line2D
var _field_color_active: Color
var _field_color_idle: Color
const CIRCLE_POINTS: int = 64

func _ready() -> void:
	collisionShape.shape = objectCollisionShape.shape
	collisionShape.scale = objectCollisionShape.scale
	collisionShape.scale.x += magnetic_field / 8
	collisionShape.scale.y += magnetic_field / 8
	collisionShape.scale *= magnetic_field / 8
	mass = selfMagneticComponent.get_mass()
	_setup_field_visual.call_deferred()
	print("Magnetized!!")

func _setup_field_visual() -> void:
	_update_polarity_colors()

	_field_line = Line2D.new()
	_field_line.width = 1.5
	_field_line.default_color = _field_color_idle
	_field_line.closed = true
	# Use a gradient so the line fades slightly giving a softer field feel
	var gradient = Gradient.new()
	gradient.set_color(0, _field_color_idle)
	gradient.set_color(1, _field_color_idle)
	_field_line.gradient = gradient
	add_child(_field_line)
	_draw_field_circle()

func _draw_field_circle() -> void:
	if _field_line == null:
		return
	# Get the field radius from the collision shape's scaled extents
	var shape = collisionShape.shape
	var radius: float
	if shape is RectangleShape2D:
		# Use the longest side as the radius for a rectangle field
		radius = max(shape.size.x * collisionShape.scale.x,
					 shape.size.y * collisionShape.scale.y) / 2.0
	elif shape is CircleShape2D:
		radius = shape.radius * collisionShape.scale.x
	else:
		radius = 32.0

	_field_line.clear_points()
	for i in range(CIRCLE_POINTS):
		var angle = (float(i) / CIRCLE_POINTS) * TAU
		_field_line.add_point(Vector2(cos(angle), sin(angle)) * radius)

func _update_polarity_colors() -> void:
	if polarity:
		_field_color_active = Color(1.0, 0.3, 0.0, 0.8)  # push orange
		_field_color_idle   = Color(1.0, 0.3, 0.0, 0.25)
	else:
		_field_color_active = Color(0.0, 0.6, 1.0, 0.8)  # pull blue
		_field_color_idle   = Color(0.0, 0.6, 1.0, 0.25)

func _process(delta: float) -> void:
	_update_field_visual()
	for body in objectsInRange:
		if body.get_node_or_null("Magnetic") != null:
			if body.get_node_or_null("MagnetizedComponent") != null:
				handle_double_magnetized(get_parent(), body, body.get_node_or_null("MagnetizedComponent"))
			else:
				handle_magnetized_magnetic(get_parent(), body, body.get_node_or_null("Magnetic"))
		elif body.get_node_or_null("MagnetComponent") != null:
			handle_magnetized_magnet(get_parent(), body, body.get_node_or_null("MagnetComponent"))

func _update_field_visual() -> void:
	if _field_line == null:
		return
	var has_objects = objectsInRange.size() > 0
	# Pulse when actively affecting something, fade when idle
	var target_color: Color
	if has_objects:
		var pulse = (sin(Time.get_ticks_msec() * 0.003) * 0.5 + 0.5)
		target_color = _field_color_idle.lerp(_field_color_active, pulse)
	else:
		target_color = _field_color_idle
	_field_line.default_color = target_color
	if _field_line.gradient:
		_field_line.gradient.set_color(0, target_color)
		_field_line.gradient.set_color(1, target_color)

func construct(charged: float, field: float, pol: bool) -> void:
	charge = charged
	magnetic_field = field
	polarity = pol
	var s = _get_sprite()
	if s != null:
		s.modulate = Color(1, 0, 0) if polarity else Color(0, 0, 1)
	_update_polarity_colors()
	if _field_line != null:
		_field_line.default_color = _field_color_idle

func _get_sprite() -> Node:
	var parent = get_parent()
	for child in parent.get_children():
		if child is Sprite2D or child is AnimatedSprite2D or child is NinePatchRect:
			return child
	return null
# --- All existing functions below unchanged ---

func _on_body_entered(body: Node2D) -> void:
	print("Body entered")
	if body.is_in_group("magnetic"):
		var magnetic_object = body.get_node_or_null("Magnetic")
		if magnetic_object != null and body != get_parent():
			print("attracting %s" % body.name)
			objectsInRange.append(body)
	elif body.get_node_or_null("MagnetComponent") != null:
		objectsInRange.append(body)

func _on_body_exited(body: Node2D) -> void:
	var objectIndex = objectsInRange.find(body)
	if objectIndex != -1:
		objectsInRange.remove_at(objectIndex)

func handle_magnetized_magnetic(body1: RigidBody2D, body2: RigidBody2D, otherMagneticComponent: Magnetic) -> void:
	var strength = magnetic_field * charge
	var total_mass: float = mass + otherMagneticComponent.mass
	var objectInfluence: float = mass / total_mass
	var selfInfluence: float = otherMagneticComponent.mass / total_mass
	var direction = body1.global_position.direction_to(body2.global_position)
	if !polarity:
		direction = body2.global_position.direction_to(body1.global_position)
	var forceVector = direction * strength
	body2.apply_central_force(forceVector * objectInfluence)
	body1.apply_central_force((-1 * forceVector) * selfInfluence)

func handle_magnetized_magnet(body1: RigidBody2D, body2: CharacterBody2D, magnet_component: MagnetComponent) -> void:
	var strength = magnetic_field * charge
	var total_mass: float = mass + magnet_component.getMass()
	var objectInfluence: float = mass / total_mass
	var selfInfluence: float = magnet_component.getMass() / total_mass
	var direction = body1.global_position.direction_to(body2.global_position)
	if polarity == magnet_component.getPolarity():
		direction = body2.global_position.direction_to(body1.global_position)
	var forceVector = direction * strength
	body1.apply_central_force(forceVector * selfInfluence)
	body2.velocity += ((-1 * forceVector) / magnet_component.getMass()) * objectInfluence * get_physics_process_delta_time()

func handle_double_magnetized(body1: RigidBody2D, body2: RigidBody2D, magnet_component: MagnetizedComponent) -> void:
	var strength = magnetic_field * charge
	var total_mass: float = mass + magnet_component.getMass()
	var objectInfluence: float = mass / total_mass
	var selfInfluence: float = magnet_component.getMass() / total_mass
	var direction = body1.global_position.direction_to(body2.global_position)
	if polarity == magnet_component.getPolarity():
		direction = body2.global_position.direction_to(body1.global_position)
	var forceVector = direction * strength
	body1.apply_central_force(forceVector * selfInfluence)
	body2.apply_central_force((-1 * forceVector) * objectInfluence)

func getMass() -> float:
	return mass

func getPolarity() -> bool:
	return polarity
