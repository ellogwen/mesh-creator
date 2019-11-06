extends MeshCreator_Gizmos_BaseGizmoTool

# namespace MeshCreator_Gizmos
class_name MeshCreator_Gizmos_FaceSelectionGizmoTool

func get_selection_store():
	return _gizmoController.get_gizmo().get_face_selection_store()


#################
# base overrides
#################

func _init(gizmoController).(gizmoController) -> void:	
	pass
	
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
		var clickedFaces = _get_clicked_on_faces_sorted_by_cam_distance(event.get_position(), camera)
		if (clickedFaces.size() > 0):
			prints("clicked on face ", clickedFaces[0].face)
			if get_selection_store().is_selected(clickedFaces[0].face.get_mesh_index()):
				get_selection_store().remove_from_selection(clickedFaces[0].face.get_mesh_index())
			else:
				# only support on face for now. @todo fix this later when cleaned up structure
				# and ngons are no problem anymore
				get_selection_store().clear()
				###########
				get_selection_store().add_to_selection(clickedFaces[0].face.get_mesh_index())
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
	
func on_input_key():
	pass	

func on_gui_action(actionCode: String, payload):
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