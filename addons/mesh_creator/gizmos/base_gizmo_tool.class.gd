# namespace MeshCreator_Gizmos
class_name MeshCreator_Gizmos_BaseGizmoTool
extends Reference

var _gizmoController

func _init(gizmoController) -> void:
	self._gizmoController = gizmoController
	pass
	
# do preparation before tool switch
func set_active() -> void:
	pass
	
func get_tool_name() -> String:
	return ""
	
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
	
# return true if event claimed handled		
func on_input_key(event, camera):
	return false
	pass	
	
func on_gui_action(actionCode: String, payload):
	pass
	
# setup handles and stuff	
func on_gizmo_redraw(gizmo):
	pass
	
# use this to create new handles, return last used index
func on_gizmo_add_handles(nextIndex) -> int:
	return nextIndex
	pass
	
func on_gizmo_get_handle_name(index):
	return ""
	
func on_gizmo_get_handle_value(index):
	return null
	
func on_gizmo_set_handle(index, camera, screen_point: Vector2):
	pass
	
func on_gizmo_commit_handle(index, restore, cancel=false):
	pass

func get_controller_gizmo():
	return _gizmoController.get_gizmo()

func get_cursor_3d():
	return _gizmoController.get_gizmo().get_cursor_3d()
