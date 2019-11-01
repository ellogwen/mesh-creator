tool
extends MeshInstance

var DEFAULT_MATERIAL = preload("res://addons/mesh_creator/materials/mc_default.material")
var MeshInstanceEditorState = preload("res://addons/mesh_creator/MeshCreatorInstanceEditorState.gd")

var ActiveEditorPlugin = null

var _editorIndicator = null
var _editorState: MeshCreatorInstanceEditorState = null

func get_editor_state() -> MeshCreatorInstanceEditorState:
	return _editorState
	
func get_editor_plugin():
	return ActiveEditorPlugin

func _init():	
	if (Engine.is_editor_hint()):
		_editorState = MeshCreatorInstanceEditorState.new()
		_editorState.connect("STATE_CHANGED", self, "_on_editor_state_changed")
	
func _ready():
	if (Engine.is_editor_hint()):
		var spatial = Spatial.new()
		spatial.name = "MC_Editor"
		add_child(spatial)
		spatial.set_owner(get_tree().get_edited_scene_root())
		_editorIndicator = ImmediateGeometry.new()
		_editorIndicator.set_script(preload("res://addons/mesh_creator/MeshCreatorInstanceEditorIndicator.gd"))
		_editorIndicator.name = "MC_EditorIndicator"
		spatial.add_child(_editorIndicator)
		_editorIndicator.set_owner(get_tree().get_edited_scene_root())		
	else:
		# remove editor helpers when running
		# the game
		if (has_node("MC_Editor")):
			var node = get_node("MC_Editor")
			remove_child(node)
			node.queue_free()
	
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
	pass	
	
func _on_editorplugin_mode_changed():		
	if (_editorIndicator != null):
		_editorIndicator.UpdateDraw()
	pass	
	
func GetFacesWithVertex(vtx: Vector3):
	var faces = get_editor_state().get_faces()
	var result = Array()
	for i in range(0, faces.size()):
		if (faces[i].HasVertex(vtx)):
			result.push_back(faces[i])
	return result
	
func _on_editor_state_changed():
	if (_editorIndicator != null):
		_editorIndicator.UpdateDraw()
	pass
	


