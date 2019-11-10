# namespace MeshCreator_Generators
extends MeshCreator_Generators_MeshGeneratorBase
class_name MeshCreator_Generators_BoxMeshGenerator

func _init().():
	pass
	
var _config = [
		{
			label = "Width",
			type = "int",
			minValue = 1,
			maxValue = 12,
			default = 1,
			value = 1
		},
		{
			label = "Height",
			type = "int",
			minValue = 1,
			maxValue = 12,
			default = 1,
			value = 1
		},
		{
			label = "Depth",
			type = "int",
			minValue = 1,
			maxValue = 12,
			default = 1,
			value = 1
		},
		{
			label = "Cuts",
			type = "int",
			minValue = 0,
			maxValue = 12,
			default = 0,
			value = 0
		},
	]
	
func get_config():
	return _config
	
func set_config_value(index, value):
	_config[index].value = value
	
func generate(configValues: Array) -> MeshCreator_Mesh_Mesh:
	var boxMesh = MeshCreator_Mesh_Mesh.new()
	
	var width = float(configValues[0]['value'])
	var height = float(configValues[1]['value'])
	var depth = float(configValues[2]['value'])
	var cuts = int(configValues[3]['value'])	
	var cutSize = Vector3(width / float((cuts + 1)), height / float((cuts + 1)), depth / float((cuts + 1)))
	var halfCut = Vector3(cutSize.x / 2.0, cutSize.y / 2.0, cutSize.z / 2.0)
	var halfSize = Vector3(width / 2.0, height / 2.0, depth / 2.0)
	
	# top		
	for x in range(0, cuts + 1):
		for z in range(0, cuts + 1):
			var a = Vector3(-halfSize.x + (x * cutSize.x), halfSize.y, -halfSize.z + (z * cutSize.z))
			var b = Vector3(-halfSize.x + (x * cutSize.x) + cutSize.x, halfSize.y, -halfSize.z + (z * cutSize.z))
			var c = Vector3(-halfSize.x + (x * cutSize.x) + cutSize.x, halfSize.y, -halfSize.z + (z * cutSize.z) + cutSize.z)
			var d = Vector3(-halfSize.x + (x * cutSize.x), halfSize.y, -halfSize.z + (z * cutSize.z) + cutSize.z)
			boxMesh.add_face_from_points(PoolVector3Array([a, b, c, d]))	
			
	# bottom
	for x in range(0, cuts + 1):
		for z in range(0, cuts + 1):
			var a = Vector3(-halfSize.x + (x * cutSize.x), -halfSize.y, halfSize.z - (z * cutSize.z))
			var b = Vector3(-halfSize.x + (x * cutSize.x) + cutSize.x, -halfSize.y, halfSize.z - (z * cutSize.z))
			var c = Vector3(-halfSize.x + (x * cutSize.x) + cutSize.x, -halfSize.y, halfSize.z - (z * cutSize.z) - cutSize.z)
			var d = Vector3(-halfSize.x + (x * cutSize.x), -halfSize.y, halfSize.z - (z * cutSize.z) - cutSize.z)
			boxMesh.add_face_from_points(PoolVector3Array([a, b, c, d]))	
			
	# front
	for x in range(0, cuts + 1):
		for y in range(0, cuts + 1):
			var a = Vector3(-halfSize.x + (x * cutSize.x), halfSize.y - (y * cutSize.y), halfSize.z)
			var b = Vector3(-halfSize.x + (x * cutSize.x) + cutSize.x, halfSize.y - (y * cutSize.y), halfSize.z)
			var c = Vector3(-halfSize.x + (x * cutSize.x) + cutSize.x, halfSize.y - (y * cutSize.y) - cutSize.y, halfSize.z)
			var d = Vector3(-halfSize.x + (x * cutSize.x), halfSize.y - (y * cutSize.y) - cutSize.y, halfSize.z)
			boxMesh.add_face_from_points(PoolVector3Array([a, b, c, d]))			
			
	# back
	for x in range(0, cuts + 1):
		for y in range(0, cuts + 1):
			var a = Vector3(halfSize.x - (x * cutSize.x), halfSize.y - (y * cutSize.y), -halfSize.z)
			var b = Vector3(halfSize.x - (x * cutSize.x) - cutSize.x, halfSize.y - (y * cutSize.y), -halfSize.z)
			var c = Vector3(halfSize.x - (x * cutSize.x) - cutSize.x, halfSize.y - (y * cutSize.y) - cutSize.y, -halfSize.z)
			var d = Vector3(halfSize.x - (x * cutSize.x), halfSize.y - (y * cutSize.y) - cutSize.y, -halfSize.z)
			boxMesh.add_face_from_points(PoolVector3Array([a, b, c, d]))
			
	# right
	for z in range(0, cuts + 1):
		for y in range(0, cuts + 1):
			var a = Vector3(halfSize.x, halfSize.y - (y * cutSize.y), halfSize.z - (z * cutSize.z))
			var b = Vector3(halfSize.x, halfSize.y - (y * cutSize.y), halfSize.z - (z * cutSize.z) - cutSize.z)
			var c = Vector3(halfSize.x, halfSize.y - (y * cutSize.y) - cutSize.y, halfSize.z - (z * cutSize.z) - cutSize.z)
			var d = Vector3(halfSize.x, halfSize.y - (y * cutSize.y) - cutSize.y, halfSize.z - (z * cutSize.z))
			boxMesh.add_face_from_points(PoolVector3Array([a, b, c, d]))	
			
	# left
	for z in range(0, cuts + 1):
		for y in range(0, cuts + 1):
			var a = Vector3(-halfSize.x, halfSize.y - (y * cutSize.y), -halfSize.z + (z * cutSize.z))
			var b = Vector3(-halfSize.x, halfSize.y - (y * cutSize.y), -halfSize.z + (z * cutSize.z) + cutSize.z)
			var c = Vector3(-halfSize.x, halfSize.y - (y * cutSize.y) - cutSize.y, -halfSize.z + (z * cutSize.z) + cutSize.z)
			var d = Vector3(-halfSize.x, halfSize.y - (y * cutSize.y) - cutSize.y, -halfSize.z + (z * cutSize.z))
			boxMesh.add_face_from_points(PoolVector3Array([a, b, c, d]))	

	return boxMesh	

	
