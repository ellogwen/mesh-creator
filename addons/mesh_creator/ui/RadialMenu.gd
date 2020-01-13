tool
extends MeshCreator_UI_Gui3D

signal radial_menu_canceled
signal radial_menu_action

var _currentActionIndex = -1
var _actions = Array()

func add_action(name: String, label: String, helpText: String = "") -> void:
	var a = RadialMenuAction.new(name, label)
	a.helpText = helpText
	_actions.push_back(a)
	
	var segmentSizeDeg = 360.0 / _actions.size()
	var actionLabel = Label.new()
	var labelPos = get_center() + (Vector2(cos(deg2rad(segmentSizeDeg)), sin(deg2rad(segmentSizeDeg))) * 85)
	actionLabel.text = a.label
	actionLabel.rect_position = labelPos
	actionLabel.name = "Action_" + str(_actions.size())
	$RenderSource/Background/Actions.add_child(actionLabel)
	actionLabel.set_owner(get_owner())
	
	pass
	
func _ready():
	MeshCreator_Signals.connect("UI_VIEWPORT_MOUSE_MOTION", self, "on_viewport_mouse_motion")
	MeshCreator_Signals.connect("UI_VIEWPORT_MOUSE_BUTTON", self, "on_viewport_mouse_button")
	add_action("TEST", "Test a")
	add_action("TEST_2", "Test b")
	add_action("TEST_3", "Test c")
	add_action("TEST_4", "Test d")
	pass
    
# tool scripts do not get input propagated in the edited scene
# but, at least, we can work with a signal for now
# unfortunately we cannot consume the event for now, @todo
func on_viewport_mouse_motion(event, camera: Camera):	
	if (event is InputEventMouse):
		var screen_pos = camera.unproject_position(translation)		
		var angle = (event.position - screen_pos).angle()
		$RenderSource/Background.LineAngle = angle
		_currentActionIndex = angle_deg_to_action_index(rad2deg(angle) + 180.0)
		
# tool scripts do not get input propagated in the edited scene
# but, at least, we can work with a signal for now
# unfortunately we cannot consume the event for now, @todo		
func on_viewport_mouse_button(event, camera: Camera):	
	if ((event is InputEventMouseButton) and (event.pressed == false) and (event.button_index == BUTTON_LEFT)):
		prints("Action Index", _currentActionIndex)		
	pass
		
func angle_deg_to_action_index(angleDeg: float) -> int:
	if _actions.empty():
		return -1
	var segmentSizeDeg = 360.0 / _actions.size()
	return int(angleDeg) % int(segmentSizeDeg)
	
func get_center() -> Vector2:
	return Vector2($RenderSource/Background.rect_size.x / 2.0, $RenderSource/Background.rect_size.y / 2.0)
	
class RadialMenuAction:
	var name: String
	var label: String
	var helpText: String
	
	func _init(name, label):
		self.name = name
		self.label = label