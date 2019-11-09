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
	indicator_material.params_cull_mode = SpatialMaterial.CULL_DISABLED
	set_material_override(indicator_material)

func UpdateDraw():
	if (Engine.is_editor_hint() == false):
		return
		
	var activeTool = MCI.get_editor_plugin().get_gizmo_plugin().get_active_tool()	
	# selected faces
	# @todo erm... nope, this will surely be backfire 
	var selectedFaces = MCI.get_mc_mesh().get_faces_selection(MCI.get_editor_plugin().get_gizmo_plugin().get_mc_gizmo().get_face_selection_store().get_store())	
		
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
	
	# selected face indicator
	for face in selectedFaces:
		_render_editor_selected_face(face)
		if (activeTool != null):
			# inset indicator			
			if (activeTool.get_tool_name() == "FACE_INSET"):
				_render_face_inset_indicator(face, activeTool.get_inset_factor())
			# loopcut indicator			
			if (activeTool.get_tool_name() == "FACE_LOOPCUT"):
				_render_face_loopcut_indicator(face, activeTool)						
		
	# face edges
	if (MCI.get_editor_plugin().SelectionMode != 0):
		for face in MCI.get_mc_mesh().get_faces():
			var verts = face.get_vertices()
			var vertsCount = verts.size()
			for i in range(0, vertsCount):				
					_render_fake_line(verts[i].get_position(), verts[(i + 1) % vertsCount].get_position(), face.get_normal(), Color.black, 0.015)
					
	# general tool indicators
	if (activeTool != null):
		# translate indicator
		if (activeTool.get_tool_name() == "FACE_TRANSLATE"):
			_render_face_translate_indicator(activeTool)
	
	
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
	
func _render_face_inset_indicator(face, insetFactor):
	var newPts = PoolVector3Array()
	if insetFactor > 0.01 and insetFactor < 0.99:
		for vtx in face.get_vertices():
			newPts.push_back(vtx.get_position() + ((face.get_centroid() - vtx.get_position()) * insetFactor))

	var vtxCount = newPts.size()
	for i in range(0, vtxCount):
		_render_fake_line(
			(newPts[i]),
			(newPts[(i + 1) % vtxCount]),
			face.get_normal(),
			Color.blue,
			0.01
		)
	pass
	
func _render_face_loopcut_indicator(face, faceLoopcutTool):
	var startEdgeIndex = faceLoopcutTool.get_edge_index()
	var insetFactor = clamp(faceLoopcutTool.get_inset_factor(), 0.0001, 0.9999)
	var loopcutChain = MCI.get_mc_mesh().build_loopcut_chain(face.get_mesh_index(), startEdgeIndex)
	
	#if (loopcutChain.size() < 3):		
	#	return
		
	var endId = loopcutChain.back()	
	var inEdgeIndex = (startEdgeIndex + 2) % 4	
	for i in range(0, loopcutChain.size() - 1):		
		var outEdgeIndex = (inEdgeIndex + 2) % 4	
		var currFace = MCI.get_mc_mesh().get_face(loopcutChain[i])
		
		if (currFace.get_vertex_count() != 4):			
			return
		
		var inEdgeStartPos = currFace.get_edge_start(inEdgeIndex)
		var inEdgeEndPos = currFace.get_edge_end(inEdgeIndex)
		var inEdgeCutPosVec = (inEdgeEndPos - inEdgeStartPos)
		var inEdgeCutPos = inEdgeStartPos + (inEdgeCutPosVec.normalized() * (inEdgeCutPosVec.length() * insetFactor))
		
		var outEdgeStartPos = currFace.get_edge_start(outEdgeIndex)
		var outEdgeEndPos = currFace.get_edge_end(outEdgeIndex)
		var outEdgeCutPosVec = (outEdgeEndPos - outEdgeStartPos)		
		var outEdgeCutPos = outEdgeStartPos + (outEdgeCutPosVec.normalized() * (outEdgeCutPosVec.length() * (1 - insetFactor)))
		
		# draw line
		_render_fake_line(inEdgeCutPos, outEdgeCutPos, currFace.get_normal(), Color.blue, 0.015)
		
		var nextFace = MCI.get_mc_mesh().get_face(loopcutChain[i + 1])		
		
		if (loopcutChain[i +1] == endId):
			break;
			
		inEdgeIndex = nextFace.get_edge_index(outEdgeEndPos, outEdgeStartPos) # flip
		if (inEdgeIndex < 0):						
			return	
	
	pass
	
func _render_face_translate_indicator(faceTranslateTool):
	var from = faceTranslateTool.get_current_position()	
	var fwd = faceTranslateTool.get_axis_forward()
	var up = faceTranslateTool.get_axis_up()
	var right = faceTranslateTool.get_axis_right()
	var lineWidth = 0.1
	var centerOffset = Vector3.ZERO
	# forward axis	
	centerOffset = right * (lineWidth/2)
	_render_fake_line(from + centerOffset, (from + (fwd * 0.25)) + centerOffset, up, ColorN("blue", 0.9), 0.1)	
	_render_fake_line((from + (fwd * 0.25)) + centerOffset, from + centerOffset, -up, ColorN("blue", 0.9), 0.1)
	# up axis
	centerOffset = -right * (lineWidth/2)
	_render_fake_line(from + centerOffset, from + (-up * 0.25) + centerOffset, -fwd, ColorN("green", 0.9), 0.1)
	_render_fake_line(from + (-up * 0.25) + centerOffset, from + centerOffset, fwd, ColorN("green", 0.9), 0.1)
	# right axis
	centerOffset = -up * (lineWidth/2)
	_render_fake_line(from + centerOffset, from + (right * 0.25) + centerOffset, -fwd, ColorN("red", 0.9), 0.1)
	_render_fake_line(from + (right * 0.25) + centerOffset, from + centerOffset, fwd, ColorN("red", 0.9), 0.1)
	pass