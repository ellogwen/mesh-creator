extends MeshCreator_Gizmos_BaseGizmoTool
class_name MeshCreator_Gizmos_FaceTranslateGizmoTool

enum AxisModes { MESH, FACE, GLOBAL }
var AxisMode = AxisModes.MESH

var _startGlobalPosition = Vector3.ZERO
var _currentGlobalPosition = Vector3.ZERO
var _fromHandleIndex = -1

var _axisMeshRight = Vector3.RIGHT
var _axisMeshUp = Vector3.UP
var _axisMeshForward = Vector3.FORWARD

var _axisGlobalRight = Vector3.RIGHT
var _axisGlobalUp = Vector3.UP
var _axisGlobalForward = Vector3.FORWARD

var _axisFaceRight = Vector3.RIGHT
var _axisFaceUp = Vector3.UP
var _axisFaceForward = Vector3.FORWARD

var meshTools = MeshCreator_MeshTools.new()

func _init(_gizmoController).(_gizmoController):
	pass
	
func get_tool_name() -> String:
	return "FACE_TRANSLATE"	
	
func get_current_position() -> Vector3:
	return _currentGlobalPosition
	pass
	
func get_axis_right() -> Vector3:
	match AxisMode:
		AxisModes.MESH:
			return _axisMeshRight
		AxisModes.FACE:
			return _axisFaceRight
		_:
			return _axisGlobalRight
	pass
	
func get_axis_up() -> Vector3:
	match AxisMode:
		AxisModes.MESH:
			return _axisMeshUp
		AxisModes.FACE:
			return _axisFaceUp
		_:
			return _axisGlobalUp
	pass
	
func get_axis_forward() -> Vector3:
	match AxisMode:
		AxisModes.MESH:
			return _axisMeshForward
		AxisModes.FACE:
			return _axisFaceForward
		_:
			return _axisGlobalForward
	pass
	
# do preparation before tool switch
func set_active() -> void:	
	prints("set_active")
	var selectedFaces = _get_selected_faces()	
	_startGlobalPosition = Vector3.ZERO
	_currentGlobalPosition = Vector3.ZERO	
	var spatial: Spatial = _gizmoController.get_gizmo().get_spatial_node()
	var lastFace = selectedFaces.back()
	if spatial != null and lastFace != null:		
		_startGlobalPosition = spatial.to_global(lastFace.get_centroid())
		_currentGlobalPosition = _startGlobalPosition
		var cursor3d = _gizmoController.get_gizmo().get_cursor_3d()
		if cursor3d.is_connected("transform_changed", self, "_on_cursor_3d_transform_changed"):
			cursor3d.disconnect("transform_changed", self, "_on_cursor_3d_transform_changed")
		cursor3d.connect("transform_changed", self, "_on_cursor_3d_transform_changed")
		if (not Input.is_mouse_button_pressed(BUTTON_LEFT)):
			_gizmoController.get_gizmo().set_cursor_3d(_currentGlobalPosition)
		_gizmoController.get_gizmo().show_cursor_3d()
		#_gizmoController.get_gizmo().focus_cursor_3d()
	_calculate_axes()
	_update_axis_indicators()
	_create_face_translate_gizmo()
	pass
	
# cleanup on tool switch
func set_inactive() -> void:
	var cursor3d = _gizmoController.get_gizmo().get_cursor_3d()
	_gizmoController.get_gizmo().set_cursor_3d(_currentGlobalPosition)
	_startGlobalPosition = Vector3.ZERO
	_currentGlobalPosition = Vector3.ZERO	
	MeshCreator_Indicator.remove_line("face_translate_axis_x")
	MeshCreator_Indicator.remove_line("face_translate_axis_y")
	MeshCreator_Indicator.remove_line("face_translate_axis_z")		
	if (cursor3d != null):
		cursor3d.disconnect("transform_changed", self, "_on_cursor_3d_transform_changed")
	_gizmoController.get_gizmo().hide_cursor_3d()
	_remove_face_translate_gizmo()
	pass	

