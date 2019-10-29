extends EditorSpatialGizmo

var MeshCreatorInstance = preload("res://addons/mesh_creator/MeshCreatorInstance.gd")
var Cursor3D = preload("res://addons/mesh_creator/Cursor3D.gd")
#var MeshTools = preload("res://addons/mesh_creator/MeshTools.gd")

var EditorHelperScript = preload("res://addons/mesh_creator/MCEditorHelper.gd")
var editorHelperNode

signal VERTEX_POSITION_CHANGED

var _cursor3D
var _gizmo_controller = null
var _vertexGizmoController
var _faceGizmoController

func _init():
	_vertexGizmoController = preload("res://addons/mesh_creator/gizmos/vertex_mode_gizmo_controller.gd").new(self)
	_faceGizmoController = preload("res://addons/mesh_creator/gizmos/face_mode_gizmo_controller.gd").new(self)
	pass
	
func setup(plugin):
	_vertexGizmoController.setup(plugin)
	_faceGizmoController.setup(plugin)
	pass
	
func _add_editor_helper():
	var parent = get_spatial_node().get_parent()
	if parent.has_node("MC_EditorHelperNode"):
		return
	var helperNode = Spatial.new()
	helperNode.name = "MC_EditorHelperNode"
	helperNode.set_script(EditorHelperScript)
	parent.add_child(helperNode)
	helperNode.set_owner(parent.get_owner())
	pass
	
func set_cursor_3d(pos):
	if (_cursor3D == null):
		_cursor3D = Cursor3D.new()
		_cursor3D.name = "Cursor3D"
		get_spatial_node().get_parent().add_child(_cursor3D)
		_cursor3D.set_owner(get_spatial_node().get_owner())
		_cursor3D.connect("transform_changed", self, "_on_cursor_3d_transform_changed")
		_cursor3D.hide()		
	_cursor3D.global_transform.origin = pos
	pass

func show_cursor_3d():
	if (_cursor3D != null):
		_cursor3D.show()
		
func hide_cursor_3d():
	if (_cursor3D != null):
		_cursor3D.hide()
		
func _set_active_gizmo_controller(controller):
	if (_gizmo_controller != null):
		_gizmo_controller.set_inactive()
	
	if (controller != null):
		controller.set_active()
	
	_gizmo_controller = controller
	pass

func redraw():
	print("Redraw (Selection Mode) " + str(get_plugin().get_creator().SelectionMode))
	match(get_plugin().get_creator().SelectionMode):
		# mesh
		0: _set_active_gizmo_controller(null)
		# vertex
		1: _set_active_gizmo_controller(_vertexGizmoController)
		# edge
		2: _set_active_gizmo_controller(null)
		# face
		3: _set_active_gizmo_controller(_faceGizmoController)
		# none
		_: _set_active_gizmo_controller(null)
		
	if (_gizmo_controller != null):
		_gizmo_controller.gizmo_redraw()
	
	_add_editor_helper()
	pass
	
func get_handle_name(index):
	if (_gizmo_controller != null):
		return _gizmo_controller.gizmo_get_handle_name(index)

func get_handle_value(index):
	if (_gizmo_controller != null):
		return _gizmo_controller.gizmo_get_handle_value(index)

#func is_handle_highlighted(index):
#	prints("is_handle_highlighted index", index)
#	return true

func set_handle(index, camera, screen_point):
	if (_gizmo_controller != null):
		_gizmo_controller.gizmo_set_handle(index, camera, screen_point)	

# Commit a handle being edited (handles must have been previously added by add_handles()).
# If the cancel parameter is true, an option to restore the edited value to the original is provided.
func commit_handle(index, restore, cancel=false ):
	prints("commit_handle", index, restore, cancel)
	if (_gizmo_controller != null):
		_gizmo_controller.gizmo_commit_handle(index, restore, cancel)
	else:
		redraw()
	pass
	
func _on_cursor_3d_transform_changed():
	print("cursor transform changed")
	pass
	
func on_creator_mode_changed():
	redraw()
	pass

func forward_editor_mouse_button_input(event, camera) -> bool:
	if (_gizmo_controller != null):
		return _gizmo_controller.gizmo_forward_mouse_button(event, camera)
	return false
	
func forward_editor_mouse_motion_input(event, camera) -> bool:
	if (_gizmo_controller != null):
		return _gizmo_controller.gizmo_forward_mouse_move(event, camera)
	return false