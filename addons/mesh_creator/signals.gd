tool
#class_name MeshCreator_Signals
extends Node

signal UI_GENERATOR_GENERATE_MESH
func emit_UI_GENERATOR_GENERATE_MESH(generator):
	emit_signal("UI_GENERATOR_GENERATE_MESH", generator)

signal UI_VIEWPORT_MOUSE_MOTION
func emit_UI_VIEWPORT_MOUSE_MOTION(event, camera):
	emit_signal("UI_VIEWPORT_MOUSE_MOTION", event, camera)
	
signal UI_VIEWPORT_MOUSE_BUTTON
func emit_UI_VIEWPORT_MOUSE_BUTTON(event, camera):
	emit_signal("UI_VIEWPORT_MOUSE_BUTTON", event, camera)
	