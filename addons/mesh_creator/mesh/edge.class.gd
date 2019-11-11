# namespace MeshCreator_Mesh
class_name MeshCreator_Mesh_Edge

var _a: MeshCreator_Mesh_Vertex
var _b: MeshCreator_Mesh_Vertex
var _meshIndex = -1

func _init(a: MeshCreator_Mesh_Vertex, b: MeshCreator_Mesh_Vertex) -> void:
	_a = a
	_b = b	
	_meshIndex = -1
	
func get_mesh_index() -> int:
	return _meshIndex
	pass
	
func get_a() -> MeshCreator_Mesh_Vertex:
	return _a
	
func get_b() -> MeshCreator_Mesh_Vertex:
	return _b
	
func set_mesh_index(idx: int) -> void:
	_meshIndex = idx
	pass

func length() -> float:
	return (_b.get_position() - _a.get_position()).length()
	
func matches(a: Vector3, b: Vector3, strict: bool = false) -> bool:
	if (strict):
		return (_a.get_position() == a and _b.get_position() == b)
	else:
		return ( (_a.get_position() == a and _b.get_position() == b) or (_a.get_position() == b and _b.get_position() == a) )