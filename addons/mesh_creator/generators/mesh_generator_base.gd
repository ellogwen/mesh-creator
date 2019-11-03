# namespace MeshCreator_Generators
class_name MeshCreator_Generators_MeshGeneratorBase

func _init():
	pass
	
func get_config():
	pass
	
func get_config_values(config: Array) -> Dictionary:
	var d = Dictionary()
	for i in range(0, config.size()):
		d[i] = config[0]["value"]
	return d
	
func is_valid() -> bool:
	return true
	pass
	
func generate(configValues: Dictionary) -> MeshCreator_Mesh_Mesh:
	return MeshCreator_Mesh_Mesh.new()
	pass