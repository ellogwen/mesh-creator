extends MeshCreator_Gizmos_BaseGizmoTool

# namespace MeshCreator_Gizmos
class_name MeshCreator_Gizmos_FaceSelectionGizmoTool

var _startGlobalPosition = Vector3.ZERO
var _currentGlobalPosition = Vector3.ZERO
var _startScale = Vector3.ONE
var _currentScale = Vector3.ONE
var _is_scaling = false
var meshTools = MeshCreator_MeshTools.new()

func get_selection_store():
	return _gizmoController.get_gizmo().get_face_selection_store()


#################
# base overrides
#################

func _init(gizmoController).(gizmoController) -> void:	
	pass
	
func get_tool_name() -> String:
	return "FACE_SELECTION"
	
# do preparation before tool switch
func set_active() -> void:
	pass
	
# cleanup on tool switch
func set_inactive() -> void:
	var cursor3d = get_cursor_3d()
	_gizmoController.get_gizmo().set_cursor_3d(_currentGlobalPosition)
	cursor3d.set_scale(Vector3.ONE)
	_startGlobalPosition = Vector3.ZERO
	_currentGlobalPosition = Vector3.ZERO
	_startScale = Vector3.ONE
	_currentScale = Vector3.ONE
	
	if (cursor3d != null):
		if cursor3d.is_connected("transform_changed", self, "_on_cursor_3d_transform_changed"):
			cursor3d.disconnect("transform_changed", self, "_on_cursor_3d_transform_changed")
	_gizmoController.get_gizmo().hide_cursor_3d()
	_gizmoController.get_gizmo().focus_mesh_instance()
	pass


# return true if event claimed handled
func on_input_mouse_button(event: InputEventMouseButton, camera) -> bool:
	if (event.get_button_index() == BUTTON_LEFT):
		
		#var cursor = _gizmoController.get_gizmo().get_cursor_3d()
		#cursor.get_gizmo().set_hidden(true)
		#prints("highlighted?",  cursor.get_gizmo().get_plugin().is_handle_highlighted(0))	
		
		if (not event.pressed):
			if (_is_scaling):
				_is_scaling = false
				_scale_cursor_to_face(_get_selected_faces().back())
					
		if (_gizmoController.get_gizmo().is_cursor_3d_selected()):
			#prints(Input.get_last_mouse_speed().length_squared())
			# hacky workaround
			#if (Input.get_last_mouse_speed().length_squared() < 10.0):
			return false
			#else:
			#	return true
	
	if (event.get_button_index() == BUTTON_RIGHT):
		var mci = _gizmoController.get_gizmo().get_spatial_node()			
		var clickedFaces = _get_clicked_on_faces_sorted_by_cam_distance(event.get_position(), camera)
		if (clickedFaces.size() > 0):
			if (not event.pressed):
				prints("clicked on face ", clickedFaces[0].face)
				if get_selection_store().is_selected(clickedFaces[0].face.get_mesh_index()):
					get_selection_store().remove_from_selection(clickedFaces[0].face.get_mesh_index())
				else:
					# only support on face for now. @todo fix this later when cleaned up structure
					# and ngons are no problem anymore
					get_selection_store().clear()
					###########
					get_selection_store().add_to_selection(clickedFaces[0].face.get_mesh_index())
				_gizmoController.call_deferred("request_redraw")
			return true # handled the click

	#if (event.get_button_index() == BUTTON_RIGHT):
	#	if (not get_selection_store().is_empty()):
	#		get_selection_store().clear()
	#		_gizmoController.call_deferred("request_redraw")
	#		return true # click handled
			
	# always handle when editing, to prevent editor from deselecting
	if (event.get_button_index() == BUTTON_RIGHT or event.get_button_index() == BUTTON_LEFT):
		return true
	return false
	pass
	
# return true if event claimed handled	
func on_input_mouse_move(event, camera) -> bool:
	return false
	pass
	
# return true if event claimed handled		
func on_input_key(event, camera):
	return false
	pass	

func on_gui_action(actionCode: String, payload):
	pass	
	
func on_gizmo_redraw(gizmo):
	_update_translate_gizmo()
	pass
	
#################
# own stuff
#################	

func _get_clicked_on_faces_sorted_by_cam_distance(clickPos, camera: Camera):		
	var result = Array()
	var mci: Spatial = _gizmoController.get_gizmo().get_spatial_node()
	var camRayNormal = camera.project_ray_normal(clickPos)	
	
	for face in mci.get_mc_mesh().get_faces():
		var normalDot = camRayNormal.dot(face.get_normal())
		for tri in face.get_triangles():
			if (normalDot >= 0): # only respect faces that are visible for the cam
				var intersection = Geometry.ray_intersects_triangle(camera.transform.origin, camRayNormal, mci.global_transform.xform(tri.get_a()), mci.global_transform.xform(tri.get_b()), mci.global_transform.xform(tri.get_c()))
				if (intersection != null):
					var clickInfo = {
						face = face,
						distance_camera = (mci.global_transform.xform(face.get_centroid()) - camera.transform.origin).length()
					}
					result.push_back(clickInfo)
					
	result.sort_custom(self, "_sort_by_distance_camera_asc")
	return result

