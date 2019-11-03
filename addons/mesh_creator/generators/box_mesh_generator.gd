# namespace MeshCreator_Generators
extends MeshCreator_Generators_MeshGeneratorBase
class_name MeshCreator_Generators_BoxMeshGenerator

func _init().():
	pass
	
func get_config():
	pass
	return [
		{
			label = "Width",
			type = "int",
			minValue = 1,
			maxValue = 12,
			default = 1
		},
		{
			label = "Height",
			type = "int",
			minValue = 1,
			maxValue = 12,
			default = 1
		},
		{
			label = "Depth",
			type = "int",
			minValue = 1,
			maxValue = 12,
			default = 1
		},		
	]
	
func generate(configValues: Dictionary) -> MeshCreator_Mesh_Mesh:
	var boxMesh = MeshCreator_Mesh_Mesh.new()
	
	var width = float(configValues[0])
	var height = float(configValues[1])
	var depth = float(configValues[2])
		
	
	# top
	var topFace = PoolVector3Array([
		Vector3(-(width/2.0), (height/2.0), -(depth/2.0)),
		Vector3((width/2.0), (height/2.0), -(depth/2.0)), 
		Vector3((width/2.0), (height/2.0), (depth/2.0)), 
		Vector3(-(width/2.0), (height/2.0), (depth/2.0))
	])		
	
	# right	
	var rightFace = PoolVector3Array([
		Vector3((width/2.0), (height/2.0), (depth/2.0)),
		Vector3((width/2.0), (height/2.0), -(depth/2.0)),
		Vector3((width/2.0), -(height/2.0), -(depth/2.0)),
		Vector3((width/2.0), -(height/2.0), (depth/2.0))
	])		
	
	# front	
	var frontFace = PoolVector3Array([
		Vector3(-(width/2.0), (height/2.0), (depth/2.0)),
		Vector3((width/2.0), (height/2.0), (depth/2.0)),
		Vector3((width/2.0), -(height/2.0), (depth/2.0)),
		Vector3(-(width/2.0), -(height/2.0), (depth/2.0))
	])	
	
	# left	
	var leftFace = PoolVector3Array([
		Vector3(-(width/2.0), -(height/2.0), -(depth/2.0)),
		Vector3(-(width/2.0), (height/2.0), -(depth/2.0)),
		Vector3(-(width/2.0), (height/2.0), (depth/2.0)),
		Vector3(-(width/2.0), -(height/2.0), (depth/2.0))
	])		
	
	# bottom	
	var bottomFace = PoolVector3Array([
		Vector3((width/2.0), -(height/2.0), (depth/2.0)),
		Vector3((width/2.0), -(height/2.0), -(depth/2.0)),
		Vector3(-(width/2.0), -(height/2.0), -(depth/2.0)),
		Vector3(-(width/2.0), -(height/2.0), (depth/2.0))
	])	
		
	# back	
	var backFace = PoolVector3Array([
		Vector3((width/2.0), -(height/2.0), -(depth/2.0)),
		Vector3((width/2.0), (height/2.0), -(depth/2.0)),
		Vector3(-(width/2.0), (height/2.0), -(depth/2.0)),
		Vector3(-(width/2.0), -(height/2.0), -(depth/2.0))
	])	
	
	boxMesh.add_face_from_points(topFace)
	boxMesh.add_face_from_points(frontFace)
	boxMesh.add_face_from_points(leftFace)
	boxMesh.add_face_from_points(rightFace)
	boxMesh.add_face_from_points(backFace)
	boxMesh.add_face_from_points(bottomFace)
	return boxMesh