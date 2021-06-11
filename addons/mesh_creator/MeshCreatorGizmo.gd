extends EditorSpatialGizmo

var MeshCreatorInstance = preload("res://addons/mesh_creator/MeshCreatorInstance.gd")
var Cursor3D = preload("res://addons/mesh_creator/Cursor3D.gd")

var EditorHelperScript = preload("res://addons/mesh_creator/MCEditorHelper.gd")
var editorHelperNode

signal VERTEX_POSITION_CHANGED

var EDITOR_TOOLS = {
	VERTEX_SELECTION = null,
	VERTEX_TRANSLATE = null,
	EDGE_SELECTION = null,
	EDGE_TRANSLATE = null,
	FACE_SELECTION = null,
	FACE_TRANSLATE = null,
	FACE_INSET = null,
	FACE_LOOPCUT = null,
}

func get_editor_tool(name: String):	return EDITOR_TOOLS[name]
func get_tool(toolName): return get_editor_tool(toolName)
	
func set_editor_tool(name, editorTool):
	EDITOR_TOOLS[name] = editorTool
	
var _faceSelectionStore
var _edgeSelectionStore
var _vertexSelectionStore
func get_face_selection_store(): return _faceSelectionStore
func get_edge_selection_store(): return _edgeSelectionStore
func get_vertex_selection_store(): return _vertexSelectionStore

var _cursor3D
var _active_gizmo_controller = null
var _vertexModeGizmoController
var _edgeModeGizmoController
var _faceModeGizmoController

func _init():
	_faceSelectionStore = MeshCreator_Mesh_SelectionStore.new()
	_edgeSelectionStore = MeshCreator_Mesh_SelectionStore.new()
	_vertexSelectionStore = MeshCreator_Mesh_SelectionStore.new()
	_vertexModeGizmoController = MeshCreator_Gizmos_VertexModeGizmoController.new(self)
	_edgeModeGizmoController = MeshCreator_Gizmos_EdgeModeGizmoController.new(self)
	_faceModeGizmoController = MeshCreator_Gizmos_FaceModeGizmoController.new(self)	
	pass
	
func setup(plugin):
	_vertexModeGizmoController.setup(plugin)
	_edgeModeGizmoController.setup(plugin)
	_faceModeGizmoController.setup(plugin)
	pass
	
func _add_editor_helper():
	var parent = get_spatial_node().get_parent()
	if parent.has_node("MC_EditorHelperNode"):
		return
	var helperNode = Spatial.new()
	helperNode.name = "MC_EditorHelperNode"
	helperNode.set_script(EditorHelperScript)
	parent.add_child(helperNode)
	helperNode.set_owner(parent.get_owner())
	pass
	
	

func update_properties_panels():	
	var facePropPanel: Panel = get_plugin().get_face_properties_panel()
	var edgePropPanel: Panel = get_plugin().get_edge_properties_panel()
	edgePropPanel.hide()
	facePropPanel.hide()
	
	if (get_plugin().get_creator().SelectionMode == 3):
		facePropPanel.set_mesh_creator_instance(get_spatial_node())
		if not facePropPanel.is_connected("USER_INPUT", self, "on_face_property_value_changed"):
			facePropPanel.connect("USER_INPUT", self, "on_face_property_value_changed")
		var selectedFacesIds = get_face_selection_store().get_store()
		if (selectedFacesIds.empty()):			
			facePropPanel.set_face_id(-1)
			facePropPanel.hide()			
		else:			
			facePropPanel.set_face_id(selectedFacesIds.back())
			facePropPanel.update_values()
			facePropPanel.show()
			
	if (get_plugin().get_creator().SelectionMode == 2):
		edgePropPanel.set_mesh_creator_instance(get_spatial_node())
		if not edgePropPanel.is_connected("USER_INPUT", self, "on_edge_property_value_changed"):
			edgePropPanel.connect("USER_INPUT", self, "on_edge_property_value_changed")
		var selectedEdgeIds = get_edge_selection_store().get_store()
		if (selectedEdgeIds.empty()):			
			edgePropPanel.set_edge_id(-1)
			edgePropPanel.hide()			
		else:			
			edgePropPanel.set_edge_id(selectedEdgeIds.back())
			edgePropPanel.update_values()
			edgePropPanel.show()
			
	pass
	
