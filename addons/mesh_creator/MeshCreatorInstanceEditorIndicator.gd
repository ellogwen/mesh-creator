tool
extends ImmediateGeometry

var MCI

func _ready():
	MCI = get_parent().get_parent() # parent = MC_Editor parent.parent = MeshCreatorInstance
	var indicator_material = SpatialMaterial.new()
	indicator_material.flags_unshaded = true
	indicator_material.flags_transparent = true
	indicator_material.vertex_color_use_as_albedo = true
	indicator_material.albedo_color = Color(1, 1, 1, 0.5)
	set_material_override(indicator_material)

func UpdateDraw():
	if (Engine.is_editor_hint() == false):
		return
		
	# Clean up before drawing.
	clear()

	# Begin draw.
	begin(Mesh.PRIMITIVE_TRIANGLES)

	var selectedFaces = MCI.get_editor_state().get_selected_faces()	
	for face in selectedFaces:
		_render_editor_selected_face(face)
	
	# End drawing.
	end()
	
	print("indicator redrawed")
	
	
func _render_editor_selected_face(face):
	
	set_color(Color.green)
	set_normal(face.Normal)
	set_uv(Vector2(0, 0))
	add_vertex(face.A - (face.Normal * 0.005))
	
	set_color(Color.green)
	set_normal(face.Normal)
	set_uv(Vector2(0, 0))
	add_vertex(face.B - (face.Normal * 0.005))
	
	set_color(Color.green)
	set_normal(face.Normal)
	set_uv(Vector2(0, 0))
	add_vertex(face.C - (face.Normal * 0.005))
	
	set_color(Color.green)
	set_normal(face.Normal)
	set_uv(Vector2(0, 0))
	add_vertex(face.A - (face.Normal * 0.005))
	
	set_color(Color.green)
	set_normal(face.Normal)
	set_uv(Vector2(0, 0))
	add_vertex(face.C - (face.Normal * 0.005))
	
	set_color(Color.green)
	set_normal(face.Normal)
	set_uv(Vector2(0, 0))
	add_vertex(face.D - (face.Normal * 0.005))
	
	pass