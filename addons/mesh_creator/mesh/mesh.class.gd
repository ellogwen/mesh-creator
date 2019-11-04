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