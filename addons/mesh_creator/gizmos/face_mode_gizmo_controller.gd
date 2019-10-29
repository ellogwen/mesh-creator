class_name FaceModeGizmoController
var MeshCreatorInstance = preload("res://addons/mesh_creator/MeshCreatorInstance.gd")
var MeshTools = preload("res://addons/mesh_creator/MeshTools.gd")
var meshTools = MeshTools.new()

var MATERIALS = {
	FACE_UNSELECTED = null,
	FACE_SELECTED = null,
	FACE_SELECTED_LINE = null
}

var _gizmo

func _init(gizmo):
	_gizmo = gizmo	
	pass
	
func setup(plugin):
	_setup_materials(plugin)

func _setup_materials(plugin):
	var baseLineMat: SpatialMaterial = plugin.get_material("lines", self)
	MATERIALS.FACE_SELECTED_LINE = baseLineMat.duplicate()	
	pass
		
var _activeTool = null
func gizmo_redraw():
	print("redrawing")
	_gizmo.clear()	
	
	var mci = _gizmo.get_spatial_node()
	if (not mci is MeshCreatorInstance):
		return
		
	var lines = PoolVector3Array()	
	
	var lineMat: SpatialMaterial = _gizmo.get_plugin().get_material("face_select_line", self)
	lineMat.params_line_width = 10.0
	var matHandleVertex = _gizmo.get_plugin().get_material("handles_vertex", self)
	var matHandleVertexSelected = _gizmo.get_plugin().get_material("handles_vertex_selected", self)	
	
	
	var selectedFaces = mci.get_editor_state().get_selected_faces()
	if (not selectedFaces.empty() and _activeTool == null):
		var toolStart = Vector3.ZERO
		for face in selectedFaces:
			toolStart += face.get_centroid()
		_activeTool = TranslateTool.new()		
		_activeTool.startPosition = toolStart
		_activeTool.currentPosition = toolStart
		_activeTool.forward = -Vector3.FORWARD
		_activeTool.up = -Vector3.UP
		_activeTool.right = Vector3.RIGHT
		
	if _activeTool != null:
		_gizmo.add_handles(PoolVector3Array([_activeTool.getDrawPosition(0)]), _gizmo.get_plugin().HandleRightMaterial, false, false)	
		_gizmo.add_handles(PoolVector3Array([_activeTool.getDrawPosition(1)]), _gizmo.get_plugin().HandleUpMaterial, false, false)	
		_gizmo.add_handles(PoolVector3Array([_activeTool.getDrawPosition(2)]), _gizmo.get_plugin().HandleForwardMaterial, false, false)	
	
	_gizmo.show_cursor_3d()
	
	if (lines.size() > 0):
	 	_gizmo.add_lines(lines, lineMat, false)		
		
	pass
	
func gizmo_get_handle_name(index):
	if (_activeTool != null):
		match(index):
			0: return "Translate Right/Left"
			1: return "Translate Up/Down"
			2: return "Translate Forward/Backward"	

func gizmo_get_handle_value(index):
	if (_activeTool != null):
		match(index):
			0: return _activeTool.currentPosition.x - _activeTool.startPosition.x
			1: return _activeTool.currentPosition.y - _activeTool.startPosition.y
			2: return _activeTool.currentPosition.z - _activeTool.startPosition.z

func gizmo_commit_handle(index, restore, cancel=false):	
	if (_activeTool != null):
		_activeTool.startPosition = _activeTool.currentPosition
		#_activeTool = null
		gizmo_redraw()
	pass
	

func gizmo_set_handle(index, camera, screen_point : Vector2):
	prints("set_handle index", index, screen_point)
	if (_activeTool == null):
		return
		
	var spatial = _gizmo.get_spatial_node()
	var spatialTrans = spatial.global_transform
		
	var sourcePos = camera.unproject_position(_activeTool.currentPosition)
	var handlePos = camera.unproject_position(_activeTool.getDrawPosition(index))
	
	var axisForwardDir = Vector2.ZERO
	var axisBackDir = Vector2.ZERO	
	var toAxis = Vector3.ZERO
	if (index == 0): 	
		axisForwardDir = camera.unproject_position(_activeTool.currentPosition - _activeTool.right).normalized()
		axisBackDir = camera.unproject_position(_activeTool.currentPosition + _activeTool.right).normalized()
		toAxis = _activeTool.right
	elif(index == 1):
		axisForwardDir = camera.unproject_position(_activeTool.currentPosition - _activeTool.up).normalized()
		axisBackDir = camera.unproject_position(_activeTool.currentPosition + _activeTool.up).normalized()
		toAxis = _activeTool.up
	elif(index == 2):
		axisForwardDir = camera.unproject_position(_activeTool.currentPosition - _activeTool.forward).normalized()
		axisBackDir = camera.unproject_position(_activeTool.currentPosition + _activeTool.forward).normalized()
		toAxis = _activeTool.forward
	else:
		return
	
	var dragDir = (screen_point - handlePos).normalized()
	
	var translateForward = true
	if (dragDir.dot(axisBackDir) > 0):
		translateForward = false
		
	var mag = (screen_point - handlePos).length()	
	
	if (mag <= 45): #@todo remove magic number
		return
		
	if (translateForward == true):			
		toAxis = -toAxis
		
	var newPos: Vector3 = _activeTool.currentPosition + (toAxis * 0.15)
	newPos = Vector3(stepify(newPos.x, 0.25), stepify(newPos.y, 0.25), stepify(newPos.z, 0.25))
	
	prints("drag magnitude", mag, "drag direction", dragDir, "use axis forward", translateForward, "use axis", toAxis, "oldPos", _activeTool.currentPosition, "newPos", newPos)
	
	if (_activeTool.currentPosition != newPos):
		_activeTool.currentPosition = newPos		
		_gizmo.set_cursor_3d(newPos)
		for face in spatial.get_editor_state().get_selected_faces():
			#var newFacePos = face.get_centroid() + (_activeTool.currentPosition - _activeTool.startPosition)
			#_move_face_to(face.Id, newFacePos)		
			_move_face_to(face.Id, newPos)
		meshTools.CreateMeshFromFaces(spatial.get_editor_state().get_faces(), spatial.mesh, spatial.mesh.surface_get_material(0))
		spatial.get_editor_state().notify_state_changed()
		gizmo_redraw()
	pass
	
