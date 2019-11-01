# namespace MeshCreator_Mesh

class Edge:
	var A: Vector3
	var B: Vector3
	var Id: int = -1	
	var FacesMapping: Array = Array()
	
	func _init(a, b, id):
		A = a
		B = b
		Id = id
	
	func length():
		return (B - A).length()
		
	func matches(a, b, strict = false):
		if (strict):
			return (A == a and B == b)
		else:
			return ( (A == a and B == b) or (A == b and B == a) )