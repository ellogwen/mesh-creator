# namspace MeshCreator_Mesh

class Face:
	var A: Vector3
	var B: Vector3
	var C: Vector3
	var D: Vector3
	var NormalABD: Vector3
	var NormalCDB: Vector3
	var Normal: Vector3	
	var Id: int = -1
	var EdgesMapping: Array = Array()
	
	func clone(newId = -1):
		var f = get_script().new()
		f.A = A
		f.B = B
		f.C = C
		f.D = D
		f.NormalABD = NormalABD
		f.NormalCDB = NormalCDB
		f.Normal = Normal
		f.Id = newId		
		return f
		
	func edge_length_a_b():
		return abs((B - A).length())
		
	func edge_length_b_c():
		return abs((C - D).length())
		
	func edge_length_c_d():
		return abs((D - C).length())
		
	func edge_length_d_a():
		return abs((D - A).length())
	
	func set_points(a, b, c, d):
		A = a
		B = b
		C = c
		D = d
		calc_normals()
		
	func set_point(index: int, p: Vector3):
		match (index):
			0: A = p
			1: B = p
			2: C = p
			3: D = p		
		calc_normals()
	
	func calc_normals():		
		NormalABD = get_triangle_normal(A, B, D)
		NormalCDB = get_triangle_normal(C, D, B)
		Normal = ((NormalABD + NormalCDB) * 0.5).normalized()
		pass
	
	func get_triangle_normal(p1, p2, p3):
		var u: Vector3 = (p2 - p1)
		var v: Vector3 = (p3 - p1)
		return Vector3(
			(u.y * v.z) - (u.z * v.y),
			(u.z * v.x) - (u.x * v.z),
			(u.x * v.y) - (u.y * v.x)
		).normalized()
		pass
		
	func get_centroid() -> Vector3:
		return 0.25 * (A + B + C + D)
		pass
		
	func HasVertex(vtx: Vector3):
		return (A == vtx or B == vtx or C == vtx or D == vtx)
		
	func GetVertexIndices(vtx: Vector3):
		var indices = PoolIntArray()		
		if A == vtx:
			indices.append(0)
		if B == vtx:
			indices.append(1)
		if C == vtx:
			indices.append(2)
		if D == vtx:
			indices.append(3)
			
		return indices
	
	func GetVertexByIndex(index: int):
		match(index):
			0: return A
			1: return B
			2: return C
			3: return D
		return null
		
	func Equals(face):
		return (
			(A == face.A or A == face.B or A == face.C or A == face.D)
			and
			(B == face.A or B == face.B or B == face.C or B == face.D)
			and
			(C == face.A or C == face.B or C == face.C or C == face.D)
			and
			(D == face.A or D == face.B or D == face.C or D == face.D)
		)