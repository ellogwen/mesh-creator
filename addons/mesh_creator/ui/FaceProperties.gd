tool
extends Panel

signal USER_INPUT

var _mci = null
var _faceId = -1
var _emitSignals = true

func set_mesh_creator_instance(mci):	 	
	_mci = mci
	pass
	
func set_face_id(faceId: int):	
	_faceId = faceId
	pass
	
func get_face_id(): return _faceId

func _ready():
	hide()
	var xVal: Range = $Items/inp_FacePosX
	if not xVal.is_connected("value_changed", self, "on_user_input"):
		xVal.connect("value_changed", self, "on_user_input", [ "CENTER_X" ])
		
	var yVal: Range = $Items/inp_FacePosY
	if not yVal.is_connected("value_changed", self, "on_user_input"):
		yVal.connect("value_changed", self, "on_user_input", [ "CENTER_Y" ])
		
	var zVal: Range = $Items/inp_FacePosZ
	if not zVal.is_connected("value_changed", self, "on_user_input"):
		zVal.connect("value_changed", self, "on_user_input", [ "CENTER_Z" ])
	
	
func update_values():	
	if (_mci == null):
		return
	if (_faceId < 0):
		return
		
	var face = _mci.get_mc_mesh().get_face(_faceId)
	if (face == null):
		return
	
	var centroid: Vector3 = face.get_centroid()		
	
	_emitSignals = false	
	$Items/lbl_FaceMeshId.text = "Face Mesh ID " + str(face.get_mesh_index())
	$Items/lbl_FaceVtxCount.text = "Vertices: " + str(face.get_vertex_count())		
	$Items/inp_FacePosX.value = centroid.x
	$Items/inp_FacePosY.value = centroid.y
	$Items/inp_FacePosZ.value = centroid.z	
	_emitSignals = true
	pass
	
func on_user_input(value, context):
	if not _emitSignals:
		return	
	emit_signal("USER_INPUT", context, value)