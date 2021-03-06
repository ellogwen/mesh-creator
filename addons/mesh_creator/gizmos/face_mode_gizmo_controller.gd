# namespace MeshCreator_Gizmos
extends MeshCreator_Gizmos_BaseModeGizmoController
class_name MeshCreator_Gizmos_FaceModeGizmoController


func _init(gizmo).(gizmo):		
	pass
	
func setup(plugin):
	.setup(plugin)
	_setup_tools()
	_setup_materials(plugin)	
	pass
	
# do preparation here
func set_active():
	.set_active()
	pass
	
# do cleanup here
func set_inactive():
	.set_inactive()
	pass	

func activate_tool(what):
	.activate_tool(what)
	pass

func gizmo_redraw():
	.gizmo_redraw()
	
	# make sure at least the selection tool is active
	if (_activeTool == null):
		activate_tool(get_gizmo().get_editor_tool('FACE_SELECTION'))	
	pass
	
func get_spatial_editor_radial_menu():
	return get_gizmo().get_plugin().get_creator().get_editor_radial_menu()
	
# editor mouse click events
func gizmo_forward_mouse_button(event: InputEventMouseButton, camera):	
	return .gizmo_forward_mouse_button(event, camera)

# editor mouse move events
func gizmo_forward_mouse_move(event, camera):
	return .gizmo_forward_mouse_move(event, camera)
	
# editor keyboard events
func gizmo_forward_key_input(event, camera):
	if event is InputEventKey and not event.pressed and event.scancode == KEY_SPACE:
		show_radial_menu()
	return .gizmo_forward_key_input(event, camera)

func _subdivide_selected_faces():
	var undo_redo = MeshCreator_Signals.get_editor_plugin().get_undo_redo()
	undo_redo.create_action("Subdivide Selected Faces")
	var mci = _gizmo.get_spatial_node()
	var old_geometry = mci.get_mc_mesh().geometry()
	
	for face in get_selected_faces():
		mci.get_mc_mesh().subdivide_face(face.get_mesh_index())
	
	var new_geometry = mci.get_mc_mesh().geometry()
	
	undo_redo.add_do_method(meshTools, "SetMeshFromMeshCreatorMeshGeometry", new_geometry, mci)
	undo_redo.add_undo_method(meshTools, "SetMeshFromMeshCreatorMeshGeometry", old_geometry, mci)

	#request_redraw()
	undo_redo.add_do_method(self, "request_redraw")
	undo_redo.add_undo_method(self, "request_redraw")
	undo_redo.commit_action()

func _extrude_selected_faces():
	var undo_redo = MeshCreator_Signals.get_editor_plugin().get_undo_redo()
	undo_redo.create_action("Extrude Selected Faces")
	var mci = _gizmo.get_spatial_node()
	var old_geometry = mci.get_mc_mesh().geometry()
	for face in get_selected_faces():		
		mci.get_mc_mesh().extrude_face(face.get_mesh_index())		
	
	var new_geometry = mci.get_mc_mesh().geometry()	

	#meshTools.SetMeshFromMeshCreatorMesh(mci.get_mc_mesh(), mci)
	undo_redo.add_do_method(meshTools, "SetMeshFromMeshCreatorMeshGeometry", new_geometry, mci)
	undo_redo.add_undo_method(meshTools, "SetMeshFromMeshCreatorMeshGeometry", old_geometry, mci)

	#request_redraw()
	undo_redo.add_do_method(self, "request_redraw")
	undo_redo.add_undo_method(self, "request_redraw")
	undo_redo.commit_action()
	pass	
	
func _remove_selected_faces():
	var undo_redo = MeshCreator_Signals.get_editor_plugin().get_undo_redo()
	undo_redo.create_action("Remove Selected Faces")
	var mci = _gizmo.get_spatial_node()
	var old_geometry = mci.get_mc_mesh().geometry()
	for face in get_selected_faces():
		mci.get_mc_mesh().remove_face(face.get_mesh_index())
	var new_geometry = mci.get_mc_mesh().geometry()
	
	#meshTools.SetMeshFromMeshCreatorMesh(mci.get_mc_mesh(), mci)
	undo_redo.add_do_method(meshTools, "SetMeshFromMeshCreatorMeshGeometry", new_geometry, mci)
	undo_redo.add_undo_method(meshTools, "SetMeshFromMeshCreatorMeshGeometry", old_geometry, mci)

	#request_redraw()
	undo_redo.add_do_method(self, "request_redraw")
	undo_redo.add_undo_method(self, "request_redraw")
	undo_redo.commit_action()
	pass

func inset_selected_faces(factor = 0.25):
	var undo_redo = MeshCreator_Signals.get_editor_plugin().get_undo_redo()
	undo_redo.create_action("Inset Selected Faces")
	var mci = _gizmo.get_spatial_node()
	var old_geometry = mci.get_mc_mesh().geometry()
	for face in get_selected_faces():
		mci.get_mc_mesh().inset_face(face.get_mesh_index(), factor)		
	var new_geometry = mci.get_mc_mesh().geometry()
	
	#meshTools.SetMeshFromMeshCreatorMesh(mci.get_mc_mesh(), mci)
	undo_redo.add_do_method(meshTools, "SetMeshFromMeshCreatorMeshGeometry", new_geometry, mci)
	undo_redo.add_undo_method(meshTools, "SetMeshFromMeshCreatorMeshGeometry", old_geometry, mci)

	#request_redraw()
	undo_redo.add_do_method(self, "request_redraw")
	undo_redo.add_undo_method(self, "request_redraw")
	undo_redo.commit_action()
	pass
	
