extends MeshCreator_Gizmos_BaseGizmoTool
class_name MeshCreator_Gizmos_FaceTranslateGizmoTool

var _startPosition = Vector3.ZERO
var _currentPosition = Vector3.ZERO
var _fromHandleIndex = -1

var _axisRight = Vector3.RIGHT
var _axisUp = Vector3.UP
var _axisForward = Vector3.FORWARD

var meshTools = MeshCreator_MeshTools.new()

func _init(_gizmoController).(_gizmoController):
	pass
	
func get_tool_name() -> String:
	return "FACE_TRANSLATE"	
	
func get_current_position() -> Vector3:
	return _currentPosition
	pass
	
func get_axis_right() -> Vector3:
	return _axisRight
	pass
	
func get_axis_up() -> Vector3:
	return _axisUp
	pass
	
func get_axis_forward() -> Vector3:
	return _axisForward
	pass
	
# do preparation before tool switch
func set_active() -> void:	
	var selectedFaces = _get_selected_faces()
	# is this right?
	_startPosition = Vector3.ZERO
	_currentPosition = Vector3.ZERO
	#for face in selectedFaces:
	#	_startPosition += face.get_centroid()
	#	_currentPosition += face.get_centroid()
	var spatial: Spatial = _gizmoController.get_gizmo().get_spatial_node()
	var lastFace = selectedFaces.back()
	if spatial != null and lastFace != null:		
		_startPosition = lastFace.get_centroid()
		_currentPosition = _startPosition
	use_axis_from_mesh()				
	pass
	
# cleanup on tool switch
func set_inactive() -> void:
	_startPosition = Vector3.ZERO
	_currentPosition = Vector3.ZERO	
	pass	
	
func use_axis_from_global():
	_axisRight = Vector3.RIGHT
	_axisUp = Vector3.UP
	_axisForward = Vector3.FORWARD
	
func use_axis_from_mesh():
	var spatial: Spatial = _gizmoController.get_gizmo().get_spatial_node()
	if (spatial != null):		
		_axisRight = spatial.transform.basis.x
		_axisUp = spatial.transform.basis.y
		_axisForward = spatial.transform.basis.z
		var selectedFaces = _get_selected_faces()
		# flip to always face outside
		if (not selectedFaces.empty()):
			var targetFace = selectedFaces.back()			
			if (targetFace.get_normal().dot(_axisRight) > 0):
				_axisRight = -_axisRight		
			if (targetFace.get_normal().dot(_axisUp) > 0):
				_axisUp = -_axisUp
			if (targetFace.get_normal().dot(_axisForward) > 0):				
				_axisForward = -_axisForward
	pass
	
func use_axis_from_face():
	pass
	
func on_gizmo_add_handles(nextIndex: int) -> int:
	set_active()
	var selectedFaces = _get_selected_faces()
	var gizmo = _gizmoController.get_gizmo()
	if not selectedFaces.empty():	
		gizmo.add_handles(PoolVector3Array([_get_handle_draw_position(0)]), gizmo.get_plugin().HandleRightMaterial, false, false)	
		gizmo.add_handles(PoolVector3Array([_get_handle_draw_position(1)]), gizmo.get_plugin().HandleUpMaterial, false, false)	
		gizmo.add_handles(PoolVector3Array([_get_handle_draw_position(2)]), gizmo.get_plugin().HandleForwardMaterial, false, false)	
		_fromHandleIndex = nextIndex
		nextIndex += 3
	return nextIndex
	
func on_gizmo_set_handle(index, camera, screen_pos):
	if (index < _fromHandleIndex or index >= _fromHandleIndex + 3):
		return
	var handleIdx = index - _fromHandleIndex
	var spatial = _gizmoController.get_gizmo().get_spatial_node()	
		
	var sourcePos = camera.unproject_position(_currentPosition)
	var handlePos = camera.unproject_position(_get_handle_draw_position(handleIdx))
	
	var axisForwardDir = Vector2.ZERO
	var axisBackDir = Vector2.ZERO	
	var toAxis = Vector3.ZERO
	if (handleIdx == 0): 	
		axisForwardDir = camera.unproject_position(_currentPosition - _axisRight).normalized()
		axisBackDir = camera.unproject_position(_currentPosition + _axisRight).normalized()
		toAxis = _axisRight
	elif(handleIdx == 1):
		axisForwardDir = camera.unproject_position(_currentPosition - _axisUp).normalized()
		axisBackDir = camera.unproject_position(_currentPosition + _axisUp).normalized()
		toAxis = _axisUp
	elif(handleIdx == 2):
		axisForwardDir = camera.unproject_position(_currentPosition - _axisForward).normalized()
		axisBackDir = camera.unproject_position(_currentPosition + _axisForward).normalized()
		toAxis = _axisForward
	else:
		return
	
	var dragDir = (screen_pos - handlePos).normalized()
	
	var translateForward = true
	if (dragDir.dot(axisBackDir) > 0):
		translateForward = false
		
	var mag = (screen_pos - handlePos).length()	
	
	if (mag <= 45): #@todo remove magic number
		return
		
	if (translateForward == true):			
		toAxis = -toAxis
		
	var newPos: Vector3 = _currentPosition + (toAxis * 0.05)
	newPos = Vector3(stepify(newPos.x, 0.05), stepify(newPos.y, 0.05), stepify(newPos.z, 0.05))
	
	# prints("drag magnitude", mag, "drag direction", dragDir, "use axis forward", translateForward, "use axis", toAxis, "oldPos", _currentPosition, "newPos", newPos)
	
	if (_currentPosition != newPos):
		_currentPosition = newPos		
		#_gizmoController.get_gizmo().set_cursor_3d(newPos)
		# @todo let this handle from someone else
		var offset = newPos - _startPosition		
		for face in _get_selected_faces():			
			for i in range(face.get_vertices().size()):
				spatial.get_mc_mesh().translate_vertex(face.get_vertex(i).get_mesh_index(), offset)	
		#	_move_face_to(face.get_mesh_index(), newPos)
		meshTools.CreateMeshFromFaces(spatial.get_mc_mesh().get_faces(), spatial.mesh, spatial.mesh.surface_get_material(0))
		#spatial.get_editor_state().recalculate_edges()
		#spatial.get_editor_state().notify_state_changed()
		#gizmo_redraw()	
		_gizmoController.request_redraw()
	
func on_gizmo_get_handle_name(index):
	if (index >= _fromHandleIndex and index < _fromHandleIndex + 3):
		match (index - _fromHandleIndex):
			0: return "Translate Left/Right"
			1: return "Translate Up/Down"
			2: return "Translate Forward/Backward"
	return ""	
	
func on_gizmo_get_handle_value(index):
	if (index >= _fromHandleIndex and index < _fromHandleIndex + 3):
		match (index - _fromHandleIndex):
			0: return _currentPosition.x - _startPosition.x
			1: return _currentPosition.y - _startPosition.y
			2: return _currentPosition.z - _startPosition.z
	return null

func _get_selected_faces():
	return _gizmoController.get_gizmo().get_spatial_node().get_mc_mesh().get_faces_selection(
		_gizmoController.get_gizmo().get_face_selection_store().get_store()
	)
	
func _get_handle_draw_position(handleIdx):
	match(handleIdx):
		0: return _currentPosition + (_axisRight * 0.25)
		1: return _currentPosition + (_axisUp * 0.25)
		2: return _currentPosition + (_axisForward * 0.25)