# namespace MeshCreator_Mesh
class_name MeshCreator_Mesh_Mesh
extends Reference
	
# typeof Array<MeshCreator_Mesh_Face>
var _faces: Array = Array()
func get_face(index: int): return _faces[index]
func get_faces() -> Array: return _faces
func get_faces_selection(faceIds: Array) -> Array:
	var faces = Array()
	for fId in faceIds:
		faces.push_back(get_face(fId))
	return faces

# typeof Array<MeshCreator_Mesh_Edge>
var _edges: Array  = Array()
func get_edges() -> Array: return _edges
func get_edge(index: int): return _edges[index]
func get_edges_selection(edgeIds: Array) -> Array:
	var edges = Array()
	for eId in edgeIds:
		edges.push_back(get_edge(eId))
	return edges

# typeof Array<MeasCreator_Mesh_Vertex>
var _vertices: Array = Array()
func get_vertex(index: int): return _vertices[index]
func get_vertices() -> Array: return _vertices
func get_vertices_selection(vtxIds: Array) -> Array:
	var verts = Array()
	for vId in vtxIds:
		verts.push_back(get_vertex(vId))
	return verts

var _nextVerticesIndex = -1
func _nextVertIdx() -> int:
	_nextVerticesIndex += 1
	return _nextVerticesIndex

var _nextFacesIndex = 0
func _nextFaceIdx() -> int:
	_nextFacesIndex += 1
	return _nextFacesIndex
	
var _nextEdgeIndex = 0
func _nextEdgeIdx() -> int:
	_nextEdgeIndex += 1
	return _nextEdgeIndex
	
func _init():
	clear()
	pass
	
func clear():
	_faces.clear()
	_edges.clear()
	_vertices.clear()
	_nextVerticesIndex = -1
	_nextFacesIndex = -1
	_nextEdgeIndex = -1
	pass
	
func define_face_from_vertices(verts: Array) -> int:
	var realVerts = Array()
	for vtx in verts:
		var realVtx = vtx
		if (vtx.get_mesh_index() < 0):
			realVtx = add_vertex(vtx)
		realVerts.push_back(realVtx)
	var f = MeshCreator_Mesh_Face.new(realVerts)
	f.set_mesh_index(_nextFaceIdx())
	_faces.push_back(f)
	# register edges
	register_face_edges(f)
	return f.get_mesh_index()
	
func register_face_edges(face):
	var vertexCount = face.get_vertex_count()
	for i in range(0, vertexCount):
		var a = face.get_vertex(i)
		var b = face.get_vertex((i + 1) % vertexCount)
		var edge = define_edge_from_vertices(a, b)
		face.set_edge(i, edge.get_mesh_index())
	pass
	
func add_face_from_points(pts: PoolVector3Array, independentVerts = false) -> int:
	var verts = Array()
	for pt in pts:
		verts.push_back(get_vertex(add_point(pt, independentVerts).get_mesh_index()))
	return define_face_from_vertices(verts)
	
func add_vertex(vtx: MeshCreator_Mesh_Vertex, independentVerts = false) -> MeshCreator_Mesh_Vertex:
	if (vtx.get_mesh_index() >= 0):
		print("[Mesh Creator] Add Vertex Warning. Vertex already indexed: Idx " + str(vtx.get_mesh_index()))
		return get_vertex(vtx.get_mesh_index())
	# find duplicate is this the right way? @todo find a good solution for linked vertices
	if (independentVerts == false):
		for v in _vertices:
			if v.equals_position(vtx):
				vtx.set_mesh_index(v.get_mesh_index())
				return get_vertex(v.get_mesh_index())
	_vertices.push_back(vtx)
	vtx.set_mesh_index(_nextVertIdx())
	return vtx
	
func define_edge_from_vertices(vtxA: MeshCreator_Mesh_Vertex, vtxB: MeshCreator_Mesh_Vertex) -> MeshCreator_Mesh_Edge :
	for e in _edges:
		if e.matches(vtxA.get_position(), vtxB.get_position(), true):
			return get_edge(e.get_mesh_index())
	var edge = MeshCreator_Mesh_Edge.new(vtxA, vtxB)
	edge.set_mesh_index(_nextEdgeIdx())
	_edges.push_back(edge)
	return edge
		
func add_point(pt: Vector3, independetVerts = false) -> MeshCreator_Mesh_Vertex:
	var vtx = MeshCreator_Mesh_Vertex.new(pt)
	return add_vertex(vtx, independetVerts)
	