func _calculate_axes():
	var spatial: Spatial = _gizmoController.get_gizmo().get_spatial_node()

	# mesh	
	if (spatial != null):		
		_axisMeshRight = spatial.transform.basis.x
		_axisMeshUp = spatial.transform.basis.y
		_axisMeshForward = spatial.transform.basis.z	

	# face
	# @TODO
	_axisFaceRight = Vector3.RIGHT
	_axisFaceUp = Vector3.UP
	_axisFaceForward = Vector3.FORWARD
	
	# global
	_axisGlobalRight = Vector3.RIGHT
	_axisGlobalUp = Vector3.UP
	_axisGlobalForward = Vector3.FORWARD

	
func on_gizmo_add_handles(nextIndex: int) -> int:
	set_active()
	var selectedFaces = _get_selected_faces()
	var gizmo = _gizmoController.get_gizmo()
	var spatial = _gizmoController.get_gizmo().get_spatial_node()
	if not selectedFaces.empty():	
		#gizmo.add_handles(PoolVector3Array([_get_handle_draw_position_local(0)]), gizmo.get_plugin().HandleRightMaterial, false, false)	
		#gizmo.add_handles(PoolVector3Array([_get_handle_draw_position_local(1)]), gizmo.get_plugin().HandleUpMaterial, false, false)	
		#gizmo.add_handles(PoolVector3Array([_get_handle_draw_position_local(2)]), gizmo.get_plugin().HandleForwardMaterial, false, false)	
		_fromHandleIndex = nextIndex
		nextIndex += 3
	return nextIndex
	
func on_gizmo_set_handle(index, camera: Camera, screen_pos):
	if (index < _fromHandleIndex or index >= _fromHandleIndex + 3):
		return
		
	return
		
	var handleIdx = index - _fromHandleIndex
	var spatial = _gizmoController.get_gizmo().get_spatial_node()
	var camNormal = camera.project_ray_normal(screen_pos)	
	var currPosGlobal = _currentGlobalPosition #spatial.to_global(_currentGlobalPosition)
	var newAxisPos = currPosGlobal
	var toAxis = Vector3.ZERO
	
	# right/left
	if (handleIdx == 0):	
		toAxis = get_axis_right()
		var hpos = currPosGlobal + _get_handle_draw_position(0)
		var p = Plane(get_axis_up(), hpos.y)
		var intersection = p.intersects_ray(camera.project_ray_origin(screen_pos), camera.project_ray_normal(screen_pos))
		if intersection != null:	
			newAxisPos = (intersection - currPosGlobal).project(toAxis) + currPosGlobal			
		
	
	elif (handleIdx == 1):	
		toAxis = get_axis_up()
		var hpos = _get_handle_draw_position(1)
		var p = Plane(get_axis_forward(), hpos.z)
		var intersection = p.intersects_ray(camera.project_ray_origin(screen_pos), camera.project_ray_normal(screen_pos))
		if intersection != null:						
			newAxisPos = (intersection - currPosGlobal).project(toAxis) + currPosGlobal			
			
	
	elif (handleIdx == 2):		
		toAxis = get_axis_forward()		
		var hpos = _get_handle_draw_position(2)
		var p = Plane(get_axis_up(), hpos.y)
		var intersection = p.intersects_ray(camera.project_ray_origin(screen_pos), camera.project_ray_normal(screen_pos))
		if intersection != null:			
			newAxisPos = (intersection - currPosGlobal).project(toAxis) + currPosGlobal	
							
	
	var offsetGlobal = (newAxisPos - currPosGlobal)
	var travelDistance = (newAxisPos - currPosGlobal).length()
	if ((travelDistance > 0.1 or travelDistance < -0.1) and abs(travelDistance) < 10):	
		var undo_redo = MeshCreator_Signals.get_editor_plugin().get_undo_redo()
		undo_redo.create_action("Translate Face")
		
		var newPosLocal = spatial.to_local(newAxisPos)		
		var newPos = Vector3(stepify(newPosLocal.x, 0.05), stepify(newPosLocal.y, 0.05), stepify(newPosLocal.z, 0.05))	
		
		var offset = newPos - spatial.to_local(_currentGlobalPosition)
		for face in _get_selected_faces():			
			for i in range(face.get_vertices().size()):
				#spatial.get_mc_mesh().translate_vertex(face.get_vertex(i).get_mesh_index(), offset)
				undo_redo.add_do_method(spatial.get_mc_mesh(), "translate_vertex", face.get_vertex(i).get_mesh_index(), offset)
				undo_redo.add_undo_method(spatial.get_mc_mesh(), "translate_vertex", face.get_vertex(i).get_mesh_index(), -offset)
		
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
			0: return _currentGlobalPosition.x - _startGlobalPosition.x
			1: return _currentGlobalPosition.y - _startGlobalPosition.y
			2: return _currentGlobalPosition.z - _startGlobalPosition.z
	return null
	
