extends MeshCreator_Gizmos_BaseGizmoTool

# namespace MeshCreator_Gizmos
class_name MeshCreator_Gizmos_EdgeSelectionGizmoTool

var _startGlobalPosition = Vector3.ZERO
var _currentGlobalPosition = Vector3.ZERO
var meshTools = MeshCreator_MeshTools.new()

func get_selection_store():
	return _gizmoController.get_gizmo().get_edge_selection_store()


#################
# base overrides
#################

func _init(gizmoController).(gizmoController) -> void:	
	pass
	
func get_tool_name() -> String:
	return "EDGE_SELECTION"
	
# do preparation before tool switch
func set_active() -> void:
	pass
	
# cleanup on tool switch
func set_inactive() -> void:
	var cursor3d = get_cursor_3d()
	_gizmoController.get_gizmo().set_cursor_3d(_currentGlobalPosition)
	_startGlobalPosition = Vector3.ZERO
	_currentGlobalPosition = Vector3.ZERO
	
	if (cursor3d != null):
		if cursor3d.is_connected("transform_changed", self, "_on_cursor_3d_transform_changed"):
			cursor3d.disconnect("transform_changed", self, "_on_cursor_3d_transform_changed")
	_gizmoController.get_gizmo().hide_cursor_3d()
	_gizmoController.get_gizmo().focus_mesh_instance()
	pass
	
# return true if event claimed handled
func on_input_mouse_button(event: InputEventMouseButton, camera) -> bool:
	# prevent interfering with editor while using spatial gizmos
	if (event.get_button_index() == BUTTON_LEFT):
		if (_gizmoController.get_gizmo().is_cursor_3d_selected()):
			return false
			
	if (event.get_button_index() == BUTTON_RIGHT and not event.pressed):
		var mci = _gizmoController.get_gizmo().get_spatial_node()			
		var clickedEdgeIds = _get_clicked_on_edges_ids_sorted_by_cam_distance(event.get_position(), camera)
		if (clickedEdgeIds.size() > 0):			
			prints("clicked on edge ", clickedEdgeIds[0])
			if get_selection_store().is_selected(clickedEdgeIds[0]):
				get_selection_store().remove_from_selection(clickedEdgeIds[0])
			else:
				# only support on edge for now. @todo fix this later when cleaned up structure				
				get_selection_store().clear()
				###########
				get_selection_store().add_to_selection(clickedEdgeIds[0])
			_gizmoController.call_deferred("request_redraw")
			return true # handled the click
				
	#if (event.get_button_index() == BUTTON_RIGHT and event.pressed):		
	#	if (not get_selection_store().is_empty()):
	#		get_selection_store().clear()
	#		_gizmoController.request_redraw()
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


# @todo this only spits out max 1 edge. 
# multiple edge will be supported soon! (i promise)
func _get_clicked_on_edges_ids_sorted_by_cam_distance(clickPos, camera: Camera):			
	var mci: Spatial = _gizmoController.get_gizmo().get_spatial_node()
	var camRayNormal = camera.project_ray_normal(clickPos)	
	
	var clickedFaces = Array()
	for face in mci.get_mc_mesh().get_faces():
		var normalDot = camRayNormal.dot(face.get_normal())
		for tri in face.get_triangles():
			if (normalDot >= 0): # only respect faces that are visible for the cam
				var intersection = Geometry.ray_intersects_triangle(camera.transform.origin, camRayNormal, mci.global_transform.xform(tri.get_a()), mci.global_transform.xform(tri.get_b()), mci.global_transform.xform(tri.get_c()))
				if (intersection != null):
					var closestDistance = 9999999.0
					var closestEdgeId = -1
					var localIntersection = mci.to_local(intersection)
					for edgeId in face.get_edges():
						var edge = mci.get_mc_mesh().get_edge(edgeId)						
						var dist = localIntersection.distance_to(edge.get_center())						
						if (dist - 0.0001 < closestDistance):
							closestDistance = dist
							closestEdgeId = edge.get_mesh_index()						
					
					var clickInfo = {
						face = face,
						distance_camera = (mci.global_transform.xform(face.get_centroid()) - camera.transform.origin).length(),
						closestEdgeId = closestEdgeId
					}					
					
					clickedFaces.push_back(clickInfo)
					
	clickedFaces.sort_custom(self, "_sort_by_distance_camera_asc")	
	
	var result = Array()
	
	for info in clickedFaces:
		result.push_back(info.closestEdgeId)	
	
	return result

func _sort_by_distance_camera_asc(a, b):
	return a.distance_camera < b.distance_camera
	
func _get_selected_edges():
	return _gizmoController.get_gizmo().get_spatial_node().get_mc_mesh().get_edges_selection(
		get_selection_store().get_store()
	)
	