func on_edge_property_value_changed(context, value):
	var edgeId = get_plugin().get_edge_properties_panel().get_edge_id()
	if (edgeId < 0):
		return
		
	var mci = get_spatial_node()
	if (mci == null):
		return
		
	var edge = mci.get_mc_mesh().get_edge(edgeId)
	if (edge == null):
		return
	var center = edge.get_center()
	var offset = Vector3.ZERO
	if (context == "EDGE_X"):
		offset.x = value - center.x
	if (context == "EDGE_Y"):
		offset.x = value - center.y
	if (context == "EDGE_Z"):
		offset.x = value - center.z
		
	if offset != Vector3.ZERO:
		var meshTools = preload("res://addons/mesh_creator/MeshTools.gd").new()
		mci.get_mc_mesh().translate_vertex(edge.get_a().get_mesh_index(), offset)
		mci.get_mc_mesh().translate_vertex(edge.get_b().get_mesh_index(), offset)

		meshTools.SetMeshFromMeshCreatorMesh(mci.get_mc_mesh(), mci)	
		redraw()
	
func on_face_property_value_changed(context, value):	
	var faceId = get_plugin().get_face_properties_panel().get_face_id()
	if faceId < 0:
		return
		
	var mci = get_spatial_node()
	if mci == null:
		return
		
	var face = mci.get_mc_mesh().get_face(faceId)
	if (face == null):
		return
	var centroid = face.get_centroid()
	var offset = Vector3.ZERO
	if (context == "CENTER_X"):
		offset.x = value - centroid.x
	if (context == "CENTER_Y"):
		offset.y = value - centroid.y
	if (context == "CENTER_Z"):
		offset.z = value - centroid.z
	if offset != Vector3.ZERO:
		var meshTools = preload("res://addons/mesh_creator/MeshTools.gd").new()
		for vtx in face.get_vertices():
			mci.get_mc_mesh().translate_vertex(vtx.get_mesh_index(), offset)
		
		meshTools.SetMeshFromMeshCreatorMesh(mci.get_mc_mesh(), mci)		
		redraw()
		
	
func set_cursor_3d(pos):
	_cursor3D = get_cursor_3d()
	_cursor3D.global_transform.origin = pos
	# resetting scale/rot
	#(_cursor3D.global_transform as Transform).basis = Vector3.ZERO
	#(_cursor3D as Spatial).set_scale(Vector3.ONE)
	prints("setting cursor to", pos)
	pass

func show_cursor_3d():
	if (_cursor3D != null):
		_cursor3D.show()
		
func hide_cursor_3d():
	if (_cursor3D != null):
		_cursor3D.hide()
		
func get_cursor_3d():
	if (_cursor3D == null):
		_cursor3D = Cursor3D.new()
		_cursor3D.name = "Cursor3D"
		get_spatial_node().get_node("MC_Editor").add_child(_cursor3D)
		_cursor3D.set_owner(get_spatial_node().get_owner())
		# _cursor3D.connect("transform_changed", self, "_on_cursor_3d_transform_changed")
		_cursor3D.hide()
	return _cursor3D
	
func focus_cursor_3d():
	var selectionModel = get_plugin().get_creator().get_editor_interface().get_selection()
	selectionModel.clear()
	selectionModel.add_node(_cursor3D)
	
func focus_mesh_instance():
	var selectionModel = get_plugin().get_creator().get_editor_interface().get_selection()
	selectionModel.clear()
	selectionModel.add_node(get_spatial_node())
		
