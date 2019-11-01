# namespace MeshCreator_Mesh
class_name MeshCreator_Mesh_EditorFace

var _meshCreatorMesh
var _faceId: int
var _edgeIndices = Array()
var _verticesIndices = Array()

func init(meshCreatorMesh):
	_meshCreatorMesh = meshCreatorMesh
	pass