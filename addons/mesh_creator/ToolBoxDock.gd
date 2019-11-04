tool
extends Panel

signal button_create_new_mesh
signal tool_action

var _mesh_creator = null

func set_creator(creator):
	_mesh_creator = creator
	_mesh_creator.connect("mode_changed", self, "_on_CreatorModeChanged")
	pass
	
func _ready():
	_connect_signals()
	
func _connect_signals():
	$ToolsList/Button_CreateCube.connect("pressed", self, "_on_ButtonCreateCube_pressed")
	$ToolsList/ModesButtons/Button_ModeMesh.connect("toggled", self, "_on_ButtonModeMesh_Toggle")
	$ToolsList/ModesButtons/Button_ModeVertex.connect("toggled", self, "_on_ButtonModeVertex_Toggle")
	$ToolsList/ModesButtons/Button_ModeEdge.connect("toggled", self, "_on_ButtonModeEdge_Toggle")
	$ToolsList/ModesButtons/Button_ModeFace.connect("toggled", self, "_on_ButtonModeFace_Toggle")
	
	$ToolsList/ToolsButtons/Button_ToolSelect.connect("pressed", self, "_on_ButtonToolSelect_Press")
	$ToolsList/ToolsButtons/Button_ToolMove.connect("pressed", self, "_on_ButtonToolMove_Press")
	$ToolsList/ToolsButtons/Button_ToolExtrude.connect("pressed", self, "_on_ButtonToolExtrude_Press")
	$ToolsList/ToolsButtons/Button_ToolInset.connect("pressed", self, "_on_ButtonToolInset_Press")
	$ToolsList/ToolsButtons/Button_ToolRemove.connect("pressed", self, "_on_ButtonToolRemove_Press")
	pass

func _on_CreatorModeChanged():
	_update_gui()
	pass

func _on_ButtonCreateCube_pressed():
	emit_signal("button_create_new_mesh")
	pass
	
func _on_ButtonModeMesh_Toggle(isPressed):
	if (isPressed):
		_mesh_creator.set_selection_mode(_mesh_creator.SelectionModes.MESH)
	pass

func _on_ButtonModeVertex_Toggle(isPressed):
	if (isPressed):
		_mesh_creator.set_selection_mode(_mesh_creator.SelectionModes.VERTEX)
	pass
	
func _on_ButtonModeEdge_Toggle(isPressed):
	if (isPressed):
		_mesh_creator.set_selection_mode(_mesh_creator.SelectionModes.EDGE)
	pass
	
func _on_ButtonModeFace_Toggle(isPressed):
	if (isPressed):
		_mesh_creator.set_selection_mode(_mesh_creator.SelectionModes.FACE)
	pass	
	
func _on_ButtonToolSelect_Press():
	emit_signal("tool_action", "TOOL_SELECT", null)
	pass
	
func _on_ButtonToolMove_Press():
	emit_signal("tool_action", "TOOL_TRANSLATE", null)
	pass		
	
func _on_ButtonToolInset_Press():
	emit_signal("tool_action", "TOOL_INSET", null)
	pass
	
func _on_ButtonToolExtrude_Press():
	emit_signal("tool_action", "TOOL_EXTRUDE", null)
	pass	
	
func _on_ButtonToolRemove_Press():
	emit_signal("tool_action", "TOOL_REMOVE", null)
	pass	

	
func _update_gui():
	if (_mesh_creator == null):
		return
		
	if (has_node("ToolsList") == false):
		return
		
	# create buttons
	
	# mode buttons
	$ToolsList/ModesButtons/Button_ModeMesh.set_pressed(_mesh_creator.SelectionMode == _mesh_creator.SelectionModes.MESH)
	$ToolsList/ModesButtons/Button_ModeVertex.set_pressed(_mesh_creator.SelectionMode == _mesh_creator.SelectionModes.VERTEX)
	$ToolsList/ModesButtons/Button_ModeEdge.set_pressed(_mesh_creator.SelectionMode == _mesh_creator.SelectionModes.EDGE)
	$ToolsList/ModesButtons/Button_ModeFace.set_pressed(_mesh_creator.SelectionMode == _mesh_creator.SelectionModes.FACE)
	
	# tools
	
	pass
