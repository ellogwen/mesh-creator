tool
extends EditorPlugin

enum SelectionModes { MESH, VERTEX, EDGE, FACE }

signal state_changed
signal mode_changed

#signal EDITOR_MOUSE_MOTION
#signal EDITOR_MOUSE_BUTTON

var toolBoxDock
var current_editor_context = null
var MeshTools = preload("res://addons/mesh_creator/MeshTools.gd")
var MeshCreatorInstance = preload("res://addons/mesh_creator/MeshCreatorInstance.gd")
var MeshCreatorGizmoPlugin = preload("res://addons/mesh_creator/MeshCreatorGizmoPlugin.gd")
var meshCreatorGizmoPlugin = MeshCreatorGizmoPlugin.new()
var SelectionMode = SelectionModes.VERTEX

var __Debug_Pos3D

func get_gizmo_plugin():
	return meshCreatorGizmoPlugin

func _enter_tree() -> void:
	meshCreatorGizmoPlugin.set_creator(self)
	connect("main_screen_changed", self, "_on_editor_main_screen_changed")
	toolBoxDock = preload("res://addons/mesh_creator/ToolBoxDock.tscn").instance()
	toolBoxDock.connect("button_create_new_mesh", self, "_on_toolbox_button_create_new_mesh")
	toolBoxDock.connect("tool_action", meshCreatorGizmoPlugin, "_on_toolbox_tool_action")
	toolBoxDock.set_creator(self)
	add_control_to_dock(DOCK_SLOT_LEFT_UL, toolBoxDock)
	add_spatial_gizmo_plugin(meshCreatorGizmoPlugin)
	emit_signal("state_changed")
	set_selection_mode(SelectionModes.MESH)
	print("[Mesh Creator] Ready to take off!")

func _exit_tree() -> void:
	remove_control_from_docks(toolBoxDock)
	remove_spatial_gizmo_plugin(meshCreatorGizmoPlugin)	
	toolBoxDock.queue_free()
	print("[Mesh Creator] Unloaded... Bye!")	
	
func forward_spatial_gui_input(camera, event):	
	if event is InputEventMouseMotion:				
		return meshCreatorGizmoPlugin.forward_editor_mouse_motion_input(event, camera)
	if event is InputEventMouseButton:
		return meshCreatorGizmoPlugin.forward_editor_mouse_button_input(event, camera)		
	return false
	
func handles(obj):
	return obj is MeshCreatorInstance
	pass
	
func make_visible(visible):
	if (visible):
		toolBoxDock.show()
	else:
		toolBoxDock.hide()
	pass
	
func set_selection_mode(selectionMode):
	if (selectionMode != SelectionMode):
		SelectionMode = selectionMode
		emit_signal("mode_changed")
		print("selection mode changed to " + str(SelectionMode))
	pass
	
func _on_editor_main_screen_changed(screen_name) -> void:
	self.current_editor_context = screen_name	
	
func _on_toolbox_button_create_new_mesh() -> void:
	var root3D = get_editor_interface().get_edited_scene_root()	
	if (root3D == null):
		return
		
	var mci = _create_new_cube()
	root3D.add_child(mci)
	mci.set_owner(root3D)
	mci.SetEditorPlugin(self)
	
	var dbg3d = Position3D.new()
	dbg3d.name = "__DebugPos3D"
	dbg3d.hide()
	mci.add_child(dbg3d)
	dbg3d.set_owner(root3D)	
	pass

func _create_new_cube():	
	var mt = MeshTools.new()		
	var cube = mt.MeshGenerator_Cube()
	return cube
	pass