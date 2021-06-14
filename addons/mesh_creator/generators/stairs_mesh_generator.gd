# namespace MeshCreator_Generators
extends MeshCreator_Generators_MeshGeneratorBase
class_name MeshCreator_Generators_StairsMeshGenerator

func _init().():
	pass
	
var _config = [
		{
			label = "Steps",
			type = "int",
			minValue = 1,
			maxValue = 100,
			default = 4,
			value = 4
		},
		{
			label = "Width",
			type = "float",
			minValue = 0.1,
			maxValue = 99.0,
			default = 1.0,
			value = 1.0,
			stepSize = 0.1
		},
		{
			label = "StepHeight",
			type = "float",
			minValue = 0.1,
			maxValue = 1.0,
			default = 0.35,
			value = 0.35,
			stepSize = 0.05
		},
		{
			label = "StepDepth",
			type = "float",
			minValue = 0.1,
			maxValue = 1.0,
			default = 0.35,
			value = 0.35,
			stepSize = 0.05
		},
	]
	
func get_config():
	return _config
	
func set_config_value(index, value):
	_config[index].value = value
	
func generate(configValues: Array) -> MeshCreator_Mesh_Mesh:
	var stairsMesh = MeshCreator_Mesh_Mesh.new()
	
	var steps = int(configValues[0]['value'])
	var width = float(configValues[1]['value'])
	var step_height = float(configValues[2]['value'])
	var step_depth = float(configValues[3]['value'])
	var half_width = width / 2.0
	var half_step_depth = step_depth / 2.0
	
	for s in range(steps):
			
		# actual step
		
		# top
		if true:
			var a = Vector3(-half_width, (s * step_height) + step_height, -half_step_depth - (s * step_depth))
			var b = Vector3(half_width, (s * step_height) + step_height, -half_step_depth - (s * step_depth))
			var c = Vector3(half_width, (s * step_height) + step_height, half_step_depth - (s * step_depth))
			var d = Vector3(-half_width, (s * step_height) + step_height, half_step_depth - (s * step_depth))
			stairsMesh.add_face_from_points(PoolVector3Array([a, b, c, d]))	
			
		# right
		if true:
			var a = Vector3(half_width, (s * step_height) + step_height, half_step_depth - (s * step_depth))
			var b = Vector3(half_width, (s * step_height) + step_height, -half_step_depth - (s * step_depth))
			var c = Vector3(half_width, 0.0, -half_step_depth - (s * step_depth))
			var d = Vector3(half_width, 0.0, half_step_depth - (s * step_depth))
			stairsMesh.add_face_from_points(PoolVector3Array([a, b, c, d]))	
		
		# left
		if true:
			var a = Vector3(-half_width, (s * step_height) + step_height, -half_step_depth - (s * step_depth))
			var b = Vector3(-half_width, (s * step_height) + step_height, half_step_depth - (s * step_depth))
			var c = Vector3(-half_width, 0.0, half_step_depth - (s * step_depth))
			var d = Vector3(-half_width, 0.0, -half_step_depth - (s * step_depth))
			stairsMesh.add_face_from_points(PoolVector3Array([a, b, c, d]))	
		
		# front
		if true:
			var a = Vector3(-half_width, (s * step_height) + step_height, half_step_depth - (s * step_depth))
			var b = Vector3(half_width, (s * step_height) + step_height, half_step_depth - (s * step_depth))
			var c = Vector3(half_width, (s * step_height), half_step_depth - (s * step_depth))
			var d = Vector3(-half_width, (s * step_height), half_step_depth - (s * step_depth))
			stairsMesh.add_face_from_points(PoolVector3Array([a, b, c, d]))	
			
	# closing bottom
	if true:
		var a = Vector3(-half_width, 0.0, +half_step_depth)
		var b = Vector3(half_width, 0.0, +half_step_depth)
		var c = Vector3(half_width, 0.0, -half_step_depth - ((steps - 1) * step_depth))
		var d = Vector3(-half_width, 0.0, -half_step_depth - ((steps - 1) * step_depth))
		stairsMesh.add_face_from_points(PoolVector3Array([a, b, c, d]))	
		
	# closing back
	if true:
		var a = Vector3(half_width, (steps * step_height), -half_step_depth - ((steps - 1) * step_depth))
		var b = Vector3(-half_width, (steps * step_height), -half_step_depth - ((steps - 1) * step_depth))
		var c = Vector3(-half_width, 0.0, -half_step_depth - ((steps - 1) * step_depth))
		var d = Vector3(half_width, 0.0, -half_step_depth - ((steps - 1) * step_depth))
		stairsMesh.add_face_from_points(PoolVector3Array([a, b, c, d]))	
	
	return stairsMesh