func _sort_by_distance_camera_asc(a, b):
	return a.distance_camera < b.distance_camera
	

func _on_cursor_3d_transform_changed():
	var cursor3d = _gizmoController.get_gizmo().get_cursor_3d()
	var newPosGlobal = _gizmoController.get_gizmo().get_cursor_3d().global_transform.origin	
	var offsetGlobal = (newPosGlobal - _currentGlobalPosition)
	var offsetScale =  Vector3(
		max(0.0, cursor3d.get_scale().x) - max(0.0, _currentScale.x),
		max(0.0, cursor3d.get_scale().y) - max(0.0, _currentScale.y),
		max(0.0, cursor3d.get_scale().z) - max(0.0, _currentScale.z)
	)
	var spatial = _gizmoController.get_gizmo().get_spatial_node()
	var travelDistance = (newPosGlobal - _currentGlobalPosition).length()
	
	prints("set new transform", cursor3d.global_transform.origin, cursor3d.scale)
		
	# check translate
	if ((travelDistance > 0.1 or travelDistance < -0.1) and abs(travelDistance) < 10):
		# disconnect, to prevent editor to not fire event again before we commit
		if (cursor3d.is_connected("transform_changed", self, "_on_cursor_3d_transform_changed")):
			cursor3d.disconnect("transform_changed", self, "_on_cursor_3d_transform_changed")
				
		var undo_redo = MeshCreator_Signals.get_editor_plugin().get_undo_redo()
		undo_redo.create_action("Translate Face")
		
		#var newPosLocal = spatial.to_local(newPosGlobal)
		#var newPos = Vector3(stepify(newPosLocal.x, 0.05), stepify(newPosLocal.y, 0.05), stepify(newPosLocal.z, 0.05))	
		#var newPos = Vector3(stepify(newPosGlobal.x, 0.05), stepify(newPosGlobal.y, 0.05), stepify(newPosGlobal.z, 0.05))	
		var newPos = newPosGlobal
		#var offset = newPos - spatial.to_local(_currentGlobalPosition)
		var offset = newPos - _startGlobalPosition
		
		var trans_edges = PoolIntArray()
		for face in _get_selected_faces():
			for edgeId in (face as MeshCreator_Mesh_Face).get_edges():
				trans_edges.push_back(edgeId)
		
		undo_redo.add_do_method(spatial.get_mc_mesh(), "translate_edges", trans_edges, offset)
		undo_redo.add_undo_method(spatial.get_mc_mesh(), "translate_edges", trans_edges, -offset)
		
		#meshTools.SetMeshFromMeshCreatorMesh(spatial.get_mc_mesh(), spatial)
		undo_redo.add_do_method(meshTools, "SetMeshFromMeshCreatorMesh", spatial.get_mc_mesh(), spatial)
		undo_redo.add_undo_method(meshTools, "SetMeshFromMeshCreatorMesh", spatial.get_mc_mesh(), spatial)
		
		# reset cursor, force editor to update this way
		# prints("from", _currentGlobalPosition, "to", newPosGlobal, "offset", offsetGlobal)
		#undo_redo.add_do_method(_gizmoController.get_gizmo(), "set_cursor_3d", newPosGlobal)
		
		#_gizmoController.request_redraw()
		undo_redo.add_do_method(_gizmoController, "request_redraw")
		undo_redo.add_undo_method(_gizmoController, "request_redraw")
		
		_currentGlobalPosition = newPosGlobal
		_currentScale = cursor3d.get_scale()
		
		undo_redo.commit_action()
		return
		
	# check scale
	if (
		(abs(offsetScale.x) > 0.1 or abs(offsetScale.y) > 0.1 or abs(offsetScale.z) > 0.1)
		and (abs(offsetScale.x) < 1.0)
		and (abs(offsetScale.y) < 1.0)
		and (abs(offsetScale.z) < 1.0)
	):
		prints("scale face", offsetScale)
		_is_scaling = true
		# disconnect, to prevent editor to not fire event again before we commit
		if (cursor3d.is_connected("transform_changed", self, "_on_cursor_3d_transform_changed")):
			cursor3d.disconnect("transform_changed", self, "_on_cursor_3d_transform_changed")
		
		var undo_redo = MeshCreator_Signals.get_editor_plugin().get_undo_redo()		
		undo_redo.create_action("Scale Face")
		
		# z scales both axis at once, combine
		var offset = Vector2(
			offsetScale.x + offsetScale.z,
			offsetScale.y + offsetScale.z
		)
		
		for face in _get_selected_faces():
			undo_redo.add_do_method(spatial.get_mc_mesh(), "scale_face", face.get_mesh_index(), offset)
			undo_redo.add_undo_method(spatial.get_mc_mesh(), "scale_face", face.get_mesh_index(), -offset)
		
		# both axis
		#for face in _get_selected_faces():
		#	for vtx in face.get_vertices():
		#		var vtx_center_dist = (vtx.get_position() - face.get_centroid())
		#		if (vtx_center_dist.length() > abs(offsetScale.y)):
		#			var step = vtx_center_dist.normalized() * offsetScale.y
		#			undo_redo.add_do_method(spatial.get_mc_mesh(), "translate_vertex", vtx.get_mesh_index(), step)
		#			undo_redo.add_undo_method(spatial.get_mc_mesh(), "translate_vertex", vtx.get_mesh_index(), -step)
				
		undo_redo.add_do_method(meshTools, "SetMeshFromMeshCreatorMesh", spatial.get_mc_mesh(), spatial)
		undo_redo.add_undo_method(meshTools, "SetMeshFromMeshCreatorMesh", spatial.get_mc_mesh(), spatial)
		undo_redo.add_do_method(_gizmoController, "request_redraw")
		undo_redo.add_undo_method(_gizmoController, "request_redraw")
		
		_currentGlobalPosition = newPosGlobal
		_currentScale = cursor3d.get_scale()
		
		undo_redo.commit_action()
		return
	pass
	
