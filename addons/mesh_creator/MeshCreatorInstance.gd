tool
extends MeshInstance

var DEFAULT_MATERIAL = preload("res://addons/mesh_creator/materials/mc_default.material")
var MeshInstanceEditorState = preload("res://addons/mesh_creator/MeshCreatorInstanceEditorState.gd")

var ActiveEditorPlugin = null

var _editorIndicator = null
var _editorState: MeshCreatorInstanceEditorState = null

func get_editor_state() -> MeshCreatorInstanceEditorState:
	return _editorState

func _init():	
	if (Engine.is_editor_hint()):
		_editorState = MeshCreatorInstanceEditorState.new()
		_editorState.connect("STATE_CHANGED", self, "_on_editor_state_changed")
	
func _ready():
	if (Engine.is_editor_hint()):
		var spatial = Spatial.new()
		spatial.name = "MC_Editor"
		add_child(spatial)
		spatial.set_owner(get_tree().get_edited_scene_root())
		_editorIndicator = ImmediateGeometry.new()
		_editorIndicator.set_script(preload("res://addons/mesh_creator/MeshCreatorInstanceEditorIndicator.gd"))
		_editorIndicator.name = "MC_EditorIndicator"
		spatial.add_child(_editorIndicator)
		_editorIndicator.set_owner(get_tree().get_edited_scene_root())		
	else:
		# remove editor helpers when running
		# the game
		if (has_node("MC_Editor")):
			var node = get_node("MC_Editor")
			remove_child(node)
			node.queue_free()
	
func SetEditorPlugin(plugin):
	# disconecct
	if (ActiveEditorPlugin != null):
		pass
		
	# connect
	ActiveEditorPlugin = plugin
	if (ActiveEditorPlugin != null):
		ActiveEditorPlugin.connect("state_changed", self, "_on_editorplugin_state_changed")
		
func _on_editorplugin_state_changed():		
	pass	
	
func GetFacesWithVertex(vtx: Vector3):
	var faces = get_editor_state().get_faces()
	var result = Array()
	for i in range(0, faces.size()):
		if (faces[i].HasVertex(vtx)):
			result.push_back(faces[i])
	return result
	
func _on_editor_state_changed():
	if (_editorIndicator != null):
		_editorIndicator.UpdateDraw()
	pass

# Face class
class Face:
	var A: Vector3
	var B: Vector3
	var C: Vector3
	var D: Vector3
	var NormalABD: Vector3
	var NormalCDB: Vector3
	var Normal: Vector3	
	var Id: int = -1
	
	func clone():
		var f = Face.new()
		f.A = A
		f.B = B
		f.C = C
		f.D = D
		f.NormalABD = NormalABD
		f.NormalCDB = NormalCDB
		f.Normal = Normal
		f.Id = Id
		return f
	
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