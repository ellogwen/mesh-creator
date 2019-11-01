class_name MeshCreator_Gizmos_VertexModeGizmoController

var MeshCreatorInstance = preload("res://addons/mesh_creator/MeshCreatorInstance.gd")
var meshTools = MeshCreator_MeshTools.new()

var _gizmo
var _vertexHandles = Array()

func _init(gizmo):
	_gizmo = gizmo
	pass
	
func setup(plugin):
	pass
	
func gizmo_redraw():
	_gizmo.clear()
	_vertexHandles.clear()
	
	var mci = _gizmo.get_spatial_node()
	if (not mci is MeshCreatorInstance):
		return
		
	var lines = PoolVector3Array()
	var handles = PoolVector3Array()
	
	var lineMat = _gizmo.get_plugin().get_material("yellow", self)
	var matHandleVertex = _gizmo.get_plugin().get_material("handles_vertex", self)
	var matHandleVertexSelected = _gizmo.get_plugin().get_material("handles_vertex_selected", self)	
	
	var handleIdx = 0
	for face in mci.get_editor_state().get_faces():
		lines.push_back(face.get_centroid())
		lines.push_back(face.get_centroid() + face.Normal)
		
		var trVHD = VertexHandleData.new()
		trVHD.id = handleIdx
		trVHD.localPosition = face.A
		trVHD.committedPosition = face.A
		trVHD.faceId = face.Id
		trVHD.faceVertexIndex = 0
		_vertexHandles.append(trVHD)
		handles.push_back(face.A)
		handleIdx += 1
				
		var brVHD = VertexHandleData.new()
		brVHD.id = handleIdx
		brVHD.localPosition = face.B
		brVHD.committedPosition = face.B
		brVHD.faceId = face.Id
		brVHD.faceVertexIndex = 1
		_vertexHandles.append(brVHD)
		handles.push_back(face.B)
		handleIdx += 1		
		
		var blVHD = VertexHandleData.new()
		blVHD.id = handleIdx
		blVHD.localPosition = face.C
		blVHD.committedPosition = face.C
		blVHD.faceId = face.Id
		blVHD.faceVertexIndex = 2
		_vertexHandles.append(blVHD)
		handles.push_back(face.C)
		handleIdx += 1
		
		var tlVHD = VertexHandleData.new()
		tlVHD.id = handleIdx
		tlVHD.localPosition = face.D
		tlVHD.committedPosition = face.D
		tlVHD.faceId = face.Id
		tlVHD.faceVertexIndex = 3
		_vertexHandles.append(tlVHD)
		handles.push_back(face.D)
		handleIdx += 1
	
		_gizmo.show_cursor_3d()
		
	# add_lines(lines, lineMat, false)
	_gizmo.add_handles(handles, _gizmo.get_plugin().HandleMaterial, false, false)
	pass
	
func gizmo_get_handle_name(index):
	var handle = _vertexHandles[index]
	if (handle != null):
		return "Handle " + str(handle.id) + " Face " + str(handle.faceId) + " Vertex " + str(handle.faceVertexIndex)
	else:
		return "Vertex Handle " + str(index)

func gizmo_get_handle_value(index):
	var handle = _vertexHandles[index]
	if (handle != null):
		return handle.localPosition
	return null
	
func gizmo_commit_handle(index, restore, cancel=false):
	var handle = _vertexHandles[index]
	if (handle != null and cancel == false):
		handle.committedPosition = handle.localPosition
	# @TODO support cancel?
	gizmo_redraw()
	pass
	
