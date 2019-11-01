# namespace MeshCreator_Gizmos
class_name MeshCreator_Gizmos_BaseGizmoTool

var _gizmoController

func _init(gizmoController) -> void:
	self._gizmoController = gizmoController
	pass
	
# do preparation before tool switch
func set_active() -> void:
	pass
	
# cleanup on tool switch
func set_inactive() -> void:
	pass
	
# return true if event claimed handled
func on_input_mouse_button(event: InputEventMouseButton, camera) -> bool:
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
	
# setup handles and stuff	
func on_gizmo_redraw(gizmo):
	pass
	
func on_gizmo_get_handle_name(index):
	return ""
	
func on_gizmo_get_handle_value(index):
	return null