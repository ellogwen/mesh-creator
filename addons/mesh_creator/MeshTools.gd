class_name MeshCreator_MeshTools

var MeshCreatorInstance = preload("res://addons/mesh_creator/MeshCreatorInstance.gd")
#var MeshCreator_Mesh_Face = preload("res://addons/mesh_creator/mesh/face.class.gd").Face

#func CreateFace(A: Vector3, B: Vector3, C: Vector3, D: Vector3):
#	var face = MeshCreator_Mesh_Face.new()
#	face.set_points(A, B, C, D)	
#	return face	
	
#func FaceToVertices(var face) -> PoolVector3Array:
#	var points = PoolVector3Array()
#	points.push_back(face.A)
#	points.push_back(face.B)
#	points.push_back(face.D)
#	points.push_back(face.C)
#	points.push_back(face.D)
#	points.push_back(face.B)
#	return points
	
func CreateMeshFromFaces(facesArray, mesh = null, material = null):
	var arrays = Array()
	arrays.resize(Mesh.ARRAY_MAX)
	
	var normal_array = PoolVector3Array()
	var uv_array = PoolVector2Array()
	var vertex_array = PoolVector3Array()
	var index_array = PoolIntArray()
	var facesSize = facesArray.size()

	for i in range(0, facesSize):
		var face = facesArray[i]
		face.refresh()
		for tri in face.get_triangles():
			var edge_ab: float = tri.get_side_length(0)
			var edge_bc: float = tri.get_side_length(1)
			var edge_ca: float = tri.get_side_length(2)
			var centroid: Vector3 = tri.get_center()
			var N: Vector3 = tri.get_normal().abs()
			var Auv = Vector2.ZERO
			var Buv = Vector2.ZERO
			var Cuv = Vector2.ZERO
			if (N.x > N.y and N.x > N.z):
				Auv = Vector2(tri.get_a().z + 0.5, tri.get_a().y + 0.5)
				Buv = Vector2(tri.get_b().z + 0.5, tri.get_b().y + 0.5)	
				Cuv = Vector2(tri.get_c().z + 0.5, tri.get_c().y + 0.5)				
			elif (N.y > N.x and N.y > N.z):
				Auv = Vector2(tri.get_a().x + 0.5, tri.get_a().z + 0.5)
				Buv = Vector2(tri.get_b().x + 0.5, tri.get_b().z + 0.5)	
				Cuv = Vector2(tri.get_c().x + 0.5, tri.get_c().z + 0.5)				
			elif (N.z > N.x and N.z > N.y):
				Auv = Vector2(tri.get_a().x + 0.5, tri.get_a().y + 0.5)
				Buv = Vector2(tri.get_b().x + 0.5, tri.get_b().y + 0.5)	
				Cuv = Vector2(tri.get_c().x + 0.5, tri.get_c().y + 0.5)				
			uv_array.append(Auv)
			normal_array.append(tri.get_normal())
			vertex_array.append(tri.get_a())
			uv_array.append(Buv)
			normal_array.append(tri.get_normal())
			vertex_array.append(tri.get_b())
			uv_array.append(Cuv)
			normal_array.append(tri.get_normal())
			vertex_array.append(tri.get_c())			
			pass
		pass
		
	arrays[Mesh.ARRAY_VERTEX] = vertex_array
	arrays[Mesh.ARRAY_NORMAL] = normal_array
	arrays[Mesh.ARRAY_TEX_UV] = uv_array
	
	# empty mesh
	if (mesh != null):
		for s in range(mesh.get_surface_count()):
    		mesh.surface_remove(s)
	else:			
		mesh = ArrayMesh.new()
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	return mesh
	
func MeshGenerator_Cube():
	var cube = preload("res://addons/mesh_creator/MeshCreatorInstance.tscn").instance()
	var mat = cube.DEFAULT_MATERIAL
	
	# top
	var topFace = PoolVector3Array([
		Vector3(-0.5, 0.5, -0.5),
		Vector3(0.5, 0.5, -0.5), 
		Vector3(0.5, 0.5, 0.5), 
		Vector3(-0.5, 0.5, 0.5)
	])		
	
	# right	
	var rightFace = PoolVector3Array([
		Vector3(0.5, 0.5, 0.5),
		Vector3(0.5, 0.5, -0.5),
		Vector3(0.5, -0.5, -0.5),
		Vector3(0.5, -0.5, 0.5)
	])		
	
	# front	
	var frontFace = PoolVector3Array([
		Vector3(-0.5, 0.5, 0.5),
		Vector3(0.5, 0.5, 0.5),
		Vector3(0.5, -0.5, 0.5),
		Vector3(-0.5, -0.5, 0.5)
	])	
	
	# left	
	var leftFace = PoolVector3Array([
		Vector3(-0.5, -0.5, -0.5),
		Vector3(-0.5, 0.5, -0.5),
		Vector3(-0.5, 0.5, 0.5),
		Vector3(-0.5, -0.5, 0.5)
	])		
	
	# bottom	
	var bottomFace = PoolVector3Array([
		Vector3(0.5, -0.5, 0.5),
		Vector3(0.5, -0.5, -0.5),
		Vector3(-0.5, -0.5, -0.5),
		Vector3(-0.5, -0.5, 0.5)
	])	
		
	# back	
	var backFace = PoolVector3Array([
		Vector3(0.5, -0.5, -0.5),
		Vector3(0.5, 0.5, -0.5),
		Vector3(-0.5, 0.5, -0.5),
		Vector3(-0.5, -0.5, -0.5)
	])	
	
	cube.get_mc_mesh().add_face_from_points(topFace)
	cube.get_mc_mesh().add_face_from_points(frontFace)
	cube.get_mc_mesh().add_face_from_points(leftFace)
	cube.get_mc_mesh().add_face_from_points(rightFace)
	cube.get_mc_mesh().add_face_from_points(backFace)
	cube.get_mc_mesh().add_face_from_points(bottomFace)
	
	cube.mesh = CreateMeshFromFaces(cube.get_mc_mesh().get_faces(), null, mat)
	return cube
	