func translate_vertex(vertexId: int, offset: Vector3):	
	var vtx = get_vertex(vertexId)
	if (vtx != null):
		vtx.set_position(vtx.get_position() + offset)
	pass
	
# does this work and leave a gap?
func remove_face(faceId: int):
	# reindex
	for i in range(faceId + 1, _faces.size()):
		var face = _faces[i]
		face.set_mesh_index(face.get_mesh_index() - 1)
	# remove
	_faces.remove(faceId)
	# index
	#_nextFacesIndex -= 1
	
func remove_edge(edgeId: int):
	#reindex
	for i in range(edgeId + 1, _edges.size()):
		var edge = _edges[i]
		edge.set_mesh_index(edge.get_mesh_index() -1)
	#remove
	_edges.remove(edgeId)
	# index
	#_nextEdgeIndex -= 1
	
func remove_vertex(vtxId: int):
	#reindex
	for i in range(vtxId + 1, _vertices.size()):
		var vtx = _vertices[i]
		vtx.set_mesh_index(vtx.get_mesh_index() -1)
	#remove
	_vertices.remove(vtxId)
	# index
	#_nextVerticesIndex -= 1

# @todo does this only work with convex faces?		
func extrude_face(faceId: int):
	var face = get_face(faceId)
	var faceNewPts = Array()
	var faceVerts = face.get_vertices()
	var faceVertsCount = faceVerts.size()
	var centroid = face.get_centroid()
	
	for n in range(0, faceVertsCount):
		var vtx = face.get_vertex(n)
		faceNewPts.push_back(vtx.get_position() - (face.get_normal() * 0.25))
		
	# create N new faces (quads)
	for n in range(0, faceVertsCount):
		var a = faceVerts[n].get_position()
		var d = faceNewPts[n]
		var b
		var c
		if (n + 1 >= faceVertsCount):
			b = faceVerts[0].get_position()
			c = faceNewPts[0]
		else:
			b = faceVerts[n + 1].get_position()
			c = faceNewPts[n + 1]
		
		add_face_from_points(PoolVector3Array([a, b, c, d]))
		pass
	
	# overwrite existing verts and define new
	# introduce new verts
	var newVerts = Array()
	for pt in faceNewPts:
		newVerts.push_back(add_point(pt))
	face.from_verts(newVerts)	
	face.refresh() # this makes sure triangulation is done
	register_face_edges(face)
	pass
	
# @todo does this only work with convex faces?		
func inset_face(faceId: int, factor = 0.25):
	var face = get_face(faceId)
	var faceNewPts = Array()
	var faceVerts = face.get_vertices()
	var faceVertsCount = faceVerts.size()
	var centroid = face.get_centroid()
	
	for n in range(0, faceVertsCount):
		var vtx = face.get_vertex(n)
		faceNewPts.push_back(vtx.get_position() + ((centroid - vtx.get_position()) * factor))
		
	# create N new faces (quads)
	for n in range(0, faceVertsCount):
		var a = faceVerts[n].get_position()
		var d = faceNewPts[n]
		var b
		var c
		if (n + 1 >= faceVertsCount):
			b = faceVerts[0].get_position()
			c = faceNewPts[0]
		else:
			b = faceVerts[n + 1].get_position()
			c = faceNewPts[n + 1]
		
		add_face_from_points(PoolVector3Array([a, b, c, d]))
		pass
	
	# overwrite existing verts and define new
	# introduce new verts
	var newVerts = Array()
	for pt in faceNewPts:
		newVerts.push_back(add_point(pt))
	face.from_verts(newVerts)		
	face.refresh() # this makes sure triangulation is done
	register_face_edges(face)
	pass
	
