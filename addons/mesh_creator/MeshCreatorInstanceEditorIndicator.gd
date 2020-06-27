tool
extends ImmediateGeometry

var MCI

var indicator_material: SpatialMaterial

func _ready():
	MCI = get_parent().get_parent() # parent = MC_Editor parent.parent = MeshCreatorInstance
	indicator_material = SpatialMaterial.new()
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
	var selectedEdges = MCI.get_mc_mesh().get_edges_selection(MCI.get_editor_plugin().get_gizmo_plugin().get_mc_gizmo().get_edge_selection_store().get_store())
	var selectedVertices = MCI.get_mc_mesh().get_vertices_selection(MCI.get_editor_plugin().get_gizmo_plugin().get_mc_gizmo().get_vertex_selection_store().get_store())
		
	# Clean up before drawing.
	MCI.mesh.surface_get_material(0).albedo_color = Color(1, 1, 1, 1)
	clear()
	
		
	# line geometry
	begin(Mesh.PRIMITIVE_LINES)

	for line in MeshCreator_Indicator.get_lines():
		_render_line(line.from, line.to, line.color)

	end()


	# triangle geometry
	begin(Mesh.PRIMITIVE_TRIANGLES)		
				
	
	# face mode indicators
	if (MCI.get_editor_plugin().SelectionMode == 3):		
		# tint mesh when in selection mode		
		MCI.mesh.surface_get_material(0).albedo_color = Color(0.7, 0.7, 0.7, 1)			

		# face centers
		for face in MCI.get_mc_mesh().get_faces():
			_render_face_center(face)	
		# selected faces
		for face in selectedFaces:
			_render_editor_selected_face(face)
			if (activeTool != null):
				# inset indicator			
				if (activeTool.get_tool_name() == "FACE_INSET"):
					_render_face_inset_indicator(face, activeTool.get_inset_factor())

				# loopcut indicator			
				if (activeTool.get_tool_name() == "FACE_LOOPCUT"):
					_render_face_loopcut_indicator(face, activeTool)						
		
	# face edges in edge/vertex mode
	if (MCI.get_editor_plugin().SelectionMode == 2 or MCI.get_editor_plugin().SelectionMode == 1):
		for face in MCI.get_mc_mesh().get_faces():
			for edgeId in face.get_edges():
					var edge = MCI.get_mc_mesh().get_edge(edgeId)
					if (selectedEdges.has(edge)):
						_render_fake_line(
							edge.get_a().get_position(), 
							edge.get_b().get_position(), 
							face.get_normal(), 
							Color.yellow, 
							0.015,
							1
						)						
					else:
						_render_fake_line(
							edge.get_a().get_position(), 
							edge.get_b().get_position(), 
							face.get_normal(), 
							Color.black, 
							0.015,
							1
						)
					pass
						
	# face edges in face mode				
	if (MCI.get_editor_plugin().SelectionMode == 3):
		for face in MCI.get_mc_mesh().get_faces():
			var verts = face.get_vertices()
			var vertsCount = verts.size()
			for i in range(0, vertsCount):				
					_render_fake_line(
						verts[i].get_position(), 
						verts[(i + 1) % vertsCount].get_position(), 
						face.get_normal(), 
						Color.black, 
						0.0075,
						1
					)
					
	# vertex mode indicators
	if (MCI.get_editor_plugin().SelectionMode == 1):
		# vertices
		for face in MCI.get_mc_mesh().get_faces():
			for i in range(0, face.get_vertex_count()):
				var vtx = face.get_vertex(i)
				var start = face.get_edge_start(i)
				var end = face.get_edge_end(i)
				var color = Color.black
				if selectedVertices.has(vtx):
					color = Color.yellow
				_render_fake_line(
					start,
					start + (end - start).normalized() * 0.05,
					face.get_normal(),
					color,
					0.05,
					1
				)		
					
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
	
# anchors: 0 = center, 1 = left, 2 = right
func _render_fake_line(from, to, normal, color, thickness = 0.02, anchor = 0):
	set_color(color)
		
	var fwd = (to - from).normalized()
	var up = normal
	var left = up.cross(fwd)
	
	var Ap = (to - (left * (thickness / 2))) - (normal * 0.0001)
	var Bp = (to + (left * (thickness / 2))) - (normal * 0.0001)
	var Cp = (from + (left * (thickness / 2))) - (normal * 0.0001)	
	var Dp = (from - (left * (thickness / 2))) - (normal * 0.0001)
	
	if anchor == 1:
		Ap = Ap + (left * (thickness / 2))
		Bp = Bp + (left * (thickness / 2))
		Cp = Cp + (left * (thickness / 2))
		Dp = Dp + (left * (thickness / 2))
		
	if anchor == 2:
		Ap = Ap - (left * (thickness / 2))
		Bp = Bp - (left * (thickness / 2))
		Cp = Cp - (left * (thickness / 2))
		Dp = Dp - (left * (thickness / 2))		
	
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
	# right axis	
	_render_fake_line(from, from + (right * 0.25), -fwd, ColorN("red", 0.9), 0.1)	
	# up axis	
	_render_fake_line(from, from + (up * 0.25), -fwd, ColorN("green", 0.9), 0.1)	
	# forward axis		
	_render_fake_line(from, (from + (fwd * 0.25)), -up, ColorN("blue", 0.9), 0.1)		
	pass