# return true if event claimed handled		
func on_input_key(event: InputEventKey, camera):
	#if event.scancode == KEY_SHIFT and event.pressed:		
		#print("TRANSLATE: using face axis")
	#if event.scancode == KEY_SHIFT and not event.pressed:
		#print("TRANSLATE: using mesh axis")
	if event.scancode == KEY_ALT and event.pressed and not event.echo:
		AxisMode = AxisModes.GLOBAL
	if event.scancode == KEY_ALT and not event.pressed:
		AxisMode = AxisModes.MESH
	return false	

func _get_selected_faces():
	return _gizmoController.get_gizmo().get_spatial_node().get_mc_mesh().get_faces_selection(
		_gizmoController.get_gizmo().get_face_selection_store().get_store()
	)
	
func _get_handle_draw_position(handleIdx):	
	var right = get_axis_right()
	var up = get_axis_up()
	var fwd = get_axis_forward()
	
	# flip to always face outside the selected face	
	var selectedFaces = _get_selected_faces()	
	if (not selectedFaces.empty()):
		var targetFace = selectedFaces.back()
		if (targetFace.get_normal().dot(right) > 0):
			right = -right		
		if (targetFace.get_normal().dot(up) > 0):
			up = -up
		if (targetFace.get_normal().dot(fwd) > 0):				
			fwd = -fwd

	match(handleIdx):
		0: return _currentGlobalPosition + (right * 0.25)
		1: return _currentGlobalPosition + (up * 0.25)
		2: return _currentGlobalPosition + (fwd * 0.25)

func _get_handle_draw_position_local(handleIdx):
	var spatial = _gizmoController.get_gizmo().get_spatial_node()
	return spatial.to_local(_get_handle_draw_position(handleIdx))
	pass

func _update_axis_indicators():
	MeshCreator_Indicator.add_line_global("face_translate_axis_x", _currentGlobalPosition, _currentGlobalPosition + get_axis_right() * 10, Color.red)	
	MeshCreator_Indicator.add_line_global("face_translate_axis_y", _currentGlobalPosition, _currentGlobalPosition + get_axis_up() * 10, Color.green)	
	MeshCreator_Indicator.add_line_global("face_translate_axis_z", _currentGlobalPosition, _currentGlobalPosition + get_axis_forward() * 10, Color.blue)	



var FaceTranslateGizmo = preload("res://addons/mesh_creator/gizmos/handles/face_translate_gizmo.tscn")
var _faceTranslateGizmo = null
func _create_face_translate_gizmo():
	# create and setup new gizmo
	if (_faceTranslateGizmo == null):
		var spatial = _gizmoController.get_gizmo().get_spatial_node()
		_faceTranslateGizmo = FaceTranslateGizmo.instance()
		_faceTranslateGizmo.name = "Face_Translate_Gizmo"	
		spatial.get_node("MC_Editor").add_child(_faceTranslateGizmo)
		_faceTranslateGizmo.set_owner(spatial.get_owner())		
	_update_face_translate_gizmo()
	pass

