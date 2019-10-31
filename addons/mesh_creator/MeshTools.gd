extends Node

var MeshCreatorInstance = preload("res://addons/mesh_creator/MeshCreatorInstance.gd")

func CreateFace(A: Vector3, B: Vector3, C: Vector3, D: Vector3):
	var face = MeshCreatorInstance.Face.new()
	face.set_points(A, B, C, D)	
	return face	
	
func FaceToVertices(var face) -> PoolVector3Array:
	var points = PoolVector3Array()
	points.push_back(face.A)
	points.push_back(face.B)
	points.push_back(face.D)
	points.push_back(face.C)
	points.push_back(face.D)
	points.push_back(face.B)
	return points
	
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
		var edge_ab = face.edge_length_a_b()
		var edge_bc = face.edge_length_b_c()
		var edge_cd = face.edge_length_c_d()
		var edge_da = face.edge_length_d_a()
		
		var centroid = face.get_centroid()
		
		var N = face.Normal.abs()
		var Auv = Vector2.ZERO
		var Buv = Vector2.ZERO
		var Cuv = Vector2.ZERO
		var Duv = Vector2.ZERO
		
		if (N.x > N.y and N.x > N.z):
			Auv = Vector2(face.A.z + 0.5, face.A.y + 0.5)
			Buv = Vector2(face.B.z + 0.5, face.B.y + 0.5)	
			Cuv = Vector2(face.C.z + 0.5, face.C.y + 0.5)
			Duv = Vector2(face.D.z + 0.5, face.D.y + 0.5)
		elif (N.y > N.x and N.y > N.z):
			Auv = Vector2(face.A.x + 0.5, face.A.z + 0.5)
			Buv = Vector2(face.B.x + 0.5, face.B.z + 0.5)	
			Cuv = Vector2(face.C.x + 0.5, face.C.z + 0.5)
			Duv = Vector2(face.D.x + 0.5, face.D.z + 0.5)
		elif (N.z > N.x and N.z > N.y):
			Auv = Vector2(face.A.x + 0.5, face.A.y + 0.5)
			Buv = Vector2(face.B.x + 0.5, face.B.y + 0.5)	
			Cuv = Vector2(face.C.x + 0.5, face.C.y + 0.5)
			Duv = Vector2(face.D.x + 0.5, face.D.y + 0.5)
				
		uv_array.append(Auv)
		normal_array.append(face.Normal)
		vertex_array.append(face.A)
		uv_array.append(Buv)
		normal_array.append(face.Normal)
		vertex_array.append(face.B)
		uv_array.append(Cuv)
		normal_array.append(face.Normal)
		vertex_array.append(face.C)
		
		uv_array.append(Auv)
		normal_array.append(face.Normal)
		vertex_array.append(face.A)
		uv_array.append(Cuv)
		normal_array.append(face.Normal)
		vertex_array.append(face.C)
		uv_array.append(Duv)
		normal_array.append(face.Normal)
		vertex_array.append(face.D)
		
		index_array.push_back((i * 4) + 0)
		index_array.push_back((i * 4) + 1)
		index_array.push_back((i * 4) + 2)
		index_array.push_back((i * 4) + 0)
		index_array.push_back((i * 4) + 2)
		index_array.push_back((i * 4) + 3)
	
	arrays[Mesh.ARRAY_VERTEX] = vertex_array
	arrays[Mesh.ARRAY_NORMAL] = normal_array
	arrays[Mesh.ARRAY_TEX_UV] = uv_array
	#arrays[Mesh.ARRAY_INDEX] = index_array
	
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
	var topFace = CreateFace(
		Vector3(-0.5, 0.5, -0.5),
		Vector3(0.5, 0.5, -0.5), 
		Vector3(0.5, 0.5, 0.5), 
		Vector3(-0.5, 0.5, 0.5)
	)	
	topFace.Id = 0
	
	# right	
	var rightFace = CreateFace(
		Vector3(0.5, 0.5, 0.5),
		Vector3(0.5, 0.5, -0.5),
		Vector3(0.5, -0.5, -0.5),
		Vector3(0.5, -0.5, 0.5)
	)	
	rightFace.Id = 1
	
	# front	
	var frontFace = CreateFace(
		Vector3(-0.5, 0.5, 0.5),
		Vector3(0.5, 0.5, 0.5),
		Vector3(0.5, -0.5, 0.5),
		Vector3(-0.5, -0.5, 0.5)
	)
	frontFace.Id = 2
	
	# left	
	var leftFace = CreateFace(
		Vector3(-0.5, -0.5, -0.5),
		Vector3(-0.5, 0.5, -0.5),
		Vector3(-0.5, 0.5, 0.5),
		Vector3(-0.5, -0.5, 0.5)
	)	
	leftFace.Id = 3
	
	# bottom	
	var bottomFace = CreateFace(
		Vector3(0.5, -0.5, 0.5),
		Vector3(0.5, -0.5, -0.5),
		Vector3(-0.5, -0.5, -0.5),
		Vector3(-0.5, -0.5, 0.5)
	)	
	bottomFace.Id = 4
		
	# back	
	var backFace = CreateFace(
		Vector3(0.5, -0.5, -0.5),
		Vector3(0.5, 0.5, -0.5),
		Vector3(-0.5, 0.5, -0.5),
		Vector3(-0.5, -0.5, -0.5)
	)
	backFace.Id = 5
	
	cube.get_editor_state().add_face(topFace)
	cube.get_editor_state().add_face(frontFace)
	cube.get_editor_state().add_face(leftFace)
	cube.get_editor_state().add_face(rightFace)
	cube.get_editor_state().add_face(backFace)
	cube.get_editor_state().add_face(bottomFace)
	
	cube.mesh = CreateMeshFromFaces(cube.get_editor_state().get_faces(), null, mat)
	return cube
	