func _set_active_active_gizmo_controller(controller):
	if (_active_gizmo_controller != null):
		_active_gizmo_controller.set_inactive()
	
	if (controller != null):
		controller.set_active()
	
	_active_gizmo_controller = controller
	pass
	
func get_active_gizmo_controller():
	return _active_gizmo_controller

func redraw():
	print("Redraw (Selection Mode) " + str(get_plugin().get_creator().SelectionMode))
	match(get_plugin().get_creator().SelectionMode):
		# mesh
		0: _set_active_active_gizmo_controller(null)
		# vertex
		1: _set_active_active_gizmo_controller(_vertexModeGizmoController)
		# edge
		2: _set_active_active_gizmo_controller(_edgeModeGizmoController)
		# face
		3: _set_active_active_gizmo_controller(_faceModeGizmoController)
		# none
		_: _set_active_active_gizmo_controller(null)
		
	if (_active_gizmo_controller != null):
		_active_gizmo_controller.gizmo_redraw()
		
	
	update_properties_panels()	
	_add_editor_helper()
	pass
	
func get_handle_name(index):
	if (_active_gizmo_controller != null):
		return _active_gizmo_controller.gizmo_get_handle_name(index)

func get_handle_value(index):
	if (_active_gizmo_controller != null):
		return _active_gizmo_controller.gizmo_get_handle_value(index)

#func is_handle_highlighted(index):
#	prints("is_handle_highlighted index", index)
#	return true

func set_handle(index, camera, screen_point):
	if (_active_gizmo_controller != null):
		_active_gizmo_controller.gizmo_set_handle(index, camera, screen_point)	

# Commit a handle being edited (handles must have been previously added by add_handles()).
# If the cancel parameter is true, an option to restore the edited value to the original is provided.
func commit_handle(index, restore, cancel=false ):
	prints("commit_handle", index, restore, cancel)
	if (_active_gizmo_controller != null):
		_active_gizmo_controller.gizmo_commit_handle(index, restore, cancel)
	else:
		redraw()
	pass
	
func _on_cursor_3d_transform_changed():
	print("cursor transform changed")
	pass
	
func on_creator_mode_changed():
	redraw()
	pass

func is_mci_selected() -> bool:
	var selectedNodes = get_plugin().get_creator().get_editor_interface().get_selection().get_selected_nodes()
	var mci = get_spatial_node()
	for node in selectedNodes:
		if node == get_spatial_node():
			return true
	return false
	
func is_cursor_3d_selected() -> bool:
	var selectedNodes = get_plugin().get_creator().get_editor_interface().get_selection().get_selected_nodes()
	var mci = get_spatial_node()
	for node in selectedNodes:
		if node == get_cursor_3d():
			return true
	return false

func force_mci_selection() -> void:
	var mci = get_spatial_node()
	if (mci != null):
		var nodeSelection = get_plugin().get_creator().get_editor_interface().get_selection()
		for node in nodeSelection.get_selected_nodes():
			prints(node)
			if (node != mci and node != _cursor3D):
				nodeSelection.remove_node(node)

func forward_editor_mouse_button_input(event, camera) -> bool:
	force_mci_selection()
	if (not is_mci_selected() and not is_cursor_3d_selected()):
		# don't allow deselection when not on mesh mod
		if (get_plugin().get_creator().SelectionMode == 0):
			print("MCI/Cursor not selected, no key forwarding")
			return false
		else:
			return true
		
	if (_active_gizmo_controller != null):
		return _active_gizmo_controller.gizmo_forward_mouse_button(event, camera)
		
	return false
	
func forward_editor_mouse_motion_input(event, camera) -> bool:
	if (_active_gizmo_controller != null):
		return _active_gizmo_controller.gizmo_forward_mouse_move(event, camera)
	return false
	
func forward_editor_key_input(event, camera) -> bool:
	if (_active_gizmo_controller != null):
		return _active_gizmo_controller.gizmo_forward_key_input(event, camera)
	return false
