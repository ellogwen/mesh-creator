# namspace MeshCreator_Mesh
class_name MeshCreator_Mesh_Face

# typeof Array<MeshCreator_Mesh_Triangle>
var _tris: Array = Array() 
# typeof Array<MeshCreator_Mesh_Vertex>
var _vertices: Array = Array()

var _normal: Vector3
var _centroid: Vector3 = Vector3.ZERO
var _meshIndex: int = -1

func _init(verts: Array = Array()) -> void:	
	for v in verts:
		_vertices.push_back(v)
	_triangulate()
	_calc_normal()
	_calc_centroid()
	pass	
	
func get_normal() -> Vector3: return _normal
func get_centroid() -> Vector3:	return _centroid
	
func get_mesh_index() -> int:
	return _meshIndex
	pass
	
func set_mesh_index(idx: int) -> void:
	_meshIndex = idx
	pass	

func from_points(points: PoolVector3Array) -> void:
	_vertices.clear()
	for pt in points:		
		_vertices.push_back(MeshCreator_Mesh_Vertex.new(pt))	
	_triangulate()
	_calc_normal()
	_calc_centroid()
	
func get_triangles() -> Array:
	return _tris

# @todo this does only work with convex!
func _triangulate() -> bool:	
	var vertCount = _vertices.size()
	if (vertCount < 3):
		return false
	_tris.clear()
	for i in range(2, vertCount):
		var c = _vertices[i].get_position()
		var b = _vertices[i - 1].get_position()
		var a = _vertices[0].get_position()
		var tri = MeshCreator_Mesh_Triangle.new(a, b, c)
		_tris.push_back(tri)
	return true
		
func _calc_normal() -> void:
	var trisCount = _tris.size()				
	if (trisCount < 1):
		return
		
	_normal = Vector3.ZERO
	for tri in _tris:
		_normal += tri.get_normal()
	_normal /= trisCount
	_normal = _normal.normalized()
	pass
	
func _calc_centroid() -> void:
	var vertCount = _vertices.size()
	if (vertCount < 3):
		return
		
	var vecSum = Vector3.ZERO
	for v in _vertices:
		vecSum += v.get_position()
	
	_centroid = vecSum / vertCount
	pass

func set_point_at_index(index: int, p: Vector3) -> void:	
	_vertices[index].set_position(p)
	_triangulate()
	_calc_normal()
	_calc_centroid()

func get_edge(fromIndex: int) -> MeshCreator_Mesh_Edge:
	var vertCount = _vertices.size()
	if (fromIndex < 0):
		return null
	if (fromIndex >= vertCount):
		return null
		
	var toIndex = fromIndex + 1
	if (fromIndex == vertCount - 1):
		toIndex = 0
		
	var a = _vertices[fromIndex].get_position()
	var b = _vertices[toIndex].get_position()
	
	return MeshCreator_Mesh_Edge.new(a, b)

func get_edge_length(fromIndex: int) -> float:
	var vertCount = _vertices.size()
	if (fromIndex < 0):
		return 0.0
	if (fromIndex >= vertCount):
		return 0.0
		
	var toIndex = fromIndex + 1
	if (fromIndex == vertCount - 1):
		toIndex = 0
		
	var a = _vertices[fromIndex].get_position()
	var b = _vertices[toIndex].get_position()
	
	return (b - a).length()

func get_vertex(index: int) -> MeshCreator_Mesh_Vertex:
	return _vertices[index]
	
func get_vertices() -> Array:
	return _vertices

func has_vertex(vertex: MeshCreator_Mesh_Vertex) -> bool:
	return has_vertex_position(vertex.get_position())
	
func has_vertex_position(position: Vector3) -> bool:	
	for v in _vertices:
		if (position == v.get_position()):
			return true
	return false

func get_vertex_index(position: Vector3) -> int:
	for i in range(0, _vertices.size()):
		if _vertices[i].get_position() == position:
			return i
	return -1

func equals(otherFace: MeshCreator_Mesh_Face) -> bool:
	for vtx in otherFace.get_vertices():
		if (has_vertex(vtx) == false):
			return false
	return true

func clone(newId = -1) -> MeshCreator_Mesh_Face:
	var pts = PoolVector3Array()
	for vtx in _vertices.size():
		pts.push_back(vtx.get_position())
	var f = get_script().new(pts)	
	return f