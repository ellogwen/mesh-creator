tool
extends ImmediateGeometry

var MCI

func _ready():
	MCI = get_parent().get_parent() # parent = MC_Editor parent.parent = MeshCreatorInstance
	var indicator_material = SpatialMaterial.new()
	indicator_material.flags_unshaded = true
	indicator_material.flags_transparent = true
	indicator_material.vertex_color_use_as_albedo = true
	indicator_material.albedo_color = Color(1, 1, 1, 1)	
	set_material_override(indicator_material)

func UpdateDraw():
	if (Engine.is_editor_hint() == false):
		return
		
	# Clean up before drawing.
	clear()
	
	begin(Mesh.PRIMITIVE_LINES)	
	end()

	# Begin draw.
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# face centers
	if (MCI.get_editor_plugin().SelectionMode == 3):
		for face in MCI.get_editor_state().get_faces():
			_render_face_center(face)
	
	# selected faces
	var selectedFaces = MCI.get_editor_state().get_selected_faces()	
	for face in selectedFaces:
		_render_editor_selected_face(face)
		
	# fake lines
	if (MCI.get_editor_plugin().SelectionMode != 0):
		for face in MCI.get_editor_state().get_faces():
			_render_fake_line(face.A, face.B, face.Normal, ColorN("orange", 0.8))
			_render_fake_line(face.B, face.C, face.Normal, ColorN("orange", 0.8))
			_render_fake_line(face.C, face.D, face.Normal, ColorN("orange", 0.8))
			_render_fake_line(face.D, face.A, face.Normal, ColorN("orange", 0.8))
	
	# End drawing.
	end()
	
	print("indicator redrawed")

func _render_face_center(face):
	set_color(ColorN("black", 0.8))
	
	var centroid = face.get_centroid()	
	
	var Ap = (face.A - centroid).normalized()
	var Bp = (face.B - centroid).normalized()
	var Cp = (face.C - centroid).normalized()
	var Dp = (face.D - centroid).normalized()
	
	set_normal(face.Normal)	
	add_vertex(centroid + (Ap * 0.05) - (face.Normal * 0.0001))
	set_normal(face.Normal)	
	add_vertex(centroid + (Bp * 0.05) - (face.Normal * 0.0001))
	set_normal(face.Normal)	
	add_vertex(centroid + (Cp * 0.05) - (face.Normal * 0.0001))
	set_normal(face.Normal)	
	add_vertex(centroid + (Ap * 0.05) - (face.Normal * 0.0001))
	set_normal(face.Normal)	
	add_vertex(centroid + (Cp * 0.05) - (face.Normal * 0.0001))
	set_normal(face.Normal)
	add_vertex(centroid + (Dp * 0.05) - (face.Normal * 0.0001))
	
func _render_line(from, to, color):
	set_color(color)	
	add_vertex(from)
	add_vertex(to)	
	pass
	
func _render_fake_line(from, to, normal, color, thickness = 0.02):
	set_color(color)
		
	var up = (to - from).normalized()
	var left = normal.cross(up)
	
	var Ap = from - (normal * 0.005)
	var Bp = to - (normal * 0.005)
	var Cp = (to + (left * thickness)) - (normal * 0.0001)
	var Dp = (from + (left * thickness)) - (normal * 0.0001)
	
	set_normal(normal)
	add_vertex(Ap)
	set_normal(normal)
	add_vertex(Bp)
	set_normal(normal)
	add_vertex(Cp)
	set_normal(normal)
	add_vertex(Ap)
	set_normal(normal)
	add_vertex(Cp)
	set_normal(normal)
	add_vertex(Dp)	
	
	pass
	
func _render_editor_selected_face(face):	
	set_color(ColorN("green", 0.5))
	set_normal(face.Normal)
	set_uv(Vector2(0, 0))
	add_vertex(face.A - (face.Normal * 0.0001))
	
	set_color(ColorN("green", 0.5))
	set_normal(face.Normal)
	set_uv(Vector2(0, 0))
	add_vertex(face.B - (face.Normal * 0.0001))
	
	set_color(ColorN("green", 0.5))
	set_normal(face.Normal)
	set_uv(Vector2(0, 0))
	add_vertex(face.C - (face.Normal * 0.0001))
	
	set_color(ColorN("green", 0.5))
	set_normal(face.Normal)
	set_uv(Vector2(0, 0))
	add_vertex(face.A - (face.Normal * 0.0001))
	
	set_color(ColorN("green", 0.5))
	set_normal(face.Normal)
	set_uv(Vector2(0, 0))
	add_vertex(face.C - (face.Normal * 0.0001))
	
	set_color(ColorN("green", 0.5))
	set_normal(face.Normal)
	set_uv(Vector2(0, 0))
	add_vertex(face.D - (face.Normal * 0.0001))
	
	pass