func gizmo_set_handle(index, camera, screen_point : Vector2):
	prints("set_handle index", index, screen_point)
	var handle = _vertexHandles[index]
		
	var vtxScreen = camera.unproject_position(handle.committedPosition)
	var mag = (screen_point - vtxScreen).length()
	
	var spatialTrans = _gizmo.get_spatial_node().global_transform
	var lPos = handle.committedPosition
	var dir = (screen_point - vtxScreen).normalized()
	
	var vScreenUp = camera.unproject_position(lPos + spatialTrans.basis.y)
	var vScreenRight = camera.unproject_position(lPos + spatialTrans.basis.x)
	var vScreenFw = camera.unproject_position(lPos + spatialTrans.basis.z)
	var vScreenDown = camera.unproject_position(lPos + -spatialTrans.basis.y)
	var vScreenLeft = camera.unproject_position(lPos + -spatialTrans.basis.x)
	var vScreenBack = camera.unproject_position(lPos + -spatialTrans.basis.z)
	
	var aToUp = rad2deg(dir.angle_to((vScreenUp - vtxScreen).normalized())) + 45.0
	var aToRight = rad2deg(dir.angle_to((vScreenRight - vtxScreen).normalized())) + 45.0
	var aToFw = rad2deg(dir.angle_to((vScreenFw - vtxScreen).normalized())) + 45.0
	var aToDown = rad2deg(dir.angle_to((vScreenDown - vtxScreen).normalized())) + 45.0
	var aToLeft = rad2deg(dir.angle_to((vScreenLeft - vtxScreen).normalized())) + 45.0
	var aToBack = rad2deg(dir.angle_to((vScreenBack - vtxScreen).normalized())) + 45.0
	
	var toAxis = Vector3.ZERO

	if(aToUp >= 25 and aToUp <= 65):		
		toAxis = spatialTrans.basis.y
	elif(aToRight >= 25 and aToRight <= 65):		
		toAxis = spatialTrans.basis.x
	elif(aToFw >= 25 and aToFw <= 65):		
		toAxis = spatialTrans.basis.z
	elif(aToDown >= 25 and aToDown <= 65):		
		toAxis = -spatialTrans.basis.y
	elif(aToLeft >= 25 and aToLeft <= 65):		
		toAxis = -spatialTrans.basis.x
	elif(aToBack >= 25 and aToBack <= 65):		
		toAxis = -spatialTrans.basis.z
		
	var newPos: Vector3 = handle.localPosition + (toAxis * 0.25)
	newPos = Vector3(stepify(newPos.x, 0.5), stepify(newPos.y, 0.5), stepify(newPos.z, 0.5))
	
	if (handle.localPosition != newPos):	
		_gizmo.set_cursor_3d(newPos)
		# emit_signal("VERTEX_POSITION_CHANGED", index, newPos)
		# test create new mesh
		if (handle.faceId >= 0 and handle.faceVertexIndex > 0):
			var spatial = _gizmo.get_spatial_node()			
			var face = spatial.GetFaceById(handle.faceId)
			if (face != null):
				var sourceVertex = face.GetVertexByIndex(handle.faceVertexIndex)
				prints("Source", sourceVertex)
				var sharingFaces = spatial.GetFacesWithVertex(sourceVertex)				
				for f2 in sharingFaces:
					var vIndices: PoolIntArray = f2.GetVertexIndices(sourceVertex)
					for vIndex in vIndices:
						prints("face", f2.Id, "vIndex", vIndex, "from", f2.GetVertexByIndex(vIndex), "to", newPos)
						f2.set_point(vIndex, newPos)					
				
				meshTools.CreateMeshFromFaces(spatial.get_editor_state().get_faces(), spatial.mesh, spatial.mesh.surface_get_material(0))
	pass
	
# do preparation here
func set_active():
	_gizmo.clear()
	_gizmo.hide_cursor_3d()
	pass
	
# do cleanup here
func set_inactive():
	_gizmo.clear()
	_gizmo.hide_cursor_3d()
	pass
	
# editor mouse click events
func gizmo_forward_mouse_button(event, camera):
	if event.get_button_index() == BUTTON_LEFT:
		print("click", event.get_global_position())
	return false	

# editor mouse click events
func gizmo_forward_mouse_move(event, camera):	
	return false
	
class VertexHandleData:
	var id: int
	var localPosition: Vector3 = Vector3.ZERO
	var committedPosition: Vector3 = Vector3.ZERO
	var faceId: int
	var faceVertexIndex: int # 0-3