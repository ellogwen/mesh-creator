extends MeshCreator_Gizmos_BaseGizmoTool
class_name MeshCreator_Gizmos_FaceInsetGizmoTool

var _fromHandleIndex = -1

var _insetFactor = 0.0
var _myFace = null
var _lastMousePos = null

var meshTools = MeshCreator_MeshTools.new()

func _init(_gizmoController).(_gizmoController):
	pass
	
func get_tool_name() -> String:
	return "FACE_INSET"
	
func get_inset_factor():
	return _insetFactor
	
# do preparation before tool switch
func set_active() -> void:
	_myFace = null
	_lastMousePos = null
	var selectedFaces = _get_selected_faces()
	if not selectedFaces.empty():				
		_myFace = selectedFaces.front()
		
	if (_myFace != null):		
		_insetFactor = 0.5
	pass
	
# cleanup on tool switch
func set_inactive() -> void:
	_myFace = null	
	_insetFactor = 0.0
	pass	
	
# return true if event claimed handled
func on_input_mouse_button(event: InputEventMouseButton, camera) -> bool:
	if (event.button_index == BUTTON_RIGHT and event.pressed):
		# cancel operation
		set_inactive()
		_gizmoController.request_action("TOOL_CANCEL")
		return true # claim event as handled
	
	if (event.button_index == BUTTON_LEFT and event.pressed):	
		if (_myFace != null and _insetFactor > 0.01 and _insetFactor < 0.99):
			_gizmoController.inset_selected_faces(_insetFactor)
			set_inactive()
			_gizmoController.request_action("TOOL_CANCEL")
			return true # claim event as handled

	if (event.button_index == BUTTON_WHEEL_UP):
		_insetFactor += 0.05
		_insetFactor = clamp(_insetFactor, 0.0, 1.0)
		_gizmoController.request_redraw()
		return true

	if (event.button_index == BUTTON_WHEEL_DOWN):
		_insetFactor -= 0.05
		_insetFactor = clamp(_insetFactor, 0.0, 1.0)
		_gizmoController.request_redraw()
		return true
	
	return false
	pass
	
# return true if event claimed handled	
func on_input_mouse_move(event: InputEventMouse, camera) -> bool:	
	if (_myFace != null):		
		# get face center as screen reference
		var myFaceCenterScreen = camera.unproject_position(_myFace.get_centroid())
		prints(myFaceCenterScreen, event.position, _lastMousePos)
		if (_lastMousePos != null):
			var newDistance = myFaceCenterScreen.distance_to(event.position)
			var oldDistance = myFaceCenterScreen.distance_to(_lastMousePos)
			if (newDistance < oldDistance):
				_insetFactor -= 0.05
			elif(newDistance > oldDistance):
				_insetFactor += 0.05
			_insetFactor = clamp(_insetFactor, 0.0, 1.0)	
	_lastMousePos = event.position
	_gizmoController.request_redraw()
	return false
	pass	

func _get_selected_faces():
	return _gizmoController.get_gizmo().get_spatial_node().get_mc_mesh().get_faces_selection(
		_gizmoController.get_gizmo().get_face_selection_store().get_store()
	)