class_name MagnetComponent
extends Node

@export_subgroup("Settings")
@export var charge: float = 100.0;
@export var magnetic_field: float = 10.0;
@export var mass: float = 2
@onready var ray = $RayCast2D


var polarity: bool = false
var current_massIndex: int = 3


func _physics_process(delta) -> void:
	swap_polarity()
	manageMass()
	if Input.is_action_pressed("shoot"):
		ray.force_raycast_update()
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider.is_in_group("magnetic"):
				print("applying force")
				var magnetic_object = collider.get_node("Magnetic")
				if(magnetic_object != null):
					handle_magnetism(get_parent(), collider, magnetic_object)

#True polarity - push
#False polarity - pull
func handle_magnetism(body1: CharacterBody2D, body2: RigidBody2D, magnetComponent: Magnetic) -> void:
	var strength = magnetic_field * charge
	var total_mass: float = mass + magnetComponent.mass
	var objectInfluence: float = mass/total_mass
	var playerInfluence: float = magnetComponent.mass/total_mass
	
	
	var direction = body1.global_position.direction_to(body2.global_position)
	if !polarity:
		direction = body2.global_position.direction_to(body1.global_position)
	var forceVector = direction * strength
	body2.apply_central_force(forceVector * objectInfluence)
	body1.velocity += ((-1 * forceVector)/mass) * playerInfluence * get_physics_process_delta_time()
		
		
			
func swap_polarity() -> void:
	if Input.is_action_just_pressed("swap_polarity"):
		polarity = !polarity

func manageMass() -> void:
	if Input.is_action_just_pressed("increment_mass"):
		mass *= 2
		print_debug(mass)
	if  Input.is_action_just_pressed("decrement_mass"):
		mass /= 2
		print_debug(mass)
	
func getMass() -> float:
	return mass;
