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

func _extrude_selected_faces():
	var mci = _gizmo.get_spatial_node()
	for face in get_selected_faces():		
		mci.get_mc_mesh().extrude_face(face.get_mesh_index())		
	meshTools.CreateMeshFromFaces(mci.get_mc_mesh().get_faces(), mci.mesh, mci.mesh.surface_get_material(0))	
	request_redraw()
	pass	
	
func _remove_selected_faces():
	var mci = _gizmo.get_spatial_node()
	for face in get_selected_faces():
		mci.get_mc_mesh().remove_face(face.get_mesh_index())
	meshTools.CreateMeshFromFaces(mci.get_mc_mesh().get_faces(), mci.mesh, mci.mesh.surface_get_material(0))	
	request_redraw()

func inset_selected_faces(factor = 0.25):
	var mci = _gizmo.get_spatial_node()
	for face in get_selected_faces():
		mci.get_mc_mesh().inset_face(face.get_mesh_index(), factor)		
	meshTools.CreateMeshFromFaces(mci.get_mc_mesh().get_faces(), mci.mesh, mci.mesh.surface_get_material(0))	
	request_redraw()
	pass
	
func loopcut_selected_faces(edgeIndex = 0, insetFactor = 0.5):
	var mci = _gizmo.get_spatial_node()
	for face in get_selected_faces():
		var lpc = mci.get_mc_mesh().build_loopcut_chain(face.get_mesh_index(), edgeIndex)
		mci.get_mc_mesh().loopcut(lpc, edgeIndex, insetFactor)
	meshTools.CreateMeshFromFaces(mci.get_mc_mesh().get_faces(), mci.mesh, mci.mesh.surface_get_material(0))	
	request_redraw()
	
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
	spatialEditorRadialMenu.add_action("TOOL_TRANSLATE", "Translate")
	spatialEditorRadialMenu.add_action("TOOL_SCALE", "Scale")
	spatialEditorRadialMenu.add_action("TOOL_INSET", "Inset")
	spatialEditorRadialMenu.add_action("TOOL_LOOPCUT", "Loopcut")
	spatialEditorRadialMenu.add_action("TOOL_EXTRUDE", "Extrude")
	spatialEditorRadialMenu.show_menu()
		
func request_action(actionName, params = []):
	if (actionName == "TOOL_CANCEL"):
		print("Cancel operation")
		activate_tool(get_gizmo().get_editor_tool('FACE_SELECTION'))
	elif (actionName == "TOOL_SELECT"):
		print("Tool Select")
		activate_tool(get_gizmo().get_editor_tool('FACE_SELECTION'))
	elif (actionName == "TOOL_TRANSLATE"):
		print("Tool Move")
		activate_tool(get_gizmo().get_editor_tool('FACE_TRANSLATE'))
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
