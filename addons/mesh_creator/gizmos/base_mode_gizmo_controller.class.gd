# namespace MeshCreator_Gizmos
extends Reference
class_name MeshCreator_Gizmos_BaseModeGizmoController

var MeshCreatorInstance = preload("res://addons/mesh_creator/MeshCreatorInstance.gd")
var meshTools = MeshCreator_MeshTools.new()

const MATERIALS = {
	FACE_UNSELECTED = null,
	FACE_SELECTED = null,
	FACE_SELECTED_LINE = null
}

var _gizmoPlugin
func get_gizmo_plugin(): return _gizmoPlugin

var _gizmo
func get_gizmo(): return _gizmo

func get_selected_faces_ids() -> Array:
	return get_gizmo().get_face_selection_store().get_store()
	
func get_selected_faces():
	return get_gizmo().get_spatial_node().get_mc_mesh().get_faces_selection(get_selected_faces_ids())
	
func get_selected_vertices_ids() -> Array:
	return get_gizmo().get_vertex_selection_store().get_store()

var _activeTool: MeshCreator_Gizmos_BaseGizmoTool = null
func get_active_tool():	return _activeTool	

func get_active_tool_name() -> String:
	if (_activeTool != null):
		return _activeTool.get_tool_name()
	return ""

func _init(gizmo):
	_gizmo = gizmo	
	pass
	
func setup(plugin):
	_gizmoPlugin = plugin	
	
# do preparation here
func set_active():
	_gizmo.clear()
	_gizmo.hide_cursor_3d()
	pass
	
# do cleanup here
func set_inactive():
	_gizmo.clear()
	_gizmo.hide_cursor_3d()
	pass	

func activate_tool(what):
	if (what == _activeTool):
		return
	if (_activeTool != null):
		_activeTool.set_inactive()
	what.set_active()
	_activeTool = what
	gizmo_redraw()
	_gizmo.get_spatial_node().ActiveEditorPlugin.notify_state_changed()
	pass

func gizmo_redraw():
	print("redrawing")
	_gizmo.clear()	
	
	var mci = _gizmo.get_spatial_node()
	if (not mci is MeshCreatorInstance):
		return	
		
	_gizmo.update_properties_panels()
	
	var handleIdx = 0			
	if (_activeTool != null):
		handleIdx = _activeTool.on_gizmo_add_handles(handleIdx)
		_activeTool.on_gizmo_redraw(_gizmo)		
	pass
	
func gizmo_get_handle_name(index):
	if (_activeTool != null):
		return _activeTool.on_gizmo_get_handle_name(index)		

func gizmo_get_handle_value(index):
	if (_activeTool != null):
		return _activeTool.on_gizmo_get_handle_value(index)		

func gizmo_commit_handle(index, restore, cancel=false):	
	if (_activeTool != null):
		_activeTool.on_gizmo_commit_handle(index, restore, cancel)
		gizmo_redraw()
	pass	

func gizmo_set_handle(index, camera, screen_point : Vector2):
	prints("set_handle index", index, screen_point)
	if (_activeTool != null):
		_activeTool.on_gizmo_set_handle(index, camera, screen_point)
	pass	
	
# editor mouse click events
func gizmo_forward_mouse_button(event: InputEventMouseButton, camera):	
	# let active tools handle events
	if (_activeTool != null):
		return _activeTool.on_input_mouse_button(event, camera)	
	return false

# editor mouse move events
func gizmo_forward_mouse_move(event, camera):
	# let active tools handle mouse movement
	if (_activeTool != null):
		return _activeTool.on_input_mouse_move(event, camera)	
	return false	
	
# editor keyboard events
func gizmo_forward_key_input(event, camera):
	# let active tools handle key input
	if (_activeTool != null):
		return _activeTool.on_input_key(event, camera)	
	return false	
		
func request_action(actionName, params = []):	
	pass
	
func on_tool_request_finish():
	if (_activeTool != null):
		_activeTool.set_inactive()
	_activeTool = null
	pass
	
func request_redraw():
	# @todo very bad way to propagate this
	get_gizmo().get_spatial_node().ActiveEditorPlugin.notify_state_changed()
	# @todo this may results into an endless loop!	
	gizmo_redraw()
	pass
