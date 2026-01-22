class_name Magnet
extends Node

@export_subgroup("Settings")
@export var charge: float = 10.0;
@export var magnetic_field: float = 10.0;

var polarity: bool = false

#True polarity - push
#False polarity - pull
func handle_magnetism(body1: CharacterBody2D, body2: RigidBody2D) -> void:
	if polarity:
			var direction = body1.direction_to(body2.global_position)
			print(direction)
			
func swap_polarity() -> void:
	if Input.is_action_just_pressed("swap_polarity"):
		polarity = !polarity

func shoot_magnet(body: CharacterBody2D)
