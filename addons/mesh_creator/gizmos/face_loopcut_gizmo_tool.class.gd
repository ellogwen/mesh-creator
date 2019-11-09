extends MeshCreator_Gizmos_BaseGizmoTool
class_name MeshCreator_Gizmos_FaceLoopcutGizmoTool

var _fromHandleIndex = -1

var _insetFactor = 0.0
var _edgeIndex = 0
var _myFace = null
var _lastMousePos = null

var meshTools = MeshCreator_MeshTools.new()

func _init(_gizmoController).(_gizmoController):
	pass
	
func get_tool_name() -> String:
	return "FACE_LOOPCUT"
	
func get_inset_factor():
	return _insetFactor
	
func get_edge_index():
	return _edgeIndex
	
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
	_insetFactor = 0.5
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
			_gizmoController.loopcut_selected_faces(_edgeIndex, _insetFactor)
			set_inactive()
			_gizmoController.request_action("TOOL_CANCEL")
			return true # claim event as handled
			
	# @todo dont use mousewheel but pointer position to determine edge cut index
	if (event.button_index == BUTTON_WHEEL_UP and event.pressed):
		if (_myFace != null):
			_edgeIndex = (_edgeIndex + 1) % _myFace.get_vertex_count()
			_gizmoController.request_redraw()
			return true	
			
	return false
	pass
	
# return true if event claimed handled	
func on_input_mouse_move(event: InputEventMouse, camera) -> bool:
	if (_lastMousePos != null):
		if event.position.x > _lastMousePos.x:
			_insetFactor -= 0.05
		else:
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