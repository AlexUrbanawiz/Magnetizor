class_name Magnet
extends Node

@export_subgroup("Settings")
@export var charge: float = 10.0;
@export var magnetic_field: float = 10.0;

#True polarity - push
#False polarity - pull
func handle_magnetism(body: CharacterBody2D, polarity: bool) -> void:
	if polarity:
		
