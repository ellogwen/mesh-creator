extends MeshCreator_Gizmos_BaseGizmoTool
class_name MeshCreator_Gizmos_FaceScaleGizmoTool

var _fromHandleIndex = -1

var _axisVertical = -Vector3.UP
var _axisHorizontal = -Vector3.RIGHT
var _axisBoth = ((_axisVertical + _axisHorizontal) * 0.5).normalized()
var _myFace = null

var meshTools = MeshCreator_MeshTools.new()

func _init(_gizmoController).(_gizmoController):
	pass
	
# do preparation before tool switch
func set_active() -> void:
	_myFace = null
	var selectedFaces = _get_selected_faces()
	if not selectedFaces.empty():				
		_myFace = selectedFaces.front()
	pass
	
# cleanup on tool switch
func set_inactive() -> void:	
	pass	
	
func on_gizmo_add_handles(nextIndex: int) -> int:
	set_active()
	if _myFace == null: 
		return nextIndex
		
	var gizmo = _gizmoController.get_gizmo()
	var spatial = gizmo.get_spatial_node()
	var faceCenter = spatial.global_transform.xform(_myFace.get_centroid())
	
	gizmo.add_handles(PoolVector3Array([_get_handle_draw_position(faceCenter, 0)]), gizmo.get_plugin().HandleRightMaterial, false, false)	
	gizmo.add_handles(PoolVector3Array([_get_handle_draw_position(faceCenter, 1)]), gizmo.get_plugin().HandleUpMaterial, false, false)	
	gizmo.add_handles(PoolVector3Array([_get_handle_draw_position(faceCenter, 2)]), gizmo.get_plugin().HandleForwardMaterial, false, false)	
	_fromHandleIndex = nextIndex
	nextIndex += 3
	return nextIndex
	
func on_gizmo_set_handle(index, camera, screen_pos):
	if (index < _fromHandleIndex or index >= _fromHandleIndex + 3):
		return
		
	if (_myFace == null):
		return
		
	var handleIdx = index - _fromHandleIndex
	var spatial = _gizmoController.get_gizmo().get_spatial_node()
	var spatialTrans: Transform = spatial.global_transform
	var faceCenter = spatialTrans.xform(_myFace.get_centroid())
	
	var sourcePosScreen = camera.unproject_position(faceCenter)
	var handlePosScreen = camera.unproject_position(_get_handle_draw_position(faceCenter, handleIdx))
	
	var axisForwardDir = Vector2.ZERO
	var axisBackDir = Vector2.ZERO	
	var toAxis = Vector3.ZERO
	if (handleIdx == 0): 	
		axisForwardDir = camera.unproject_position(faceCenter - _axisHorizontal).normalized()
		axisBackDir = camera.unproject_position(faceCenter + _axisHorizontal).normalized()
		toAxis = _axisHorizontal
	elif(handleIdx == 1):
		axisForwardDir = camera.unproject_position(faceCenter - _axisVertical).normalized()
		axisBackDir = camera.unproject_position(faceCenter + _axisVertical).normalized()
		toAxis = _axisVertical
	elif(handleIdx == 2):
		axisForwardDir = camera.unproject_position(faceCenter - _axisBoth).normalized()
		axisBackDir = camera.unproject_position(faceCenter + _axisBoth).normalized()
		toAxis = _axisBoth
	else:
		return
	
	var dragDir = (screen_pos - handlePosScreen).normalized()	
	
	var scaleUp = true
	if (dragDir.dot(axisBackDir) > 0):
		scaleUp = false
		
	var mag = (screen_pos - handlePosScreen).length()	
	
	if (mag <= 120): #@todo remove magic number
		return	
	
	if (handleIdx == 2):
		for vtx in _myFace.get_vertices():
			var step = (vtx.get_position() - faceCenter).normalized() * 0.15
			step = Vector3(stepify(step.x, 0.1), stepify(step.y, 0.1), stepify(step.z, 0.1))	
			if (scaleUp):		
				spatial.get_mc_mesh().translate_vertex(vtx.get_mesh_index(), step)
			else:
				spatial.get_mc_mesh().translate_vertex(vtx.get_mesh_index(), -step)
	else:
		var step = (toAxis * 0.15)
		step = Vector3(stepify(step.x, 0.1), stepify(step.y, 0.1), stepify(step.z, 0.1))
		if scaleUp == false:
			step = -step
		var p = Plane((toAxis - faceCenter).normalized(), 0)		
		for vtx in _myFace.get_vertices():
			if (p.is_point_over(spatialTrans.xform(vtx.get_position()))):
				spatial.get_mc_mesh().translate_vertex(vtx.get_mesh_index(), step)
			else:
				spatial.get_mc_mesh().translate_vertex(vtx.get_mesh_index(), -step)	

	meshTools.CreateMeshFromFaces(spatial.get_mc_mesh().get_faces(), spatial.mesh, spatial.mesh.surface_get_material(0))
	_gizmoController.request_redraw()
	
func on_gizmo_get_handle_name(index):
	if (index >= _fromHandleIndex and index < _fromHandleIndex + 3):
		match (index - _fromHandleIndex):
			0: return "Scale Horizontal"
			1: return "Scale Vertical"
			2: return "Scale Diagonal"
	return ""	
	
#func on_gizmo_get_handle_value(index):
#	if (index >= _fromHandleIndex and index < _fromHandleIndex + 3):
#		match (index - _fromHandleIndex):
#			0: return _currentPosition.x - _startPosition.x
#			1: return _currentPosition.y - _startPosition.y
#			2: return _currentPosition.z - _startPosition.z
#	return null

func _get_selected_faces():
	return _gizmoController.get_gizmo().get_spatial_node().get_mc_mesh().get_faces_selection(
		_gizmoController.get_gizmo().get_face_selection_store().get_store()
	)
	
func _get_handle_draw_position(faceCenter, handleIdx):	
	match(handleIdx):
		0: return faceCenter + (_axisHorizontal * 0.25)
		1: return faceCenter - (_axisVertical * 0.25)
		2: return faceCenter - (_axisBoth * 0.25)