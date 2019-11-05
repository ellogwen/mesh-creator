tool
extends Container

var _generator

func load_ui(generator: MeshCreator_Generators_MeshGeneratorBase):
	_generator = generator
	var fields = _generator.get_config()
	for i in range(0, fields.size()):
		var field = fields[i]
		match (field.type):
			"int": _create_attach_int_field(i, field.label, field.minValue, field.maxValue, field.default)
		pass
	pass
	
	var createButton = Button.new()
	createButton.name = "Create"
	createButton.set_text("Create")
	createButton.connect("pressed", self, "_on_ButtonCreate_pressed")
	add_child(createButton)
	
func _create_attach_int_field(configIndex, label, minVal, maxVal, defaultVal):
	var labelInput = Label.new()
	labelInput.name = "label_" + str(configIndex)
	labelInput.set_text(label)
	add_child(labelInput)
	
	var input = SpinBox.new()
	input.name = "input_" + str(configIndex)
	input.set_min(minVal)
	input.set_max(maxVal)
	input.set_step(1)
	input.set_value(defaultVal)
	input.connect("value_changed", self, "_on_input_change", [configIndex])
	add_child(input)
	pass
	
func _on_ButtonCreate_pressed():
	MeshCreator_Signals.emit_UI_GENERATOR_GENERATE_MESH(_generator)
	pass
	
func _on_input_change(value, inputId):
	_generator.set_config_value(inputId, value)	
	pass