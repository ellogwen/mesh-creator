# namespace MeshCreator_Mesh
class_name MeshCreator_Mesh_Mesh
	
# typeof Array<MeshCreator_Mesh_Face>
var _faces: Array = Array()
func get_face(index: int): return _faces[index]
func get_faces() -> Array: return _faces
func get_faces_selection(faceIds: Array) -> Array:
	var faces = Array()
	for fId in faceIds:
		faces.push_back(get_face(fId))
	return faces

# typeof Array<MeshCreator_Mesh_Edge>
var _edges: Array  = Array()	
func get_edges() -> Array: return _edges

# typeof Array<MeasCreator_Mesh_Vertex>
var _vertices: Array = Array()
func get_vertex(index: int): return _vertices[index]
func get_vertices() -> Array: return _vertices
func get_vertices_selection(vtxIds: Array) -> Array:
	var verts = Array()
	for vId in vtxIds:
		verts.push_back(get_vertex(vId))
	return verts

var _nextVerticesIndex = -1
func _nextVertIdx() -> int:
	_nextVerticesIndex += 1
	return _nextVerticesIndex

var _nextFacesIndex = 0
func _nextFaceIdx() -> int:
	_nextFacesIndex += 1
	return _nextFacesIndex
	
func _init():
	clear()		
	pass
	
func clear():
	_faces.clear()
	_edges.clear()
	_vertices.clear()
	_nextVerticesIndex = -1
	_nextFacesIndex = -1	
	pass
	
func define_face_from_vertices(verts: Array) -> int:
	var realVerts = Array()
	for vtx in verts:
		var realVtx = vtx
		if (vtx.get_mesh_index() < 0):
			realVtx = add_vertex(vtx)
		realVerts.push_back(realVtx)
	var f = MeshCreator_Mesh_Face.new(realVerts)	
	f.set_mesh_index(_nextFaceIdx())
	_faces.push_back(f)
	return f.get_mesh_index()
	
func add_face_from_points(pts: PoolVector3Array, independentVerts = false) -> int:
	var verts = Array()
	for pt in pts:
		verts.push_back(get_vertex(add_point(pt, independentVerts).get_mesh_index()))
	return define_face_from_vertices(verts)	
	
func add_vertex(vtx: MeshCreator_Mesh_Vertex, independentVerts = false) -> MeshCreator_Mesh_Vertex:
	if (vtx.get_mesh_index() >= 0):
		print("[Mesh Creator] Add Vertex Warning. Vertex already indexed: Idx " + str(vtx.get_mesh_index()))		
		return get_vertex(vtx.get_mesh_index())
	# find duplicate is this the right way? @todo find a good solution for linked vertices
	if (independentVerts == false):
		for v in _vertices:
			if v.equals_position(vtx):
				vtx.set_mesh_index(v.get_mesh_index())			
				return get_vertex(v.get_mesh_index())
	_vertices.push_back(vtx)
	vtx.set_mesh_index(_nextVertIdx())
	return vtx

	
func add_point(pt: Vector3, independetVerts = false) -> MeshCreator_Mesh_Vertex:
	var vtx = MeshCreator_Mesh_Vertex.new(pt)
	return add_vertex(vtx, independetVerts)
	
func translate_vertex(vertexId: int, offset: Vector3):
	var vtx = get_vertex(vertexId)
	if (vtx != null):
		vtx.set_position(vtx.get_position() + offset)
	pass
	
# does this work and leave a gap?
func remove_face(faceId: int):	
	# reindex
	for i in range(faceId + 1, _faces.size()):
		var face = _faces[i]
		face.set_mesh_index(face.get_mesh_index() - 1)
	# remove
	_faces.remove(faceId)

# @todo does this only work with convex faces?		
func extrude_face(faceId: int):
	var face = get_face(faceId)
	var faceNewPts = Array()
	var faceVerts = face.get_vertices()
	var faceVertsCount = faceVerts.size()
	var centroid = face.get_centroid()
	
	for n in range(0, faceVertsCount):
		var vtx = face.get_vertex(n)
		faceNewPts.push_back(vtx.get_position() - (face.get_normal() * 0.25))
		
	# create N new faces (quads)
	for n in range(0, faceVertsCount):
		var a = faceVerts[n].get_position()
		var d = faceNewPts[n]
		var b
		var c			
		if (n + 1 >= faceVertsCount):
			b = faceVerts[0].get_position()
			c = faceNewPts[0]
		else:
			b = faceVerts[n + 1].get_position()
			c = faceNewPts[n + 1]
		
		add_face_from_points(PoolVector3Array([a, b, c, d]))			
		pass
	
	# overwrite existing verts and define new
	# introduce new verts
	var newVerts = Array()
	for pt in faceNewPts:
		newVerts.push_back(add_point(pt))
	face.from_verts(newVerts)
	
	face.refresh() # this makes sure triangulation is done		
	pass
	
# @todo does this only work with convex faces?		
func inset_face(faceId: int):
	var face = get_face(faceId)
	var faceNewPts = Array()
	var faceVerts = face.get_vertices()
	var faceVertsCount = faceVerts.size()
	var centroid = face.get_centroid()
	
	for n in range(0, faceVertsCount):
		var vtx = face.get_vertex(n)
		faceNewPts.push_back(vtx.get_position() + ((centroid - vtx.get_position()) * 0.25))
		
	# create N new faces (quads)
	for n in range(0, faceVertsCount):
		var a = faceVerts[n].get_position()
		var d = faceNewPts[n]
		var b
		var c			
		if (n + 1 >= faceVertsCount):
			b = faceVerts[0].get_position()
			c = faceNewPts[0]
		else:
			b = faceVerts[n + 1].get_position()
			c = faceNewPts[n + 1]
		
		add_face_from_points(PoolVector3Array([a, b, c, d]))			
		pass
	
	# overwrite existing verts and define new
	# introduce new verts
	var newVerts = Array()
	for pt in faceNewPts:
		newVerts.push_back(add_point(pt))
	face.from_verts(newVerts)
		
	face.refresh() # this makes sure triangulation is done		
	pass