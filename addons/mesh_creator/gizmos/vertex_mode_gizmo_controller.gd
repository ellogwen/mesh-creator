# namespace MeshCreator_Gizmos
class_name MeshCreator_Gizmos_VertexModeGizmoController
extends MeshCreator_Gizmos_BaseModeGizmoController

func _init(gizmo).(gizmo):	
	pass
	
func setup(plugin):
	.setup(plugin)
	_setup_tools()
	_setup_materials(plugin)
	pass
	
# do preparation here
func set_active():
	.set_active()
	pass
	
# do cleanup here
func set_inactive():
	.set_inactive()
	pass	

func activate_tool(what):
	.activate_tool(what)
	pass

func gizmo_redraw():
	.gizmo_redraw()
	
	# make sure at least the selection tool is active
	if (_activeTool == null):
		activate_tool(get_gizmo().get_editor_tool('VERTEX_SELECTION'))	
	pass
	
# editor mouse click events
func gizmo_forward_mouse_button(event: InputEventMouseButton, camera):	
	return .gizmo_forward_mouse_button(event, camera)

# editor mouse move events
func gizmo_forward_mouse_move(event, camera):
	return .gizmo_forward_mouse_move(event, camera)
	
# editor keyboard events
func gizmo_forward_key_input(event, camera):
	return .gizmo_forward_key_input(event, camera)

		
func request_action(actionName, params = []):
	if (actionName == "TOOL_CANCEL"):
		print("Cancel operation")
		activate_tool(get_gizmo().get_editor_tool('VERTEX_SELECTION'))
	elif (actionName == "TOOL_SELECT"):
		print("Tool Select")
		activate_tool(get_gizmo().get_editor_tool('VERTEX_SELECTION'))
	elif (actionName == "TOOL_TRANSLATE"):
		print("Tool Move")
		activate_tool(get_gizmo().get_editor_tool('VERTEX_TRANSLATE'))	
	pass

func _setup_tools():
	get_gizmo().set_editor_tool('VERTEX_SELECTION', MeshCreator_Gizmos_VertexSelectionGizmoTool.new(self))
	get_gizmo().set_editor_tool('VERTEX_TRANSLATE', MeshCreator_Gizmos_VertexTranslateGizmoTool.new(self))	
	pass
	
func _setup_materials(plugin):
	var baseLineMat: SpatialMaterial = plugin.get_material("lines", self)
	MATERIALS.FACE_SELECTED_LINE = baseLineMat.duplicate()	
	pass			