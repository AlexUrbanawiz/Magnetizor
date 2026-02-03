class_name MovementComponent
extends Node

@export_subgroup("Settings")
@export var speed: float = 100
@export var ground_accel_speed: float = 6.0
@export var ground_decel_speed: float = 8.0
@export var air_accel_speed: float = 10.0
@export var air_decel_speed: float = 3.0

func handle_horizontal_movement(body: CharacterBody2D, magnet: MagnetComponent, direction: float) -> void:
	#When the magnet's mass is higher I want the accel speed to be lower, but the decel speed to be lower. So it takes a while to get going, but it also takes more to stop.
	var velocity_change_speed: float = 0.0
	if body.is_on_floor():
		velocity_change_speed = ground_accel_speed if direction != 0 else ground_decel_speed
	else:
		velocity_change_speed = air_accel_speed if direction != 0 else air_decel_speed
	
	body.velocity.x = move_toward(body.velocity.x, direction* speed, velocity_change_speed)
	
