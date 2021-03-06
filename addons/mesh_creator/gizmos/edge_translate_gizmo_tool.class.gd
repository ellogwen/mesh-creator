extends MeshCreator_Gizmos_BaseGizmoTool
class_name MeshCreator_Gizmos_EdgeTranslateGizmoTool

var _startPosition = Vector3.ZERO
var _currentPosition = Vector3.ZERO
var _fromHandleIndex = -1

var _axisRight = Vector3.RIGHT
var _axisUp = Vector3.UP
var _axisForward = Vector3.FORWARD

var _useFaceLocalAxis = false

var meshTools = MeshCreator_MeshTools.new()

func _init(_gizmoController).(_gizmoController):
	pass
	
func get_tool_name() -> String:
	return "EDGE_TRANSLATE"	
	
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
	var selectedEdges = _get_selected_edges()	
	_startPosition = Vector3.ZERO
	_currentPosition = Vector3.ZERO	
	var spatial: Spatial = _gizmoController.get_gizmo().get_spatial_node()
	var lastEdge = selectedEdges.back()
	if spatial != null and lastEdge != null:		
		_startPosition = lastEdge.get_center()
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
		var selectedEdges = _get_selected_edges()		
	pass
	
func use_axis_from_face():			
	pass
	
func on_gizmo_add_handles(nextIndex: int) -> int:
	set_active()
	var selectedEdges = _get_selected_edges()
	var gizmo = _gizmoController.get_gizmo()
	if not selectedEdges.empty():	
		gizmo.add_handles(PoolVector3Array([_get_handle_draw_position(0)]), gizmo.get_plugin().HandleRightMaterial, false, false)	
		gizmo.add_handles(PoolVector3Array([_get_handle_draw_position(1)]), gizmo.get_plugin().HandleUpMaterial, false, false)	
		gizmo.add_handles(PoolVector3Array([_get_handle_draw_position(2)]), gizmo.get_plugin().HandleForwardMaterial, false, false)	
		_fromHandleIndex = nextIndex
		nextIndex += 3
	return nextIndex
	
func on_gizmo_set_handle(index, camera: Camera, screen_pos):
	if (index < _fromHandleIndex or index >= _fromHandleIndex + 3):
		return
		
	var handleIdx = index - _fromHandleIndex
	var spatial = _gizmoController.get_gizmo().get_spatial_node()	
	var camNormal = camera.project_ray_normal(screen_pos)	
	var currPosGlobal = spatial.to_global(_currentPosition)
	var newAxisPos = currPosGlobal
	var toAxis = Vector3.ZERO
	
	# right/left
	if (handleIdx == 0):	
		toAxis = _axisRight	
		var hpos = currPosGlobal + _get_handle_draw_position(0)
		var p = Plane(_axisUp, hpos.y)
		var intersection = p.intersects_ray(camera.project_ray_origin(screen_pos), camera.project_ray_normal(screen_pos))
		if intersection != null:	
			newAxisPos = (intersection - currPosGlobal).project(toAxis) + currPosGlobal			
		
	
	elif (handleIdx == 1):	
		toAxis = _axisUp
		var hpos = _get_handle_draw_position(1)
		var p = Plane(_axisForward, hpos.z)
		var intersection = p.intersects_ray(camera.project_ray_origin(screen_pos), camera.project_ray_normal(screen_pos))
		if intersection != null:						
			newAxisPos = (intersection - currPosGlobal).project(toAxis) + currPosGlobal			
			
	
	elif (handleIdx == 2):		
		toAxis = _axisForward		
		var hpos = _get_handle_draw_position(2)
		var p = Plane(_axisUp, hpos.y)
		var intersection = p.intersects_ray(camera.project_ray_origin(screen_pos), camera.project_ray_normal(screen_pos))
		if intersection != null:			
			newAxisPos = (intersection - currPosGlobal).project(toAxis) + currPosGlobal	
							
	
	var offsetGlobal = (newAxisPos - currPosGlobal)
	var travelDistance = (newAxisPos - currPosGlobal).length()
	if ((travelDistance > 0.1 or travelDistance < -0.1) and abs(travelDistance) < 10):
		var undo_redo = MeshCreator_Signals.get_editor_plugin().get_undo_redo()
		undo_redo.create_action("Translate Edge")

		var newPosLocal = spatial.to_local(newAxisPos)		
		var newPos = Vector3(stepify(newPosLocal.x, 0.05), stepify(newPosLocal.y, 0.05), stepify(newPosLocal.z, 0.05))	
		
		var offset = newPos - _currentPosition		
		for edge in _get_selected_edges():						
			#spatial.get_mc_mesh().translate_vertex(edge.get_a().get_mesh_index(), offset)		
			#spatial.get_mc_mesh().translate_vertex(edge.get_b().get_mesh_index(), offset)				
			undo_redo.add_do_method(spatial.get_mc_mesh(), "translate_vertex",edge.get_a().get_mesh_index(), offset)
			undo_redo.add_do_method(spatial.get_mc_mesh(), "translate_vertex",edge.get_b().get_mesh_index(), offset)
			undo_redo.add_undo_method(spatial.get_mc_mesh(), "translate_vertex",edge.get_a().get_mesh_index(), -offset)
			undo_redo.add_undo_method(spatial.get_mc_mesh(), "translate_vertex",edge.get_b().get_mesh_index(), -offset)			
		
		#meshTools.SetMeshFromMeshCreatorMesh(spatial.get_mc_mesh(), spatial)
		undo_redo.add_do_method(meshTools, "SetMeshFromMeshCreatorMesh", spatial.get_mc_mesh(), spatial)
		undo_redo.add_undo_method(meshTools, "SetMeshFromMeshCreatorMesh", spatial.get_mc_mesh(), spatial)
		#_gizmoController.request_redraw()
		undo_redo.add_do_method(_gizmoController, "request_redraw")
		undo_redo.add_undo_method(_gizmoController, "request_redraw")
		undo_redo.commit_action()
	
	pass
		
	
	
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
	
# return true if event claimed handled		
func on_input_key(event: InputEventKey, camera):
	#if event.scancode == KEY_SHIFT and event.pressed:		
		#print("TRANSLATE: using face axis")
	#if event.scancode == KEY_SHIFT and not event.pressed:
		#print("TRANSLATE: using mesh axis")
	return false	

func _get_selected_edges():
	return _gizmoController.get_gizmo().get_spatial_node().get_mc_mesh().get_edges_selection(
		_gizmoController.get_gizmo().get_edge_selection_store().get_store()
	)
	
func _get_handle_draw_position(handleIdx):
	match(handleIdx):
		0: return _currentPosition + (_axisRight * 0.25)
		1: return _currentPosition + (_axisUp * 0.25)
		2: return _currentPosition + (_axisForward * 0.25)
