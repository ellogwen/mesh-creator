tool
extends MeshInstance


var DEFAULT_MATERIAL = preload("res://addons/mesh_creator/materials/mc_default.material")

var ActiveEditorPlugin = null

var _mc_mesh: MeshCreator_Mesh_Mesh
func get_mc_mesh() -> MeshCreator_Mesh_Mesh:
	return _mc_mesh
	
func set_mc_mesh(mc_mesh: MeshCreator_Mesh_Mesh):
	_mc_mesh = mc_mesh


var _editorIndicator = null
var _editorHoverLabel = null
var _editorRadialMenu = null
	
func get_editor_plugin():
	return ActiveEditorPlugin

func _init():	
	if (Engine.is_editor_hint()):
		set_mc_mesh(MeshCreator_Mesh_Mesh.new())
		pass
	
func _ready():
	if (Engine.is_editor_hint()):
		var spatial = Spatial.new()
		spatial.name = "MC_Editor"
		add_child(spatial)
		spatial.set_owner(get_tree().get_edited_scene_root())
		
		_create_editor_indicator(spatial)
		_create_hover_label(spatial)		
		
		
	else:
		# remove editor helpers when running
		# the game
		if (has_node("MC_Editor")):
			var node = get_node("MC_Editor")
			remove_child(node)
			node.queue_free()	


func _create_editor_indicator(spatial) -> void:
	_editorIndicator = ImmediateGeometry.new()
	_editorIndicator.set_script(preload("res://addons/mesh_creator/MeshCreatorInstanceEditorIndicator.gd"))
	_editorIndicator.name = "MC_EditorIndicator"
	spatial.add_child(_editorIndicator)
	_editorIndicator.set_owner(get_tree().get_edited_scene_root())
	pass

func _create_hover_label(spatial) -> void:
	_editorHoverLabel = preload("res://addons/mesh_creator/ui/Label3D.tscn").instance()
	_editorHoverLabel.name = "MC_EditorHoverLabel"
	spatial.add_child(_editorHoverLabel)
	_editorHoverLabel.set_owner(get_tree().get_edited_scene_root())
	_editorHoverLabel.set_text("")		
	pass
	
func SetEditorPlugin(plugin):
	# disconecct
	if (ActiveEditorPlugin != null):
		pass
		
	# connect
	ActiveEditorPlugin = plugin
	if (ActiveEditorPlugin != null):
		ActiveEditorPlugin.connect("state_changed", self, "_on_editorplugin_state_changed")
		ActiveEditorPlugin.connect("mode_changed", self, "_on_editorplugin_mode_changed")
		
func _on_editorplugin_state_changed():	
	if (_editorIndicator != null):
		_editorIndicator.UpdateDraw()	
	pass	
	
func _on_editorplugin_mode_changed():		
	if (_editorIndicator != null):
		_editorIndicator.UpdateDraw()
	pass