func _move_face_to(faceId, newPos):
	var spatial = _gizmo.get_spatial_node()
	prints("moving face " + str(faceId), newPos)
	# get face
	var sourceFace = spatial.get_editor_state().get_face(faceId)
	if (sourceFace == null): 
		return
	# calc difference
	var from = sourceFace.get_centroid()
	var diff = newPos - from
	
	# for each face vertex , set new pos and find sharing 
	# vertices and move them to the new positions
	var newA = sourceFace.A + diff
	var newB = sourceFace.B + diff
	var newC = sourceFace.C + diff
	var newD = sourceFace.D + diff
	
	# prevent clashing ?
	var fTest = sourceFace.clone()
	fTest.set_points(newA, newB, newC, newD)
	var clash = false
	for face in spatial.get_editor_state().get_faces():
		if (face.Id != fTest.Id and face.Equals(fTest)):
			clash = true
			break
			
	if not clash:	
		# move them to the new position
		_move_connected_vertices(sourceFace.A, newA)	
		_move_connected_vertices(sourceFace.B, newB)	
		_move_connected_vertices(sourceFace.C, newC)	
		_move_connected_vertices(sourceFace.D, newD)
	pass
	
func _move_connected_vertices(fromPos, toPos):
	var spatial = _gizmo.get_spatial_node()
	var affectedFaces = spatial.GetFacesWithVertex(fromPos)
	for face in affectedFaces:
		var vIndices: PoolIntArray = face.GetVertexIndices(fromPos)
		for vIndex in vIndices:
			face.set_point(vIndex, toPos)			
	pass
	
	
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
	
# editor mouse click events
func gizmo_forward_mouse_button(event: InputEventMouseButton, camera):
	if (event.get_button_index() == BUTTON_LEFT and event.pressed):
		if (_activeTool != null):
			return false # dont handle while tool is active
		var mci = _gizmo.get_spatial_node()			
		var clickedFaces = _get_clicked_on_faces_sorted_by_cam_distance(event.get_position(), camera)
		if (clickedFaces.size() > 0):
			prints("clicked on face ", clickedFaces[0].face)
			mci.get_editor_state().add_face_id_to_selection(clickedFaces[0].face.Id)
			gizmo_redraw()
			return true # handled the click
	if (event.get_button_index() == BUTTON_RIGHT and event.pressed):
		var mci = _gizmo.get_spatial_node()
		# workaround
		if (mci.get_editor_state().has_selected_faces() or _activeTool != null):
			mci.get_editor_state().clear_face_selection()
			_activeTool = null
			return true
	return false	


# editor mouse click events
func gizmo_forward_mouse_move(event, camera):	
	return false
	
func _get_clicked_on_faces_sorted_by_cam_distance(clickPos, camera):
	var result = Array()
	var mci = _gizmo.get_spatial_node()
	for face in mci.get_editor_state().get_faces():
		if (_has_clicked_on_face(face, clickPos, camera)):
			var clickInfo = {
				face = face,
				distance_camera = (face.get_centroid() - camera.transform.origin).length()
			}
			result.push_back(clickInfo)
	# sort by distance ascending
	result.sort_custom(self, "_click_info_distance_sort")
	return result
	
func _click_info_distance_sort(a, b):
	return a.distance_camera < b.distance_camera
	
func _has_clicked_on_face(face, point, camera):
	var spatial = _gizmo.get_spatial_node()		
	var screenA = camera.unproject_position(spatial.transform.origin + face.A)
	var screenB = camera.unproject_position(spatial.transform.origin + face.B)
	var screenC = camera.unproject_position(spatial.transform.origin + face.C)
	var screenD = camera.unproject_position(spatial.transform.origin + face.D)

	var in1 = Geometry.point_is_inside_triangle(point, screenA, screenB, screenC)
	var in2 = Geometry.point_is_inside_triangle(point, screenA, screenC, screenD)
			
	if (in1 or in2):
		return true
	else:
		return false	
	
class TranslateTool:	
	var startPosition	
	var currentPosition
	var forward
	var up
	var right
	func getDrawPosition(index):
		match(index):
			0: return currentPosition + (right * 0.5)
			1: return currentPosition - (up * 0.5)
			2: return currentPosition + (forward * 0.5)