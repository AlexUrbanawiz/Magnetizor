class_name GravityComponent
extends Node

@export_subgroup("Settings")
@export var gravity: float = 1000.0
@export var gravity_mass_exponent: float = 0.4
@export var max_gravity_multiplier: float = 2.5

var is_falling: bool = false

func handle_gravity(body: CharacterBody2D, magnet: MagnetComponent, delta: float) -> void:
	if not body.is_on_floor():
		var gravity_multiplier = clamp(
			pow(magnet.getMass() / 2.0, gravity_mass_exponent),
			0.1,
			max_gravity_multiplier
		)
		body.velocity.y += gravity * delta * gravity_multiplier

	is_falling = body.velocity.y > 0 and not body.is_on_floor()
