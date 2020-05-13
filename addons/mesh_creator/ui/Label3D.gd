tool
extends MeshCreator_UI_Gui3D

export (String) var Text = "" setget set_text
	
func set_text(text: String) -> void:
	Text = text
	$RenderSource/Label.text = text
