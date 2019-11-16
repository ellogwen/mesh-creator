tool
extends Panel

signal USER_INPUT

var _mci = null
var _edgeId = -1
var _emitSignals = true

func set_mesh_creator_instance(mci):	 	
	_mci = mci
	pass
	
func set_edge_id(edgeId: int):	
	_edgeId = edgeId
	pass
	
func get_edge_id(): return _edgeId

func _ready():
	var xVal: Range = $Items/inp_EdgePosX
	if not xVal.is_connected("value_changed", self, "on_user_input"):
		xVal.connect("value_changed", self, "on_user_input", [ "EDGE_X" ])
		
	var yVal: Range = $Items/inp_EdgePosY
	if not yVal.is_connected("value_changed", self, "on_user_input"):
		yVal.connect("value_changed", self, "on_user_input", [ "EDGE_Y" ])
		
	var zVal: Range = $Items/inp_EdgePosZ
	if not zVal.is_connected("value_changed", self, "on_user_input"):
		zVal.connect("value_changed", self, "on_user_input", [ "EDGE_Z" ])
	
	
func update_values():	
	if (_mci == null):
		return
	if (_edgeId < 0):
		return
		
	var edge = _mci.get_mc_mesh().get_edge(_edgeId)
	if (edge == null):
		return
	
	var centroid: Vector3 = edge.get_center()		
	
	_emitSignals = false	
	$Items/lbl_EdgeMeshId.text = "Edge Mesh ID " + str(edge.get_mesh_index())
	$Items/lbl_EdgeLength.text = "Length: " + str(edge.length())		
	$Items/inp_EdgePosX.value = centroid.x
	$Items/inp_EdgePosY.value = centroid.y
	$Items/inp_EdgePosZ.value = centroid.z	
	_emitSignals = true
	pass
	
func on_user_input(value, context):
	if not _emitSignals:
		return	
	emit_signal("USER_INPUT", context, value)