func loopcut_selected_faces(edgeIndex = 0, insetFactor = 0.5):
	var undo_redo = MeshCreator_Signals.get_editor_plugin().get_undo_redo()
	undo_redo.create_action("Face Loopcut")
	var mci = _gizmo.get_spatial_node()
	var old_geometry = mci.get_mc_mesh().geometry()
	for face in get_selected_faces():
		var lpc = mci.get_mc_mesh().build_loopcut_chain(face.get_mesh_index(), edgeIndex)
		mci.get_mc_mesh().loopcut(lpc, edgeIndex, insetFactor)
	var new_geometry = mci.get_mc_mesh().geometry()
	#meshTools.SetMeshFromMeshCreatorMesh(mci.get_mc_mesh(), mci)
	undo_redo.add_do_method(meshTools, "SetMeshFromMeshCreatorMeshGeometry", new_geometry, mci)
	undo_redo.add_undo_method(meshTools, "SetMeshFromMeshCreatorMeshGeometry", old_geometry, mci)

	#request_redraw()
	undo_redo.add_do_method(self, "request_redraw")
	undo_redo.add_undo_method(self, "request_redraw")
	undo_redo.commit_action()
	pass
	
func on_radial_menu_action(action):
	on_radial_menu_canceled()	
	request_action(action.name)
	pass
	
func on_radial_menu_canceled():
	var spatialEditorRadialMenu = get_spatial_editor_radial_menu()
	spatialEditorRadialMenu.disconnect("radial_menu_canceled", self, "on_radial_menu_canceled")
	spatialEditorRadialMenu.disconnect("radial_menu_action", self, "on_radial_menu_action")
	spatialEditorRadialMenu.hide_menu()
	pass
	
func show_radial_menu():
	var spatialEditorRadialMenu = get_spatial_editor_radial_menu()
	if spatialEditorRadialMenu.visible:
		return
	spatialEditorRadialMenu.connect("radial_menu_action", self, "on_radial_menu_action")
	spatialEditorRadialMenu.connect("radial_menu_canceled", self, "on_radial_menu_canceled")
	spatialEditorRadialMenu.reset()
	#spatialEditorRadialMenu.add_action("TOOL_TRANSLATE", "Translate", "", KEY_G)
	#spatialEditorRadialMenu.add_action("TOOL_SCALE", "Scale", "", KEY_S)
	spatialEditorRadialMenu.add_action("TOOL_INSET", "Inset", "", KEY_I)
	spatialEditorRadialMenu.add_action("TOOL_LOOPCUT", "Loopcut")
	spatialEditorRadialMenu.add_action("TOOL_EXTRUDE", "Extrude", "", KEY_E)
	spatialEditorRadialMenu.add_action("TOOL_SUBDIVIDE", "Subdivide")
	spatialEditorRadialMenu.show_menu()
		
func request_action(actionName, params = []):
	if (actionName == "TOOL_CANCEL"):
		print("Cancel operation")
		activate_tool(get_gizmo().get_editor_tool('FACE_SELECTION'))
	elif (actionName == "TOOL_SELECT"):
		print("Tool Select")
		activate_tool(get_gizmo().get_editor_tool('FACE_SELECTION'))
	#elif (actionName == "TOOL_TRANSLATE"):
	#	print("Tool Move")
	#	activate_tool(get_gizmo().get_editor_tool('FACE_TRANSLATE'))
	elif (actionName == "TOOL_SCALE"):
		print("Tool Scale")
		activate_tool(get_gizmo().get_editor_tool('FACE_SCALE'))
	elif (actionName == "TOOL_INSET"):
		print("Tool Inset")
		activate_tool(get_gizmo().get_editor_tool('FACE_INSET'))
	elif (actionName == "TOOL_LOOPCUT"):
		print("Tool Loopcut")
		activate_tool(get_gizmo().get_editor_tool('FACE_LOOPCUT'))
	elif (actionName == "TOOL_EXTRUDE"):
		print("Action Extrude")
		_extrude_selected_faces()
	elif (actionName == "TOOL_SUBDIVIDE"):
		print("Action Subdivide")
		_subdivide_selected_faces()
	elif (actionName == "TOOL_REMOVE"):
		print("Action Remove Face")
		_remove_selected_faces()	
	pass

func _setup_tools():
	get_gizmo().set_editor_tool('FACE_SELECTION', MeshCreator_Gizmos_FaceSelectionGizmoTool.new(self))
	get_gizmo().set_editor_tool('FACE_TRANSLATE', MeshCreator_Gizmos_FaceTranslateGizmoTool.new(self))
	get_gizmo().set_editor_tool('FACE_SCALE', MeshCreator_Gizmos_FaceScaleGizmoTool.new(self))
	get_gizmo().set_editor_tool('FACE_INSET', MeshCreator_Gizmos_FaceInsetGizmoTool.new(self))
	get_gizmo().set_editor_tool('FACE_LOOPCUT', MeshCreator_Gizmos_FaceLoopcutGizmoTool.new(self))
	pass
	
func _setup_materials(plugin):
	var baseLineMat: SpatialMaterial = plugin.get_material("lines", self)
	MATERIALS.FACE_SELECTED_LINE = baseLineMat.duplicate()	
	pass			
