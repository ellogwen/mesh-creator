tool
extends EditorPlugin

####################
# ENUMS
####################

enum SelectionModes { MESH, VERTEX, EDGE, FACE }


####################
# SIGNALS
####################

signal state_changed
signal mode_changed

#signal EDITOR_MOUSE_MOTION
#signal EDITOR_MOUSE_BUTTON



####################
# GODOT LIFECYCLE
####################

func _enter_tree() -> void:
	add_autoload_singleton("MeshCreator_Signals", "res://addons/mesh_creator/signals.gd")
	add_autoload_singleton("MeshCreator_Indicator", "res://addons/mesh_creator/gizmos/indicator.singleton.gd")
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
	MeshCreator_Signals.connect("UI_GENERATOR_GENERATE_MESH", self, "_on_generator_create_mesh")
	MeshCreator_Signals.set_editor_plugin(self)
	uiFaceProperties = UIFaceProperties.instance()
	uiEdgeProperties = UIEdgeProperties.instance()
	uiFaceProperties.hide()
	uiEdgeProperties.hide()
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_BOTTOM, uiFaceProperties)
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_BOTTOM, uiEdgeProperties)	
	_create_radial_menu()
	print("[Mesh Creator] Ready to take off!")


func _exit_tree() -> void:
	remove_control_from_docks(toolBoxDock)
	remove_spatial_gizmo_plugin(meshCreatorGizmoPlugin)	
	toolBoxDock.queue_free()
	remove_autoload_singleton("MeshCreator_Signals")
	remove_autoload_singleton("MeshCreator_Indicator")
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_BOTTOM, uiFaceProperties)
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_BOTTOM, uiEdgeProperties)
	uiFaceProperties.queue_free()	
	uiEdgeProperties.queue_free()
	_remove_radial_menu()
	print("[Mesh Creator] Unloaded... Bye!")	


####################
# GODOT EDITOR PLUGIN OVERWRITES
####################

func get_gizmo_plugin():
	return meshCreatorGizmoPlugin

func forward_spatial_gui_input(camera, event):	
	if event is InputEventMouseMotion:				
		return meshCreatorGizmoPlugin.forward_editor_mouse_motion_input(event, camera)
	if event is InputEventMouseButton:
		return meshCreatorGizmoPlugin.forward_editor_mouse_button_input(event, camera)
	if event is InputEventKey:
		return meshCreatorGizmoPlugin.forward_editor_key_input(event, camera)
	return false

# this methods returns true if the selected node
# will get handled by this plugin	
func handles(obj):
	# handles on spatial so that the 
	# gui is available
	return obj is Spatial
	pass
	
func make_visible(visible):
	if (toolBoxDock == null):
		return
		
	if (visible):
		toolBoxDock.show()
	else:
		toolBoxDock.hide()
	pass



####################
# PLUGIN GETTERS SETTERS
####################

var __Debug_Pos3D
var toolBoxDock
var current_editor_context = null
var MeshCreatorInstance = preload("res://addons/mesh_creator/MeshCreatorInstance.gd")
var MeshCreatorGizmoPlugin = preload("res://addons/mesh_creator/MeshCreatorGizmoPlugin.gd")
var meshCreatorGizmoPlugin = MeshCreatorGizmoPlugin.new()
var SelectionMode = SelectionModes.VERTEX
var UIFaceProperties = preload("res://addons/mesh_creator/ui/FaceProperties.tscn")
var UIEdgeProperties = preload("res://addons/mesh_creator/ui/EdgeProperties.tscn")
var uiFaceProperties: Panel	
var uiEdgeProperties: Panel	

var _editorRadialMenu: Control
func get_editor_radial_menu() -> Control:
	return _editorRadialMenu

# workaround to access the the spatial editor control
# tries to warn if something does look right,
# however, this ~~may~~ will break	
func get_spatial_editor_control():
	var spatial_editor = get_editor_interface().get_editor_viewport().get_child(1).get_child(1).get_child(0).get_child(0).get_child(0).get_child(1)	
	if (spatial_editor == null or spatial_editor.name == ""):
		printerr("MeshCreator uses a hacky way to access the spatial editor control, since there is (was) no build in way to do so. However, something went wrong accessing the Spatial Editor Control, maybe a never version changed the UI structure or an parallel installed plugin messes around with the editor as well.", var2str(spatial_editor))
	return spatial_editor



#########################
# PLUGIN PUBLIC METHODS
#########################

func notify_state_changed():
	emit_signal("state_changed")
	pass

func set_selection_mode(selectionMode):
	if (selectionMode != SelectionMode):
		SelectionMode = selectionMode
		emit_signal("mode_changed")
		print("selection mode changed to " + str(SelectionMode))
	pass

func get_face_properties_panel():
	return uiFaceProperties
	
func get_edge_properties_panel():
	return uiEdgeProperties	



#########################
# PLUGIN PRIVATE METHODS
#########################

func _create_radial_menu() -> void:
	_editorRadialMenu = preload("res://addons/mesh_creator/ui/RadialMenu.tscn").instance()
	_editorRadialMenu.name = "MC_EditorRadialMenu"
	var spatialEditor = get_spatial_editor_control()
	spatialEditor.add_child(_editorRadialMenu)
	_editorRadialMenu.set_owner(spatialEditor.get_owner())
	_editorRadialMenu.hide_menu()
	pass
	
func _remove_radial_menu() -> void:
	if _editorRadialMenu != null:		
		_editorRadialMenu.get_parent().remove_child(_editorRadialMenu)
		_editorRadialMenu.queue_free()
	pass

func _create_new_cube():	
	var mt = MeshCreator_MeshTools.new()
	var cubegen = MeshCreator_Generators_BoxMeshGenerator.new()
	var cube = mt.MeshGenerator_Generate(cubegen)
	return cube
	pass

	

###############################
# PLUGIN SIGNAL CALLBACKS
###############################

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
	
	get_editor_interface().get_selection().clear()
	get_editor_interface().get_selection().add_node(mci)
	
	var dbg3d = Position3D.new()
	dbg3d.name = "__DebugPos3D"
	dbg3d.hide()
	mci.add_child(dbg3d)
	dbg3d.set_owner(root3D)	
	pass

func _on_generator_create_mesh(generator):
	if (generator == null):
		return
	if (not generator.is_valid()):
		return
		
	var mt = MeshCreator_MeshTools.new()
	var mci = mt.MeshGenerator_Generate(generator)
	var root3D = get_editor_interface().get_edited_scene_root()	
	root3D.add_child(mci)
	mci.set_owner(root3D)
	mci.SetEditorPlugin(self)
	get_editor_interface().get_selection().clear()
	get_editor_interface().get_selection().add_node(mci)
