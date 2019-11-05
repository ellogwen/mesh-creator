tool
#class_name MeshCreator_Signals
extends Node

signal UI_GENERATOR_GENERATE_MESH
func emit_UI_GENERATOR_GENERATE_MESH(generator):
	emit_signal("UI_GENERATOR_GENERATE_MESH", generator)
	