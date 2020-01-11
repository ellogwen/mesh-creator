tool
extends Spatial

export (String) var Text = "" setget set_text

func _init():
	pass
	
func _ready():
	var mat = _create_gui_material()
	$RenderTarget.material_override = mat
	pass
	
func set_text(text: String) -> void:
	Text = text
	$RenderSource/Label.text = text
	
func _create_gui_material() -> SpatialMaterial:
	var mat = SpatialMaterial.new()
	var viewport = $RenderSource
	mat.flags_transparent = true
	mat.flags_unshaded = true
	mat.flags_no_depth_test = true
	mat.flags_do_not_receive_shadows = true
	mat.flags_disable_ambient_light = true
	mat.params_cull_mode = mat.CULL_FRONT
	
	var vpt = viewport.get_texture()
	vpt.flags = Texture.FLAG_FILTER
	mat.albedo_texture = vpt
	return mat