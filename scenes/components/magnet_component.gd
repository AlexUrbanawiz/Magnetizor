class_name MagnetComponent
extends Node

@export_subgroup("Settings")
@export var charge: float = 100.0
@export var magnetic_field: float = 10.0
@export var mass: float = 2

@export_subgroup("Beam Visuals")
@export var pull_color: Color = Color(0.0, 0.6, 1.0)
@export var push_color: Color = Color(1.0, 0.3, 0.0)
@export var beam_width: float = 3.0
@export var pulse_speed: float = 3.0

@onready var ray = $RayCast2D
@onready var ray2 = $RayCast2D2

var polarity: bool = false
var magnetized_component
var current_target: RigidBody2D = null

# Beam nodes
var _beam: Line2D
var _particles: CPUParticles2D

func _ready() -> void:
	magnetized_component = preload("res://scenes/components/magnetized_component.tscn")
	EventBus.emit_signal.call_deferred("polarityChanged", polarity)
	EventBus.emit_signal.call_deferred("massChanged", mass)
	_setup_beam()
	_setup_particles()

# --------------------------------------------------------
# Beam Setup
# --------------------------------------------------------

func _setup_beam() -> void:
	_beam = Line2D.new()
	_beam.width = beam_width
	_beam.default_color = pull_color
	_beam.visible = false
	_beam.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_beam.end_cap_mode = Line2D.LINE_CAP_ROUND
	# Add to parent so it draws in world space alongside the player
	get_parent().add_child.call_deferred(_beam)

func _setup_particles() -> void:
	_particles = CPUParticles2D.new()
	_particles.emitting = false
	_particles.amount = 12
	_particles.lifetime = 0.4
	_particles.gravity = Vector2.ZERO
	_particles.spread = 10.0
	_particles.initial_velocity_min = 40.0
	_particles.initial_velocity_max = 80.0
	_particles.scale_amount_min = 2.0
	_particles.scale_amount_max = 4.0
	get_parent().add_child.call_deferred(_particles)

# --------------------------------------------------------
# Physics Process
# --------------------------------------------------------

func _physics_process(delta) -> void:
	swap_polarity()
	manageMass()

	var beam_color = pull_color if !polarity else push_color
	var shoot_held = Input.is_action_pressed("shoot")

	ray.force_raycast_update()

	if shoot_held and ray.is_colliding():
		var collider = ray.get_collider()
		if collider.is_in_group("magnetic"):
			var magnetic_object = collider.get_node_or_null("Magnetic")
			if magnetic_object != null:
				handle_magnetism(get_parent(), collider, magnetic_object)
				_update_beam(true, ray.get_collision_point(), beam_color)
				_update_target_outline(collider, true, beam_color)
			else:
				_clear_beam()
				_clear_target_outline()
		else:
			_clear_beam()
			_clear_target_outline()
	elif ray.is_colliding():
		var collider = ray.get_collider()
		#print("ray hit: ", collider.name)
		#print("in magnetic group: ", collider.is_in_group("magnetic"))
		var magnetic_object = collider.get_node_or_null("Magnetic")
		#print("Magnetic node found: ", magnetic_object)
		if collider.is_in_group("magnetic"):
			if magnetic_object != null:
				_update_beam(true, ray.get_collision_point(), beam_color)
				_update_target_outline(collider, true, beam_color)
		else:
			_clear_beam()
			_clear_target_outline()
	else:
		_clear_beam()
		_clear_target_outline()

	if Input.is_action_just_pressed("magnetize"):
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider.is_in_group("magnetic"):
				var magnetic_object = collider.get_node_or_null("Magnetic")
				if magnetic_object != null:
					magnetize(collider)

# --------------------------------------------------------
# Beam Update
# --------------------------------------------------------

func _update_beam(hit: bool, hit_position: Vector2, color: Color) -> void:
	if !hit:
		_beam.visible = false
		_particles.emitting = false
		return

	_beam.visible = true
	_particles.emitting = true
	_beam.default_color = color

	# Line2D is a child of the player so points are in the player's local space
	var local_hit = get_parent().to_local(hit_position)
	_beam.clear_points()
	_beam.add_point(get_parent().to_local(get_parent().global_position))
	_beam.add_point(local_hit)

	# Pulse beam width
	_beam.width = beam_width + sin(Time.get_ticks_msec() * 0.001 * pulse_speed) * 1.5

	# Point particles along the beam, flowing based on polarity
	_particles.color = color
	var dir = local_hit.normalized()
	if !polarity:
		# Pull: particles flow from object toward player
		_particles.position = local_hit
		_particles.direction = -dir
	else:
		# Push: particles flow from player toward object
		_particles.position = get_parent().to_local(get_parent().global_position)
		_particles.direction = dir

func _clear_beam() -> void:
	_beam.visible = false
	_particles.emitting = false

# --------------------------------------------------------
# Outline Update
# --------------------------------------------------------

func _update_target_outline(new_target: RigidBody2D, active: bool, color: Color) -> void:
	if current_target != null and current_target != new_target:
		_set_outline(current_target, false, Color.WHITE)
	current_target = new_target
	_set_outline(current_target, active, color)

func _clear_target_outline() -> void:
	if current_target != null:
		_set_outline(current_target, false, Color.WHITE)
		current_target = null

func _set_outline(target: RigidBody2D, active: bool, color: Color) -> void:
	var magnetic_node = target.get_node_or_null("Magnetic")
	if magnetic_node != null:
		magnetic_node.set_outline(active, color)

# --------------------------------------------------------
# Magnetism
# --------------------------------------------------------

func handle_magnetism(body1: CharacterBody2D, body2: RigidBody2D, magnetComponent: Magnetic) -> void:
	var strength = magnetic_field * charge
	var total_mass: float = mass + magnetComponent.mass
	var objectInfluence: float = mass / total_mass
	var playerInfluence: float = magnetComponent.mass / total_mass

	var direction = body1.global_position.direction_to(body2.global_position)
	if !polarity:
		direction = body2.global_position.direction_to(body1.global_position)
	var forceVector = direction * strength
	body2.apply_central_force(forceVector * objectInfluence)
	body1.velocity += ((-1 * forceVector) / mass) * playerInfluence * get_physics_process_delta_time()

func swap_polarity() -> void:
	if Input.is_action_just_pressed("swap_polarity"):
		polarity = !polarity
		EventBus.emit_signal("polarityChanged", polarity)
	var sprite: Sprite2D = get_node_or_null("../Magnet")
	if polarity:
		sprite.modulate = Color(1, 0, 0)
	else:
		sprite.modulate = Color(0, 0, 1)

func manageMass() -> void:
	if ray2.is_colliding():
		var collider2 = ray2.get_collider()
		if collider2.is_in_group("metal_pile"):
			if Input.is_action_just_pressed("increment_mass"):
				mass *= 2
				EventBus.emit_signal("massChanged", mass)
			if Input.is_action_just_pressed("decrement_mass"):
				mass /= 2
				EventBus.emit_signal("massChanged", mass)

func getMass() -> float:
	return mass

func getPolarity() -> bool:
	return polarity

func magnetize(body2: RigidBody2D) -> void:
	var instance = magnetized_component.instantiate()
	if body2.get_node_or_null("MagnetizedComponent"):
		var existing = body2.get_node_or_null("MagnetizedComponent")
		existing.name = "DESTROY"
		existing.queue_free()
	body2.add_child(instance)
	instance.name = "MagnetizedComponent"
	instance.construct.call_deferred(charge, magnetic_field, polarity)
