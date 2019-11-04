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
		for face in MCI.get_mc_mesh().get_faces():
			_render_face_center(face)
	
	# selected faces
	# @todo erm... nope, this will surely be backfire 
	var selectedFaces = MCI.get_mc_mesh().get_faces_selection(MCI.get_editor_plugin().get_gizmo_plugin().get_mc_gizmo().get_face_selection_store().get_store())	
	for face in selectedFaces:
		_render_editor_selected_face(face)
		
	# fake lines
	if (MCI.get_editor_plugin().SelectionMode != 0):
		for face in MCI.get_mc_mesh().get_faces():
			var verts = face.get_vertices()
			var vertsCount = verts.size()
			for i in range(0, vertsCount):
				if (i == vertsCount - 1):
					_render_fake_line(verts[i].get_position(), verts[0].get_position(), face.get_normal(), ColorN("blue", 0.9))
				else:
					_render_fake_line(verts[i].get_position(), verts[i+1].get_position(), face.get_normal(), ColorN("blue", 0.9))
					
	
	# End drawing.
	end()
	
	print("indicator redrawed")

func _render_face_center(face):
	set_color(ColorN("black", 0.8))
	
	var centroid = face.get_centroid()	
	
	for tri in face.get_triangles():
		var Ap = (tri.get_a() - centroid).normalized()
		var Bp = (tri.get_b() - centroid).normalized()
		var Cp = (tri.get_c() - centroid).normalized()		
	
		set_normal(tri.get_normal())
		add_vertex(centroid + (Ap * 0.05) - (tri.get_normal() * 0.0001))
		set_normal(tri.get_normal())
		add_vertex(centroid + (Bp * 0.05) - (tri.get_normal() * 0.0001))
		set_normal(tri.get_normal())
		add_vertex(centroid + (Cp * 0.05) - (tri.get_normal() * 0.0001))
	
	
	
func _render_line(from, to, color):
	set_color(color)	
	add_vertex(from)
	add_vertex(to)	
	pass
	
func _render_fake_line(from, to, normal, color, thickness = 0.02):
	set_color(color)
		
	var fwd = (to - from).normalized()
	var up = normal
	var left = up.cross(fwd)
	
	var Ap = from - (normal * 0.0001)
	var Bp = to - (normal * 0.0001)
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
	for tri in face.get_triangles():		
		set_color(ColorN("green", 0.5))
		set_normal(tri.get_normal())
		set_uv(Vector2(0, 0))
		add_vertex(tri.get_a() - (tri.get_normal() * 0.0001))
		
		set_color(ColorN("green", 0.5))
		set_normal(tri.get_normal())
		set_uv(Vector2(0, 0))
		add_vertex(tri.get_b() - (tri.get_normal() * 0.0001))
		
		set_color(ColorN("green", 0.5))
		set_normal(tri.get_normal())
		set_uv(Vector2(0, 0))
		add_vertex(tri.get_c() - (tri.get_normal() * 0.0001))
	
	pass