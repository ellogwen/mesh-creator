# namespace MeshCreator_Generators
extends MeshCreator_Generators_MeshGeneratorBase
class_name MeshCreator_Generators_PlaneMeshGenerator

func _init().():
	pass
	
var _config = [
		{
			label = "Width",
			type = "int",
			minValue = 1,
			maxValue = 100,
			default = 1,
			value = 1
		},
		{
			label = "Depth",
			type = "int",
			minValue = 1,
			maxValue = 100,
			default = 1,
			value = 1
		},
		{
			label = "Columns",
			type = "int",
			minValue = 1,
			maxValue = 100,
			default = 1,
			value = 1
		},
		{
			label = "Rows",
			type = "int",
			minValue = 1,
			maxValue = 100,
			default = 1,
			value = 1
		},
	]
	
func get_config():
	return _config
	
func set_config_value(index, value):
	_config[index].value = value
	
func generate(configValues: Array) -> MeshCreator_Mesh_Mesh:
	var planeMesh = MeshCreator_Mesh_Mesh.new()
	
	var width = float(configValues[0]['value'])
	var depth = float(configValues[1]['value'])
	var columns = int(configValues[2]['value'])
	var rows = int(configValues[3]['value'])
	var cutSize = Vector3(width / float((columns + 1)), 0.0, depth / float((rows + 1)))
	var halfCut = Vector3(cutSize.x / 2.0, cutSize.y / 2.0, cutSize.z / 2.0)
	var halfSize = Vector3(width / 2.0, 0.0, depth / 2.0)
	
	# top		
	for x in range(0, columns + 1):
		for z in range(0, rows + 1):
			var a = Vector3(-halfSize.x + (x * cutSize.x), halfSize.y, -halfSize.z + (z * cutSize.z))
			var b = Vector3(-halfSize.x + (x * cutSize.x) + cutSize.x, halfSize.y, -halfSize.z + (z * cutSize.z))
			var c = Vector3(-halfSize.x + (x * cutSize.x) + cutSize.x, halfSize.y, -halfSize.z + (z * cutSize.z) + cutSize.z)
			var d = Vector3(-halfSize.x + (x * cutSize.x), halfSize.y, -halfSize.z + (z * cutSize.z) + cutSize.z)
			planeMesh.add_face_from_points(PoolVector3Array([a, b, c, d]))	
	
	return planeMesh

	
