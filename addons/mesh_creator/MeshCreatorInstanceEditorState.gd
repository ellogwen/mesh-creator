class_name MeshCreatorInstanceEditorState

var _highestFaceId = -1
var _faces: Array
var _edges: Array
var _selectedFaceIds: Array
var _selectedEdgeIds: Array

signal STATE_CHANGED

# ctor
func _init():
	_faces = Array()	
	_edges = Array()
	_selectedFaceIds = Array()
	_selectedEdgeIds = Array()
	var _highestFaceId = -1

####################	
# edges
####################

func get_edges() -> Array:
	return _edges
	
func get_edge(edgeId):
	for edge in get_edges():
		if (edge.Id == edgeId):
			return edge
	return null

func find_edge(a, b, strict = false):
	for edge in get_edges():
		if (edge.matches(a, b, strict)):
			return edge
	return null
	
func connect_edge_to_faces(edge, faceIds: PoolIntArray):
	for faceId in faceIds:
		if not edge.FacesMapping.has(faceId):
			edge.FacesMapping.push_back(faceId)
	emit_signal("STATE_CHANGED")
	pass
	
func disconnect_edge_from_faces(edge, faceIds: PoolIntArray):
	for faceId in faceIds:
		edge.FacesMapping.erase(faceId)
	emit_signal("STATE_CHANGED")
	pass
	
####################
# faces
####################

func get_faces() -> Array:
	return _faces    
	
func get_face(faceId):
	for face in get_faces():
		if (face.Id == faceId):
			return face
	return null
	
func get_highest_face_id():
	return _highestFaceId

func add_face(face) -> void:
	# @todo find a better way to handle face ids
	if (face.Id > _highestFaceId):
		_highestFaceId = face.Id
		
	self._faces.push_back(face)
	if face.EdgesMapping.empty():		
		var abEdge = find_edge(face.A, face.B)
		var bcEdge = find_edge(face.B, face.C)
		var cdEdge = find_edge(face.C, face.D)
		var daEdge = find_edge(face.D, face.A)
		
		if (abEdge == null):			
			abEdge = Edge.new(face.A, face.B, (face.Id * 4) + 0)
			_edges.push_back(abEdge)
		if (bcEdge == null):			
			bcEdge = Edge.new(face.B, face.C, (face.Id * 4) + 1)
			_edges.push_back(bcEdge)
		if (cdEdge == null):			
			cdEdge = Edge.new(face.C, face.D, (face.Id * 4) + 2)
			_edges.push_back(cdEdge)
		if (daEdge == null):			
			daEdge = Edge.new(face.D, face.A, (face.Id * 4) + 3)
			_edges.push_back(daEdge)
			
		connect_edge_to_faces(abEdge, PoolIntArray([face.Id]))
		connect_edge_to_faces(bcEdge, PoolIntArray([face.Id]))
		connect_edge_to_faces(cdEdge, PoolIntArray([face.Id]))
		connect_edge_to_faces(daEdge, PoolIntArray([face.Id]))		
		connect_face_to_edges(face, PoolIntArray([abEdge.Id, bcEdge.Id, cdEdge.Id, daEdge.Id]))			
		
	emit_signal("STATE_CHANGED")


		
func recalculate_edges():
	_edges.clear()
	for face in _faces:
		face.EdgesMapping.clear()
		var abEdge = find_edge(face.A, face.B)
		var bcEdge = find_edge(face.B, face.C)
		var cdEdge = find_edge(face.C, face.D)
		var daEdge = find_edge(face.D, face.A)
		
		if (abEdge == null):			
			abEdge = Edge.new(face.A, face.B, (face.Id * 4) + 0)
			_edges.push_back(abEdge)
		if (bcEdge == null):			
			bcEdge = Edge.new(face.B, face.C, (face.Id * 4) + 1)
			_edges.push_back(bcEdge)
		if (cdEdge == null):			
			cdEdge = Edge.new(face.C, face.D, (face.Id * 4) + 2)
			_edges.push_back(cdEdge)
		if (daEdge == null):			
			daEdge = Edge.new(face.D, face.A, (face.Id * 4) + 3)
			_edges.push_back(daEdge)
			
		connect_edge_to_faces(abEdge, PoolIntArray([face.Id]))
		connect_edge_to_faces(bcEdge, PoolIntArray([face.Id]))
		connect_edge_to_faces(cdEdge, PoolIntArray([face.Id]))
		connect_edge_to_faces(daEdge, PoolIntArray([face.Id]))		
		connect_face_to_edges(face, PoolIntArray([abEdge.Id, bcEdge.Id, cdEdge.Id, daEdge.Id]))			
	
	
func connect_face_to_edges(face, edgeIds: PoolIntArray):
	for edgeId in edgeIds:
		if not face.EdgesMapping.has(edgeId):
			face.EdgesMapping.push_back(edgeId)	
	pass
	
func disconnect_face_from_edges(face, edgeIds: PoolIntArray):
	for edgeId in edgeIds:
		face.EdgesMapping.erase(edgeId)	
	pass	


# face selection

func get_selected_face_ids() -> Array:
	return _selectedFaceIds
	
func get_selected_faces() -> Array:
	var faceIds: Array = get_selected_face_ids()
	var result = Array()	
	for face in get_faces():
		if (faceIds.has(face.Id)):		
			result.push_back(face)				
	return result

func add_face_id_to_selection(faceId: int) -> void:
	if (is_face_id_selected(faceId) == false):
		_selectedFaceIds.push_back(faceId)
		emit_signal("STATE_CHANGED")
	pass

func remove_face_id_from_selection(faceId: int) -> void:
	_selectedFaceIds.erase(faceId)
	emit_signal("STATE_CHANGED")
	pass

func is_face_id_selected(faceId: int) -> bool:	
	return _selectedFaceIds.has(faceId)
	
func has_selected_faces() -> bool:
	return not _selectedFaceIds.empty()
	
func clear_face_selection() -> void:
	_selectedFaceIds.clear()
	emit_signal("STATE_CHANGED")
	pass


########################
# events and callbacks
########################

func notify_state_changed() -> void:
	emit_signal("STATE_CHANGED")
	
# Edge class
class Edge:
	var A: Vector3
	var B: Vector3
	var Id: int = -1	
	var FacesMapping: Array = Array()
	
	func _init(a, b, id):
		A = a
		B = b
		Id = id
	
	func length():
		return (B - A).length()
		
	func matches(a, b, strict = false):
		if (strict):
			return (A == a and B == b)
		else:
			return ( (A == a and B == b) or (A == b and B == a) )