func _update_face_translate_gizmo():
	if (_faceTranslateGizmo == null):
		return	
	_faceTranslateGizmo.global_transform.origin = get_current_position()
	var selectedFaces = _get_selected_faces()	
	if (not selectedFaces.empty()):
		var targetFace = selectedFaces.back()
		_faceTranslateGizmo.global_transform.origin += (-targetFace.get_normal() * 0.1)
		_faceTranslateGizmo.look_at(_faceTranslateGizmo.global_transform.origin + -targetFace.get_normal(), get_axis_up())
	pass

func _remove_face_translate_gizmo():
	if _faceTranslateGizmo != null:		
		var spatial = _gizmoController.get_gizmo().get_spatial_node()
		spatial.get_node("MC_Editor").remove_child(_faceTranslateGizmo)
		_faceTranslateGizmo.queue_free()
	_faceTranslateGizmo = null
	pass

func _on_cursor_3d_transform_changed():
	prints("set new transform", _gizmoController.get_gizmo().get_cursor_3d().global_transform.origin)
	var newPosGlobal = _gizmoController.get_gizmo().get_cursor_3d().global_transform.origin	
	var offsetGlobal = (newPosGlobal - _currentGlobalPosition)
	var spatial = _gizmoController.get_gizmo().get_spatial_node()
	var travelDistance = (newPosGlobal - _currentGlobalPosition).length()
	if ((travelDistance > 0.1 or travelDistance < -0.1) and abs(travelDistance) < 10):
		# disconnect, to prevent editor to not fire event again before we commit
		_gizmoController.get_gizmo().get_cursor_3d().disconnect("transform_changed", self, "_on_cursor_3d_transform_changed")
		
		var undo_redo = MeshCreator_Signals.get_editor_plugin().get_undo_redo()
		prints("Current Undo Stack:", undo_redo.get_current_action_name())
		undo_redo.create_action("Translate Face")
		
		#var newPosLocal = spatial.to_local(newPosGlobal)
		#var newPos = Vector3(stepify(newPosLocal.x, 0.05), stepify(newPosLocal.y, 0.05), stepify(newPosLocal.z, 0.05))	
		#var newPos = Vector3(stepify(newPosGlobal.x, 0.05), stepify(newPosGlobal.y, 0.05), stepify(newPosGlobal.z, 0.05))	
		var newPos = newPosGlobal
		#var offset = newPos - spatial.to_local(_currentGlobalPosition)
		var offset = newPos - _startGlobalPosition
		for face in _get_selected_faces():			
			for i in range(face.get_vertices().size()):
				#spatial.get_mc_mesh().translate_vertex(face.get_vertex(i).get_mesh_index(), offset)
				undo_redo.add_do_method(spatial.get_mc_mesh(), "translate_vertex", face.get_vertex(i).get_mesh_index(), offset)
				undo_redo.add_undo_method(spatial.get_mc_mesh(), "translate_vertex", face.get_vertex(i).get_mesh_index(), -offset)
		
		#meshTools.SetMeshFromMeshCreatorMesh(spatial.get_mc_mesh(), spatial)
		undo_redo.add_do_method(meshTools, "SetMeshFromMeshCreatorMesh", spatial.get_mc_mesh(), spatial)
		undo_redo.add_undo_method(meshTools, "SetMeshFromMeshCreatorMesh", spatial.get_mc_mesh(), spatial)
		
		# reset cursor, force editor to update this way
		prints("from", _currentGlobalPosition, "to", newPosGlobal, "offset", offsetGlobal)
		#undo_redo.add_do_method(_gizmoController.get_gizmo(), "set_cursor_3d", newPosGlobal)
		
		#_gizmoController.request_redraw()
		undo_redo.add_do_method(_gizmoController, "request_redraw")
		undo_redo.add_undo_method(_gizmoController, "request_redraw")	
		
		_currentGlobalPosition = newPosGlobal

		undo_redo.commit_action()
		
	
	
	pass
