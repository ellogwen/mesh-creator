class_name MeshCreatorInstanceEditorState

var _faces: Array
var _selectedFaceIds: Array

signal STATE_CHANGED

# ctor
func _init():
	_faces = Array()
	_selectedFaceIds = PoolIntArray()

# faces

func get_faces() -> Array:
	return _faces    
	
func get_face(faceId):
	for face in get_faces():
		if (face.Id == faceId):
			return face
	return null

func add_face(face) -> void:
	self._faces.push_back(face)
	emit_signal("STATE_CHANGED")


# face selection

func get_selected_face_ids() -> Array:
	return _selectedFaceIds
	
func get_selected_faces() -> Array:
	var faceIds: Array = get_selected_face_ids()
	var result = Array()	
	for face in get_faces():
		if (faceIds.has(face.Id)):		
			result.push_back(face)				
	return result

func add_face_id_to_selection(faceId: int) -> void:
	if (is_face_id_selected(faceId) == false):
		_selectedFaceIds.push_back(faceId)
		emit_signal("STATE_CHANGED")
	pass

func remove_face_id_from_selection(faceId: int) -> void:
	_selectedFaceIds.erase(faceId)
	emit_signal("STATE_CHANGED")
	pass

func is_face_id_selected(faceId: int) -> bool:	
	return _selectedFaceIds.has(faceId)
	
func has_selected_faces() -> bool:
	return not _selectedFaceIds.empty()
	
func clear_face_selection() -> void:
	_selectedFaceIds.clear()
	emit_signal("STATE_CHANGED")
	pass

func notify_state_changed() -> void:
	emit_signal("STATE_CHANGED")

