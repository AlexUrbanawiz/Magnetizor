class_name Magnet
extends Node

@export_subgroup("Settings")
@export var charge: float = 100.0;
@export var magnetic_field: float = 10.0;

@onready var ray = $RayCast2D

var polarity: bool = false


func _physics_process(delta) -> void:
	swap_polarity()
	if Input.is_action_pressed("shoot"):
		ray.force_raycast_update()
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider.is_in_group("magnetic"):
				print("applying force")
				handle_magnetism(get_parent(), collider)

#True polarity - push
#False polarity - pull
func handle_magnetism(body1: CharacterBody2D, body2: RigidBody2D) -> void:
	var direction = body1.global_position.direction_to(body2.global_position)
	if !polarity:
		direction = body2.global_position.direction_to(body1.global_position)
	body2.apply_central_force(direction * magnetic_field * charge)
			
func swap_polarity() -> void:
	if Input.is_action_just_pressed("swap_polarity"):
		polarity = !polarity
