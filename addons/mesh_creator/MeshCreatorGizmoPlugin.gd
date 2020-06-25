extends EditorSpatialGizmoPlugin

var MeshCreatorInstance = preload("res://addons/mesh_creator/MeshCreatorInstance.gd")
var MeshCreatorGizmo = preload("res://addons/mesh_creator/MeshCreatorGizmo.gd")
var HandleMaterial = preload("res://addons/mesh_creator/materials/handle.material")
var HandleSelectedMaterial

var HandleForwardMaterial
var HandleUpMaterial
var HandleRightMaterial

var _meshCreator = null

func set_creator(mc):
	_meshCreator = mc
	
func get_creator():
	return _meshCreator

func get_name():
	return "MeshCreatorInstance"

func _init():
	create_material("face_select_line", Color.yellow, false, false, false)	
	create_material("lines", Color.green, false, false, false)	
	create_handle_material("handles_vertex", false)
	create_handle_material("handles_vertex_selected", false)		
	HandleSelectedMaterial = HandleMaterial.duplicate()
	HandleSelectedMaterial.albedo_color = Color.green				
	
	HandleForwardMaterial = HandleMaterial.duplicate()
	HandleUpMaterial = HandleMaterial.duplicate()
	HandleRightMaterial = HandleMaterial.duplicate()
	HandleForwardMaterial.albedo_color = Color.blue
	HandleUpMaterial.albedo_color = Color.green
	HandleRightMaterial.albedo_color = Color.red

var _meshCreatorGizmo = null
func create_gizmo(spatial):
	if spatial is MeshCreatorInstance:		
		_meshCreatorGizmo = MeshCreatorGizmo.new()
		get_creator().connect("mode_changed", _meshCreatorGizmo, "on_creator_mode_changed")		
		_meshCreatorGizmo.setup(self)		
		return _meshCreatorGizmo
	else:
		return null
		
func get_mc_gizmo():	
	return _meshCreatorGizmo
		
func _on_toolbox_tool_action(actionName, params):	
	if (_meshCreatorGizmo != null):
		var controller = _meshCreatorGizmo.get_active_gizmo_controller()
		if (controller != null):
			controller.request_action(actionName, params)	
	pass
			
func forward_editor_mouse_button_input(event, camera) -> bool:
	MeshCreator_Signals.emit_UI_VIEWPORT_MOUSE_BUTTON(event, camera)
	if (_meshCreatorGizmo != null):
		return _meshCreatorGizmo.forward_editor_mouse_button_input(event, camera)
	return false
	
func forward_editor_mouse_motion_input(event, camera) -> bool:
	MeshCreator_Signals.emit_UI_VIEWPORT_MOUSE_MOTION(event, camera)
	if (_meshCreatorGizmo != null):
		return _meshCreatorGizmo.forward_editor_mouse_motion_input(event, camera)
	return false
	
func forward_editor_key_input(event, camera) -> bool:
	if (_meshCreatorGizmo != null):
		return _meshCreatorGizmo.forward_editor_key_input(event, camera)
	return false	
	
func get_face_properties_panel():
	return get_creator().get_face_properties_panel()
	
func get_edge_properties_panel():
	return get_creator().get_edge_properties_panel()	
	
func get_active_tool_name():
	return get_mc_gizmo().get_active_gizmo_controller().get_active_tool_name()
	
func get_active_tool():	
	if _meshCreatorGizmo != null:		
		var controller = _meshCreatorGizmo.get_active_gizmo_controller()		
		if controller != null:			
			return controller.get_active_tool()
	return null