func loopcut(loopcutChain : Array, startEdgeIndex = 0, factor: float = 0.5):
	factor = clamp(factor,0.0001, 0.9999)
	if (loopcutChain.size() < 3):
		print("Loopcut: Invalid chain size. abort")
		return
	var endId = loopcutChain.back()	
	var inEdgeIndex = (startEdgeIndex + 2) % 4	
	for i in range(0, loopcutChain.size() - 1):		
		var outEdgeIndex = (inEdgeIndex + 2) % 4	
		var currFace = get_face(loopcutChain[i])
		
		if (currFace.get_vertex_count() != 4):
			print("Loopcut: Error - Current implementation only support convex shapes with 4 vertices (quads)")
			return
		
		var inEdgeStartPos = currFace.get_edge_start(inEdgeIndex)
		var inEdgeEndPos = currFace.get_edge_end(inEdgeIndex)
		var inEdgeCutPosVec = (inEdgeEndPos - inEdgeStartPos)
		var inEdgeCutPos = inEdgeStartPos + (inEdgeCutPosVec.normalized() * (inEdgeCutPosVec.length() * factor))
		
		var outEdgeStartPos = currFace.get_edge_start(outEdgeIndex)
		var outEdgeEndPos = currFace.get_edge_end(outEdgeIndex)
		var outEdgeCutPosVec = (outEdgeEndPos - outEdgeStartPos)		
		var outEdgeCutPos = outEdgeStartPos + (outEdgeCutPosVec.normalized() * (outEdgeCutPosVec.length() * (1.0 - factor)))
		
		var currFaceA = currFace.get_vertex(outEdgeIndex).get_position()
		var currFaceB = outEdgeCutPos
		var currFaceC = inEdgeCutPos
		var currFaceD = currFace.get_vertex((outEdgeIndex + 3) % 4).get_position()
		
		var newFaceA = outEdgeCutPos
		var newFaceB = currFace.get_vertex((outEdgeIndex + 1) % 4).get_position()
		var newFaceC = currFace.get_vertex((outEdgeIndex + 2) % 4).get_position()
		var newFaceD = inEdgeCutPos		
		
		var nextFace = get_face(loopcutChain[i + 1])		
		
		currFace.from_verts([add_point(currFaceA), add_point(currFaceB), add_point(currFaceC), add_point(currFaceD)])	
		currFace.refresh() # this makes sure triangulation is done		
		register_face_edges(currFace)
		add_face_from_points(PoolVector3Array([newFaceA, newFaceB, newFaceC, newFaceD]))		
		
		if (loopcutChain[i +1] == endId):
			break;
			
		inEdgeIndex = nextFace.get_edge_index(outEdgeEndPos, outEdgeStartPos) # flip
		if (inEdgeIndex < 0):			
			print("Loopcut: Error - Could not detect matching edge")
			return
	pass
	
# returns a list of faces that build a loopcut chain, first and last
# element is the start face
# loopcuts only supported for quads right now
# empty list if loopcut chain cant be created
# yes, this look inefficient ^^
func build_loopcut_chain(fromFaceId, perEdgeIndex = 0) -> Array:
	var chain = Array()
	
	var startFace = get_face(fromFaceId)
		
	var outEdgeIndex = perEdgeIndex
	var edgeA = startFace.get_edge_start(perEdgeIndex)
	var edgeB = startFace.get_edge_end(perEdgeIndex)
	
	var currentFaceId = find_face_with_edge(edgeB, edgeA, fromFaceId) # flip
	
	if (currentFaceId < 0):
		return Array()
		
	var process = true
	var killSwitch = 1000000
	while(process):
		killSwitch -= 1
		
		if (killSwitch < 0):
			print("Loopcut: Safety switch. sorry")
			return Array()
			
		if (currentFaceId < 0):
			print("Loopcut: No current face. Abort")
			return Array()
			
		var currentFace = get_face(currentFaceId)
		
		if (currentFace.get_mesh_index() == fromFaceId):
			print("Loopcut: We reached start")
			process = false
			break
			
		if chain.has(currentFace.get_mesh_index()):
			print("Loopcut: Face does already exist in chain. Abort.")
			return Array()
		
		if (currentFace.get_vertex_count() != 4):
			print("Lookup: Face does not have 4 vertices. abort")
			return Array()
			
		var inEdgeIndex = currentFace.get_edge_index(edgeB, edgeA) #flip
		if (inEdgeIndex < 0):
			print("Loopcut: Face does not have a matching edge")
			return Array()
		
		chain.push_back(currentFace.get_mesh_index())
		
		outEdgeIndex = (inEdgeIndex + 2) % 4
		
		if outEdgeIndex == inEdgeIndex:
			print("Loopcut: Edge index calculation error. Abort.")
			return Array()
		
		edgeA = currentFace.get_edge_start(outEdgeIndex)
		edgeB = currentFace.get_edge_end(outEdgeIndex)
		
		currentFaceId = find_face_with_edge(edgeB, edgeA, currentFace.get_mesh_index())	# flip
		pass
		
	print ("Loopcut: Finished loopcut with " + str(1000000 - killSwitch) + " iterations.")	
	
	# loop chain starts and ends with starting face
	chain.push_front(fromFaceId)
	chain.push_back(fromFaceId)	
	return chain
	
func find_face_with_edge(a, b, ignoreId = -1) -> int:
	for face in _faces:
		if (face.get_mesh_index() == ignoreId):
			continue
		if (face.has_edge(a, b)):
			return face.get_mesh_index()
	return -1