func _get_selected_faces():
	return _gizmoController.get_gizmo().get_spatial_node().get_mc_mesh().get_faces_selection(
		get_selection_store().get_store()
	)

func _rotate_cursor_to_face(face):
	var cursor3d = _gizmoController.get_gizmo().get_cursor_3d()
	var x_normal = face.get_edge_normal(0)
	var y_normal = face.get_normal()
	var z_normal = face.get_edge_normal(1)
	
	cursor3d.look_at(cursor3d.global_transform.origin + y_normal, z_normal)
	var basis = Basis(cursor3d.global_transform.basis)
	#cursor3d.rotate(x_normal.cross(basis.x).normalized(),basis.x.angle_to(x_normal))
	#cursor3d.rotate(y_normal.cross(basis.y).normalized(),basis.y.angle_to(y_normal))
	#cursor3d.rotate(z_normal.cross(basis.z).normalized(),basis.z.angle_to(z_normal))
	(cursor3d as Spatial).rotate(basis.z.normalized(), basis.x.angle_to(y_normal))
	
		
func _scale_cursor_to_face(face):
	if (_is_scaling):
		return
	if (face == null):
		return
	var cursor3d = _gizmoController.get_gizmo().get_cursor_3d()
	var scale_x = max(face.get_edge_length(0), face.get_edge_length(2))
	var scale_y = max(face.get_edge_length(1), face.get_edge_length(3))
	var scale_z = 0.1
	(cursor3d as Spatial).set_scale(Vector3(scale_x * 2, scale_y * 2, scale_z * 2))
	_currentScale = cursor3d.get_scale()
	pass
	
func _update_translate_gizmo():
	var selectedFaces : Array = _get_selected_faces()
	prints("updating translate gizmo", selectedFaces)
	_startGlobalPosition = Vector3.ZERO
	_currentGlobalPosition = Vector3.ZERO	
	_startScale = Vector3.ONE
	_currentScale = Vector3.ONE
	var cursor3d = _gizmoController.get_gizmo().get_cursor_3d()
	var spatial: Spatial = _gizmoController.get_gizmo().get_spatial_node()	
	if (spatial != null and not selectedFaces.empty()): 
		var lastFace = selectedFaces.back()
		_startGlobalPosition = spatial.to_global(lastFace.get_centroid())
		_currentGlobalPosition = _startGlobalPosition
			
		_startScale = cursor3d.get_scale()
		
		_startScale.x = max(0.0, _startScale.x)
		_startScale.y = max(0.0, _startScale.y)
		_startScale.z = max(0.0, _startScale.z)
		
		_currentScale = _startScale
		
		if cursor3d.is_connected("transform_changed", self, "_on_cursor_3d_transform_changed"):
			cursor3d.disconnect("transform_changed", self, "_on_cursor_3d_transform_changed")
		
		if (not Input.is_mouse_button_pressed(BUTTON_LEFT)):
			_gizmoController.get_gizmo().set_cursor_3d(_currentGlobalPosition)
			# set rot/scale to match face
			_gizmoController.get_gizmo().focus_cursor_3d()
			
		_rotate_cursor_to_face(lastFace)
		_scale_cursor_to_face(lastFace)
			
		cursor3d.connect("transform_changed", self, "_on_cursor_3d_transform_changed")
		_gizmoController.get_gizmo().show_cursor_3d()
	else:		
		if (cursor3d != null):
			if (cursor3d.is_connected("transform_changed", self, "_on_cursor_3d_transform_changed")):
				cursor3d.disconnect("transform_changed", self, "_on_cursor_3d_transform_changed")
			_gizmoController.get_gizmo().hide_cursor_3d()
			_gizmoController.get_gizmo().focus_mesh_instance()
