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
	_setup_generators()
	_connect_signals()
	
func _connect_signals():
	$Scroll/ToolsList/GenerateButtons/Button_CreateCube.connect("pressed", self, "_on_ButtonCreateCube_pressed")
	$Scroll/ToolsList/GenerateButtons/Button_OpenGenerators.connect("pressed", self, "_on_ButtonOpenGenerators_pressed")
	$Scroll/ToolsList/ModesButtons/Button_ModeMesh.connect("toggled", self, "_on_ButtonModeMesh_Toggle")
	$Scroll/ToolsList/ModesButtons/Button_ModeVertex.connect("toggled", self, "_on_ButtonModeVertex_Toggle")
	$Scroll/ToolsList/ModesButtons/Button_ModeEdge.connect("toggled", self, "_on_ButtonModeEdge_Toggle")
	$Scroll/ToolsList/ModesButtons/Button_ModeFace.connect("toggled", self, "_on_ButtonModeFace_Toggle")
	
	$Scroll/ToolsList/ToolsButtons/Button_ToolSelect.connect("pressed", self, "_on_ButtonToolSelect_Press")
	$Scroll/ToolsList/ToolsButtons/Button_ToolMove.connect("pressed", self, "_on_ButtonToolMove_Press")
	$Scroll/ToolsList/ToolsButtons/Button_ToolScale.connect("pressed", self, "_on_ButtonToolScale_Press")
	$Scroll/ToolsList/ToolsButtons/Button_ToolExtrude.connect("pressed", self, "_on_ButtonToolExtrude_Press")
	$Scroll/ToolsList/ToolsButtons/Button_ToolInset.connect("pressed", self, "_on_ButtonToolInset_Press")
	$Scroll/ToolsList/ToolsButtons/Button_ToolRemove.connect("pressed", self, "_on_ButtonToolRemove_Press")
	$Scroll/ToolsList/ToolsButtons/Button_ToolLoopcut.connect("pressed", self, "_on_ButtonToolLoopcut_Press")
	pass

func _setup_generators():
	var genOptions: OptionButton = $Scroll/ToolsList/Generators/OptionButton
	genOptions.clear()
	genOptions.add_item("Select", 0)
	genOptions.add_item("Box", 1)
	if not genOptions.is_connected("item_selected", self, "_on_Generatos_Select"):
		genOptions.connect("item_selected", self, "_on_Generators_Select")
	pass


# @todo make this better and reload each panel and just attach remove
func _on_Generators_Select(selectionIndex):
	print("switching generator to: " + str(selectionIndex))
	# remove existing panel
	var existingPanel = $Scroll/ToolsList/Generators.get_node_or_null("Generator_Panel")
	if existingPanel != null:
		$Scroll/ToolsList/Generators.remove_child(existingPanel)
		existingPanel.queue_free()
			
	# create new panel
	if selectionIndex == 1:
		# box generator
		var panel = preload("res://addons/mesh_creator/generators/generator_ui_panel.tscn").instance()
		panel.load_ui(MeshCreator_Generators_BoxMeshGenerator.new())
		panel.name = "Generator_Panel"		
		$Scroll/ToolsList/Generators.add_child(panel)
	pass

func _on_CreatorModeChanged():
	_update_gui()
	pass

func _on_ButtonCreateCube_pressed():
	emit_signal("button_create_new_mesh")
	pass
	
var generators_window = null
func _on_ButtonOpenGenerators_pressed():
	if (generators_window == null):
		generators_window = preload("res://addons/mesh_creator/generators/GeneratorWindow.tscn").instance()
		add_child(generators_window)
		
	(generators_window as WindowDialog).popup_centered()
	(generators_window as WindowDialog).set_as_minsize()
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
	
func _on_ButtonToolScale_Press():
	emit_signal("tool_action", "TOOL_SCALE", null)
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
	
func _on_ButtonToolLoopcut_Press():
	emit_signal("tool_action", "TOOL_LOOPCUT", null)
	pass	

	
func _update_gui():
	if (_mesh_creator == null):
		return
		
	if (has_node("Scroll/ToolsList") == false):
		return
		
	# create buttons
	
	# mode buttons
	$Scroll/ToolsList/ModesButtons/Button_ModeMesh.set_pressed(_mesh_creator.SelectionMode == _mesh_creator.SelectionModes.MESH)
	$Scroll/ToolsList/ModesButtons/Button_ModeVertex.set_pressed(_mesh_creator.SelectionMode == _mesh_creator.SelectionModes.VERTEX)
	$Scroll/ToolsList/ModesButtons/Button_ModeEdge.set_pressed(_mesh_creator.SelectionMode == _mesh_creator.SelectionModes.EDGE)
	$Scroll/ToolsList/ModesButtons/Button_ModeFace.set_pressed(_mesh_creator.SelectionMode == _mesh_creator.SelectionModes.FACE)
	
	# tools
	
	pass
