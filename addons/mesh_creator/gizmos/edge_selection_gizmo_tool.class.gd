extends MeshCreator_Gizmos_BaseGizmoTool

# namespace MeshCreator_Gizmos
class_name MeshCreator_Gizmos_EdgeSelectionGizmoTool

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
	pass
	
# return true if event claimed handled
func on_input_mouse_button(event: InputEventMouseButton, camera) -> bool:
	if (event.get_button_index() == BUTTON_LEFT and event.pressed):		
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
			_gizmoController.request_redraw()
			return true # handled the click
	if (event.get_button_index() == BUTTON_RIGHT and event.pressed):		
		if (not get_selection_store().is_empty()):
			get_selection_store().clear()
			_gizmoController.request_redraw()
			return true # click handled
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