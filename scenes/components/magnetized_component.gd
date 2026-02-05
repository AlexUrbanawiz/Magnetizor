class_name MagnetizedComponent
extends Area2D

@export_category("Settings")
@export var charge: float = 100.0
@export var magnetic_field: float = 10.0
@export var polarity: bool = false
@onready var collisionShape: CollisionShape2D = $CollisionShape2D
@onready var selfMagneticComponent = get_node_or_null("../Magnetic")
@onready var sprite: Sprite2D = get_node_or_null("../Sprite2D")
@onready var objectCollisionShape: CollisionShape2D = get_node_or_null("../CollisionShape2D")


var mass: float = 0
var objectsInRange = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collisionShape.shape = objectCollisionShape.shape
	collisionShape.scale = objectCollisionShape.scale
	collisionShape.scale.x += magnetic_field/8
	collisionShape.scale.y += magnetic_field/8
	collisionShape.scale *= magnetic_field/8
	
	mass = selfMagneticComponent.get_mass()
	print("Magnetized!!")

func _on_body_entered(body: Node2D) -> void:
	print("Body entered")
	if body.is_in_group("magnetic"):
		var magnetic_object = body.get_node_or_null("Magnetic")
		if(magnetic_object != null and body != get_parent()):
			print("attracting %s" % body.name)
			objectsInRange.append(body)
	elif body.get_node_or_null("MagnetComponent") != null:
		objectsInRange.append(body)


func _on_body_exited(body: Node2D) -> void:
	var objectIndex = objectsInRange.find(body)
	if objectIndex != -1:
		objectsInRange.remove_at(objectIndex)


func _process(delta: float) -> void:
	for body in objectsInRange:
		if body.get_node_or_null("Magnetic") != null:
			if body.get_node_or_null("MagnetizedComponent") != null:
				handle_double_magnetized(get_parent(), body, body.get_node_or_null("MagnetizedComponent"))
			else:
				handle_magnetized_magnetic(get_parent(), body, body.get_node_or_null("Magnetic"))
			
		elif body.get_node_or_null("MagnetComponent") != null:
			handle_magnetized_magnet(get_parent(), body, body.get_node_or_null("MagnetComponent"))
		


func handle_magnetized_magnetic(body1: RigidBody2D, body2: RigidBody2D, otherMagneticComponent: Magnetic) -> void:
	#print("magnet power")
	var strength = magnetic_field * charge
	var total_mass: float = mass + otherMagneticComponent.mass
	var objectInfluence: float = mass/total_mass
	var selfInfluence: float = otherMagneticComponent.mass/total_mass
	
	
	var direction = body1.global_position.direction_to(body2.global_position)
	if !polarity:
		direction = body2.global_position.direction_to(body1.global_position)
	var forceVector = direction * strength
	body2.apply_central_force(forceVector * objectInfluence)
	body1.apply_central_force((-1 * forceVector) * selfInfluence)
	
func handle_magnetized_magnet(body1: RigidBody2D, body2: CharacterBody2D, magnet_component: MagnetComponent) -> void:
	var strength = magnetic_field * charge
	var total_mass: float = mass + magnet_component.getMass()
	var objectInfluence: float = mass/total_mass
	var selfInfluence: float = magnet_component.getMass()/total_mass
	
	var direction = body1.global_position.direction_to(body2.global_position)
	if polarity == magnet_component.getPolarity():
		direction = body2.global_position.direction_to(body1.global_position)
	var forceVector = direction * strength
	body1.apply_central_force(forceVector * selfInfluence)
	body2.velocity += ((-1 * forceVector)/magnet_component.getMass()) * objectInfluence * get_physics_process_delta_time()

func handle_double_magnetized(body1: RigidBody2D, body2: RigidBody2D, magnet_component: MagnetizedComponent) -> void:
	var strength = magnetic_field * charge
	var total_mass: float = mass + magnet_component.getMass()
	var objectInfluence: float = mass/total_mass
	var selfInfluence: float = magnet_component.getMass()/total_mass
	
	var direction = body1.global_position.direction_to(body2.global_position)
	if polarity == magnet_component.getPolarity():
		direction = body2.global_position.direction_to(body1.global_position)
	var forceVector = direction * strength
	body1.apply_central_force(forceVector * selfInfluence)
	body2.apply_central_force((-1 * forceVector) * objectInfluence)


func construct(charged: float, field: float, pol: bool) -> void:
	charge = charged
	magnetic_field = field
	polarity = pol
	if(polarity):
		sprite.modulate = Color(1, 0, 0)
	else:
		sprite.modulate = Color(0, 0, 1)

func getMass() -> float:
	return mass
func getPolarity() -> bool:
	return polarity
