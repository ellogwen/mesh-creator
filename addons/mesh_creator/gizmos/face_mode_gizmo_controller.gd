class_name MeshCreator_Gizmos_FaceModeGizmoController

var MeshCreatorInstance = preload("res://addons/mesh_creator/MeshCreatorInstance.gd")
var meshTools = MeshCreator_MeshTools.new()

const MATERIALS = {
	FACE_UNSELECTED = null,
	FACE_SELECTED = null,
	FACE_SELECTED_LINE = null
}

var _activeTool: MeshCreator_Gizmos_BaseGizmoTool = null

var _gizmo
func get_gizmo(): return _gizmo

var _selectedFacesIds = Array()
func get_selected_faces_ids() -> Array:
	return _selectedFacesIds
	
var _selectedVerticesIds = Array()
func get_selected_vertices_ids() -> Array:
	return _selectedVerticesIds

func _init(gizmo):
	_gizmo = gizmo	
	pass
	
func setup(plugin):
	_setup_tools()
	_setup_materials(plugin)
	
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
	
func _setup_tools():
	get_gizmo().EDITOR_TOOLS['FACE_SELECTION'] = MeshCreator_Gizmos_FaceSelectionGizmoTool.new(self)
	get_gizmo().EDITOR_TOOLS['FACE_TRANSLATE'] = MeshCreator_Gizmos_FaceTranslateGizmoTool.new(self)
	pass

func _setup_materials(plugin):
	var baseLineMat: SpatialMaterial = plugin.get_material("lines", self)
	MATERIALS.FACE_SELECTED_LINE = baseLineMat.duplicate()	
	pass		

func activate_tool(what):
	if (what == _activeTool):
		return
	if (_activeTool != null):
		_activeTool.set_inactive()
	what.set_active()
	_activeTool = what
	gizmo_redraw()
	pass

func gizmo_redraw():
	print("redrawing")
	_gizmo.clear()	
	
	# make sure at least the selection tool is active
	if (_activeTool == null):
		activate_tool(get_gizmo().EDITOR_TOOLS['FACE_SELECTION'])
	
	var mci = _gizmo.get_spatial_node()
	if (not mci is MeshCreatorInstance):
		return
		
	# create lines
	var lines = PoolVector3Array()		
	var lineMat: SpatialMaterial = _gizmo.get_plugin().get_material("face_select_line", self)
	lineMat.params_line_width = 10.0
	if (lines.size() > 0):
	 	_gizmo.add_lines(lines, lineMat, false)		
	
	
	# create handles
	var matHandleVertex = _gizmo.get_plugin().get_material("handles_vertex", self)
	var matHandleVertexSelected = _gizmo.get_plugin().get_material("handles_vertex_selected", self)	
	
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










func _move_connected_vertices(fromPos, toPos):
	var spatial = _gizmo.get_spatial_node()
	var affectedFaces = spatial.GetFacesWithVertex(fromPos)
	for face in affectedFaces:
		var vIndices: PoolIntArray = face.GetVertexIndices(fromPos)
		for vIndex in vIndices:
			face.set_point(vIndex, toPos)			
	pass	

	
func _extrude_selected_faces():
	var mci = _gizmo.get_spatial_node()
	for face in mci.get_editor_state().get_selected_faces():
		var highestId = mci.get_editor_state().get_highest_face_id()
		var newAFace = face.clone(highestId + 1)
		var newBFace = face.clone(highestId + 2)
		var newCFace = face.clone(highestId + 3)
		var newDFace = face.clone(highestId + 4)
		
		var newAPos = face.A - (face.Normal * 0.25)
		var newBPos = face.B - (face.Normal * 0.25)
		var newCPos = face.C - (face.Normal * 0.25)
		var newDPos = face.D - (face.Normal * 0.25)
		
		face.set_points(newAPos, newBPos, newCPos, newDPos)
		
		newAFace.set_point(2, face.B)
		newAFace.set_point(3, face.A)
		newBFace.set_point(0, face.B)
		newBFace.set_point(3, face.C)
		newCFace.set_point(1, face.C)
		newCFace.set_point(0, face.D)
		newDFace.set_point(1, face.A)
		newDFace.set_point(2, face.D)
		
		mci.get_editor_state().add_face(newAFace)
		mci.get_editor_state().add_face(newBFace)
		mci.get_editor_state().add_face(newCFace)
		mci.get_editor_state().add_face(newDFace)
		pass
		
	meshTools.CreateMeshFromFaces(mci.get_editor_state().get_faces(), mci.mesh, mci.mesh.surface_get_material(0))
	mci.get_editor_state().recalculate_edges()
	mci.get_editor_state().notify_state_changed()
	gizmo_redraw()
	pass
	
func _inset_selected_faces():
	var mci = _gizmo.get_spatial_node()
	for face in mci.get_editor_state().get_selected_faces():
		var highestId = mci.get_editor_state().get_highest_face_id()
		var newAFace = face.clone(highestId + 1)
		var newBFace = face.clone(highestId + 2)
		var newCFace = face.clone(highestId + 3)
		var newDFace = face.clone(highestId + 4)
		
		var newAPos = face.A + ((face.get_centroid() - face.A) * 0.25)
		var newBPos = face.B + ((face.get_centroid() - face.B) * 0.25)
		var newCPos = face.C + ((face.get_centroid() - face.C) * 0.25)
		var newDPos = face.D + ((face.get_centroid() - face.D) * 0.25)
		
		face.set_points(newAPos, newBPos, newCPos, newDPos)
		
		newAFace.set_point(3, face.A)
		newAFace.set_point(2, face.B)
		newBFace.set_point(0, face.B)
		newBFace.set_point(3, face.C)
		newCFace.set_point(1, face.C)
		newCFace.set_point(0, face.D)
		newDFace.set_point(1, face.A)
		newDFace.set_point(2, face.D)
		
		mci.get_editor_state().add_face(newAFace)
		mci.get_editor_state().add_face(newBFace)
		mci.get_editor_state().add_face(newCFace)
		mci.get_editor_state().add_face(newDFace)
		pass
		
	meshTools.CreateMeshFromFaces(mci.get_editor_state().get_faces(), mci.mesh, mci.mesh.surface_get_material(0))
	mci.get_editor_state().recalculate_edges()
	mci.get_editor_state().notify_state_changed()
	gizmo_redraw()
	pass
		
func request_action(actionName, params):
	if (actionName == "TOOL_SELECT"):
		print("Tool Select")
		activate_tool(get_gizmo().EDITOR_TOOLS['FACE_SELECTION'])
	if (actionName == "TOOL_TRANSLATE"):
		print("Tool Move")
		activate_tool(get_gizmo().EDITOR_TOOLS['FACE_TRANSLATE'])
	if (actionName == "TOOL_INSET"):
		print("Action Inset")
		_inset_selected_faces()
	if (actionName == "TOOL_EXTRUDE"):
		print("Action Extrude")
		_extrude_selected_faces()			
	pass
	
func on_tool_request_finish():
	if (_activeTool != null):
		_activeTool.set_inactive()
	_activeTool = null
	pass
	
func request_redraw():
	# @todo very bad way to propagate this
	_gizmo.get_spatial_node().ActiveEditorPlugin.notify_state_changed()
	# @todo this may results into an endless loop!	
	gizmo_redraw()
	pass