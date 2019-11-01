# namespace MeshCreator_Mesh
class_name MeshCreator_Mesh_Edge

var _a: Vector3
var _b: Vector3

func _init(a: Vector3, b: Vector3) -> void:
	_a = a
	_b = b	

func length() -> float:
	return (_b - _a).length()
	
func matches(a: Vector3, b: Vector3, strict: bool = false) -> bool:
	if (strict):
		return (_a == a and _b == b)
	else:
		return ( (_a == a and _b == b) or (_a == b and _b == a) )
		
func get_interpolated_point(factor: float) -> Vector3:
	return (_b - _a) * factor