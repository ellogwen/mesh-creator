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
	
	MeshCreator_Signals.connect("UI_MESH_CHANGE_TEXTURE", self, "on_ui_mesh_change_texture")
	

var _meshCreatorGizmos = []
func create_gizmo(spatial):
	if spatial is MeshCreatorInstance:
		if (spatial.get_mc_gizmo() == null):
			var gizmo = MeshCreatorGizmo.new()
			get_creator().connect("mode_changed", gizmo, "on_creator_mode_changed")		
			gizmo.setup(self)
			spatial.set_mc_gizmo(gizmo)
			_meshCreatorGizmos.push_back(gizmo)
			gizmo.set_spatial_node(spatial)
		return spatial.get_mc_gizmo()
	return null
		
#func get_mc_gizmo():	
#	return _meshCreatorGizmo
		
func _on_toolbox_tool_action(actionName, params):
	for g in _meshCreatorGizmos:
		if (g.is_getting_handled):
			var controller = g.get_active_gizmo_controller()
			if (controller != null):
				controller.request_action(actionName, params)
	pass
			
func forward_editor_mouse_button_input(event, camera) -> bool:
	MeshCreator_Signals.emit_UI_VIEWPORT_MOUSE_BUTTON(event, camera)
	for g in _meshCreatorGizmos:
		if g.forward_editor_mouse_button_input(event, camera):
			return true
	return false
	
func forward_editor_mouse_motion_input(event, camera) -> bool:
	MeshCreator_Signals.emit_UI_VIEWPORT_MOUSE_MOTION(event, camera)
	for g in _meshCreatorGizmos:			
		if g.forward_editor_mouse_motion_input(event, camera):
			return true
	return false
	
func forward_editor_key_input(event, camera) -> bool:
	for g in _meshCreatorGizmos:
		prints("visible?", g.is_getting_handled)
		if g.forward_editor_key_input(event, camera):
			return true
	return false	
	
func get_face_properties_panel():
	return get_creator().get_face_properties_panel()
	
func get_edge_properties_panel():
	return get_creator().get_edge_properties_panel()
	
func on_editor_handles(obj):
	for g in _meshCreatorGizmos:
		prints(g.get_spatial_node(), obj)
		if (g.get_spatial_node() == obj):
			g.is_getting_handled = true
		else:
			g.is_getting_handled = false
			
func on_ui_mesh_change_texture(texture_id):
	if (get_creator().SelectionMode == 0):
		for node in (get_creator().get_editor_interface() as EditorInterface).get_selection().get_selected_nodes():
			if (node is MeshCreatorInstance):
				if (node.has_method("set_texture_id")):
					node.set_texture_id(texture_id)
	
#func get_active_tool_name():
#	return get_mc_gizmo().get_active_gizmo_controller().get_active_tool_name()
	
#func get_active_tool():	
#	if _meshCreatorGizmo != null:		
#		var controller = _meshCreatorGizmo.get_active_gizmo_controller()		
#		if controller != null:			
#			return controller.get_active_tool()
#	return null
