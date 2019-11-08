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
		_insetFactor = 0.25
	pass
	
# cleanup on tool switch
func set_inactive() -> void:
	_myFace = null	
	_insetFactor = 0.0
	pass	
	
func on_gizmo_add_handles(nextIndex: int) -> int:		
	if _myFace == null: 
		return nextIndex
		
#	_insetFactor = clamp(_insetFactor, 0.0, 1.0)
#
#	var gizmo = _gizmoController.get_gizmo()
#	var spatial = gizmo.get_spatial_node()
#	var faceCenter = spatial.global_transform.xform(_myFace.get_centroid())
#	var lineMat = gizmo.get_plugin().get_material("face_select_line", gizmo)
#
#	var newPts = PoolVector3Array()
#	if _insetFactor > 0.01 and _insetFactor < 0.99:
#		for vtx in _myFace.get_vertices():
#			newPts.push_back(vtx.get_position() + ((faceCenter - vtx.get_position()) * _insetFactor))
#
#	var addLines = PoolVector3Array()
#	var vtxCount = newPts.size()
#	for i in range(0, vtxCount):
#		addLines.push_back(newPts[i] - (_myFace.get_normal() * 0.001))
#		addLines.push_back(newPts[(i + 1) % vtxCount] - (_myFace.get_normal() * 0.001))
#
#	if addLines.size() > 0:
#		gizmo.add_lines(addLines, lineMat, false)
		
	#prints(addLines, newPts, _insetFactor)
	
	return nextIndex
	
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
	return false
	pass
	
# return true if event claimed handled	
func on_input_mouse_move(event: InputEventMouse, camera) -> bool:
	if (_lastMousePos != null):
		if event.position.x < _lastMousePos.x:
			_insetFactor -= 0.01
		else:
			_insetFactor += 0.01
		_insetFactor = clamp(_insetFactor, 0.0, 1.0)	
	_lastMousePos = event.position
	_gizmoController.request_redraw()
	return false
	pass	

func _get_selected_faces():
	return _gizmoController.get_gizmo().get_spatial_node().get_mc_mesh().get_faces_selection(
		_gizmoController.get_gizmo().get_face_selection_store().get_store()
	)