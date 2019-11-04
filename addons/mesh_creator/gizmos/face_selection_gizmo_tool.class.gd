extends MeshCreator_Gizmos_BaseGizmoTool

# namespace MeshCreator_Gizmos
class_name MeshCreator_Gizmos_FaceSelectionGizmoTool

var _selectedFaceIds: Array
func get_selected_face_ids(): return _selectedFaceIds


#################
# base overrides
#################

func _init(gizmoController).(gizmoController) -> void:
	_selectedFaceIds = Array()
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
			if _selectedFaceIds.has(clickedFaces[0].face.get_mesh_index()):
				_selectedFaceIds.erase(clickedFaces[0].face.get_mesh_index())
			else:
				# only support on face for now. @todo fix this later when cleaned up structure
				# and ngons are no problem anymore
				_selectedFaceIds.clear()
				###########
				_selectedFaceIds.push_back(clickedFaces[0].face.get_mesh_index())
			_gizmoController.request_redraw()
			return true # handled the click
	if (event.get_button_index() == BUTTON_RIGHT and event.pressed):		
		if (not _selectedFaceIds.empty()):
			_selectedFaceIds.clear()
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

func _get_clicked_on_faces_sorted_by_cam_distance(clickPos, camera):
	var result = Array()
	var mci = _gizmoController.get_gizmo().get_spatial_node()
	for face in mci.get_mc_mesh().get_faces():
		if (_has_clicked_on_face(face, clickPos, camera)):
			var clickInfo = {
				face = face,
				distance_camera = (face.get_centroid() - camera.transform.origin).length()
			}
			result.push_back(clickInfo)
	# sort by distance ascending
	result.sort_custom(self, "_sort_by_distance_camera_asc")
	return result

func _sort_by_distance_camera_asc(a, b):
	return a.distance_camera < b.distance_camera	

func _has_clicked_on_face(face, point, camera):
	var mci = _gizmoController.get_gizmo().get_spatial_node()
	for tri in face.get_triangles():
		var screenA = camera.unproject_position(mci.transform.origin + tri.get_a())
		var screenB = camera.unproject_position(mci.transform.origin + tri.get_b())
		var screenC = camera.unproject_position(mci.transform.origin + tri.get_c())		
		if Geometry.point_is_inside_triangle(point, screenA, screenB, screenC):
			return true		
	
	return false