tool
extends WindowDialog

var settings_panel_prefab = preload("res://addons/mesh_creator/generators/generator_ui_panel.tscn")

onready var settings_panel = $HBoxContainer/GeneratorSettings
onready var preview_model = $HBoxContainer/VBoxContainer/ModelPreview/Viewport/PreviewModel

var settings = null
func on_type_select(type_string):
	if (settings != null):
		settings_panel.remove_child(settings)
		settings.queue_free()
		
	settings = settings_panel_prefab.instance()
	settings.show_create_button = false
	settings.name = "Generator_Panel"
	settings.connect("input_changed", self, "on_settings_input_changed")
	settings.load_ui(MeshCreator_Generators_BoxMeshGenerator.new())
	settings_panel.add_child(settings)
	pass
	
func on_settings_input_changed():
	if (settings == null):
		return
	var generator = settings.get_generator()
	if ((generator as MeshCreator_Generators_MeshGeneratorBase).is_valid()):
		var mt = MeshCreator_MeshTools.new()
		var mesh = generator.generate(generator.get_config())
		preview_model.mesh = mt.CreateArrayMeshFromMeshCreatorMeshFaces(mesh.get_faces(), null, null)
	pass

func on_create_button_pressed():
	if (settings == null):
		return
		
	var generator = settings.get_generator()
	if ((generator as MeshCreator_Generators_MeshGeneratorBase).is_valid()):
		MeshCreator_Signals.emit_UI_GENERATOR_GENERATE_MESH(generator)
		hide()
	pass