func _update_translate_gizmo():
	var selectedEdges : Array = _get_selected_edges()
	_startGlobalPosition = Vector3.ZERO
	_currentGlobalPosition = Vector3.ZERO
	var cursor3d = _gizmoController.get_gizmo().get_cursor_3d()
	var spatial: Spatial = _gizmoController.get_gizmo().get_spatial_node()	
	if (spatial != null and not selectedEdges.empty()): 
		var lastEdge = selectedEdges.back()
		_startGlobalPosition = spatial.to_global(lastEdge.get_center())
		_currentGlobalPosition = _startGlobalPosition
		
		if cursor3d.is_connected("transform_changed", self, "_on_cursor_3d_transform_changed"):
			cursor3d.disconnect("transform_changed", self, "_on_cursor_3d_transform_changed")
		
		if (not Input.is_mouse_button_pressed(BUTTON_LEFT)):
			_gizmoController.get_gizmo().set_cursor_3d(_currentGlobalPosition)			
			_gizmoController.get_gizmo().focus_cursor_3d()
			
		_rotate_cursor_to_edge(lastEdge)
		_scale_cursor_to_edge(lastEdge)
			
		cursor3d.connect("transform_changed", self, "_on_cursor_3d_transform_changed")
		_gizmoController.get_gizmo().show_cursor_3d()
	else:		
		if (cursor3d != null):
			if (cursor3d.is_connected("transform_changed", self, "_on_cursor_3d_transform_changed")):
				cursor3d.disconnect("transform_changed", self, "_on_cursor_3d_transform_changed")
			_gizmoController.get_gizmo().hide_cursor_3d()
			_gizmoController.get_gizmo().focus_mesh_instance()
			
func _rotate_cursor_to_edge(edge):
	var cursor3d = _gizmoController.get_gizmo().get_cursor_3d()
	var abNormal = edge.to_vector().normalized()
	var basis = Basis(Vector3.RIGHT, Vector3.UP, Vector3.FORWARD)
	cursor3d.global_transform.basis = basis	
	(cursor3d as Spatial).rotate(basis.z.normalized(), basis.x.angle_to(abNormal))
	
func _scale_cursor_to_edge(edge):	
	if (edge == null):
		return
	var cursor3d = _gizmoController.get_gizmo().get_cursor_3d()
	var scale_x = edge.length()
	var scale_y = 0.1
	var scale_z = 0.1
	(cursor3d as Spatial).set_scale(Vector3(scale_x * 2, scale_y * 2, scale_z * 2))
	pass
	
func _on_cursor_3d_transform_changed():
	var cursor3d = _gizmoController.get_gizmo().get_cursor_3d()
	var newPosGlobal = _gizmoController.get_gizmo().get_cursor_3d().global_transform.origin
	var offsetGlobal = (newPosGlobal - _currentGlobalPosition)
	
	var spatial = _gizmoController.get_gizmo().get_spatial_node()
	var travelDistance = (newPosGlobal - _currentGlobalPosition).length()
	
	prints("set new transform", cursor3d.global_transform.origin, cursor3d.scale)
		
	# check translate
	if ((travelDistance > 0.1 or travelDistance < -0.1) and abs(travelDistance) < 10):
		# disconnect, to prevent editor to not fire event again before we commit
		if (cursor3d.is_connected("transform_changed", self, "_on_cursor_3d_transform_changed")):
			cursor3d.disconnect("transform_changed", self, "_on_cursor_3d_transform_changed")
		
		var undo_redo = MeshCreator_Signals.get_editor_plugin().get_undo_redo()
		undo_redo.create_action("Translate Edge")
		
		#var newPosLocal = spatial.to_local(newPosGlobal)
		#var newPos = Vector3(stepify(newPosLocal.x, 0.05), stepify(newPosLocal.y, 0.05), stepify(newPosLocal.z, 0.05))	
		#var newPos = Vector3(stepify(newPosGlobal.x, 0.05), stepify(newPosGlobal.y, 0.05), stepify(newPosGlobal.z, 0.05))	
		var newPos = newPosGlobal
		#var offset = newPos - spatial.to_local(_currentGlobalPosition)
		var offset = newPos - _startGlobalPosition
		
		var trans_edges = PoolIntArray()
		for edge in _get_selected_edges():
			trans_edges.push_back(edge.get_mesh_index())
			
			# undo_redo.add_do_method(spatial.get_mc_mesh(), "translate_vertex", edge.get_a().get_mesh_index(), offset)
			# undo_redo.add_do_method(spatial.get_mc_mesh(), "translate_vertex", edge.get_b().get_mesh_index(), offset)
			# undo_redo.add_undo_method(spatial.get_mc_mesh(), "translate_vertex", edge.get_a().get_mesh_index(), -offset)
			# undo_redo.add_undo_method(spatial.get_mc_mesh(), "translate_vertex", edge.get_b().get_mesh_index(), -offset)
		
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
		
		undo_redo.commit_action()
		return
		
	pass
