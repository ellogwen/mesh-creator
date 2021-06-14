tool
#class_name MeshCreator_Signals
extends Node

var _editorPlugin

func get_editor_plugin():
	return _editorPlugin

func set_editor_plugin(editorPlugin):
	_editorPlugin = editorPlugin

signal UI_GENERATOR_GENERATE_MESH
func emit_UI_GENERATOR_GENERATE_MESH(generator):
	emit_signal("UI_GENERATOR_GENERATE_MESH", generator)

signal UI_VIEWPORT_MOUSE_MOTION
func emit_UI_VIEWPORT_MOUSE_MOTION(event, camera):
	emit_signal("UI_VIEWPORT_MOUSE_MOTION", event, camera)
	
signal UI_VIEWPORT_MOUSE_BUTTON
func emit_UI_VIEWPORT_MOUSE_BUTTON(event, camera):
	emit_signal("UI_VIEWPORT_MOUSE_BUTTON", event, camera)
	
signal UI_MESH_CHANGE_TEXTURE(texture_id)
func emit_UI_MESH_CHANGE_TEXTURE(texture_id):
	emit_signal("UI_MESH_CHANGE_TEXTURE", texture_id)
	
