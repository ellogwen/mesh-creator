# namespace MeshCreator_Mesh
class_name MeshCreator_Mesh_Mesh
	
# typeof Array<MeshCreator_Mesh_Face>
var _faces: Array = Array()
func get_faces() -> Array: return _faces

# typeof Array<MeshCreator_Mesh_Edge>
var _edges: Array  = Array()	
func get_edges() -> Array: return _edges

# typeof Array<MeasCreator_Mesh_Vertex>
var _vertices: Array = Array()
func get_vertices() -> Array: return _vertices

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

func get_vertex(index: int):
	return _vertices[index]
	
func clear():
	_faces.clear()
	_edges.clear()
	_vertices.clear()
	_nextVerticesIndex = -1
	_nextFacesIndex = -1
	pass
	
func define_face_from_vertices(verts: Array) -> int:
	for vtx in verts:
		if (vtx.get_mesh_index() < 0):
			add_vertex(vtx)
	var f = MeshCreator_Mesh_Face.new(verts)	
	f.set_mesh_index(_nextFaceIdx())
	_faces.push_back(f)
	return f.get_mesh_index()
	
func add_face_from_points(pts: PoolVector3Array) -> int:
	var verts = Array()
	for pt in pts:
		verts.push_back(get_vertex(add_point(pt)))
	return define_face_from_vertices(verts)	
	
func add_vertex(vtx: MeshCreator_Mesh_Vertex) -> int:
	if (vtx.get_mesh_index() >= 0):
		print("[Mesh Creator] Add Vertex Warning. Vertex already indexed: Idx " + str(vtx.get_mesh_index()))
		return vtx.get_mesh_index()
	_vertices.push_back(vtx)
	vtx.set_mesh_index(_nextVertIdx())
	return vtx.get_mesh_index()
	
func add_point(pt: Vector3) -> int:
	var vtx = MeshCreator_Mesh_Vertex.new(pt)
	return add_vertex(vtx)
