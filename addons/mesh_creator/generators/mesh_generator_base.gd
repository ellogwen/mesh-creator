# namespace MeshCreator_Generators
class_name MeshCreator_Generators_MeshGeneratorBase

func _init():
	pass
	
func get_config():
	pass
	
func get_config_value(id):
	pass
	
func set_config_value(id, val):
	pass
	
func is_valid() -> bool:
	return true
	pass
	
func generate(configValues: Dictionary) -> MeshCreator_Mesh_Mesh:
	return MeshCreator_Mesh_Mesh.new()
	pass