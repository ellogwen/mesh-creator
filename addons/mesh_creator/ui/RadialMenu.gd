tool
extends Control

signal radial_menu_canceled
signal radial_menu_action

var _currentActionIndex = -1
var _actions = Array()

func hide_menu():
	hide()
	set_process_input(false)
	
func show_menu():
	show()
	set_process_input(true)
	rect_global_position = get_global_mouse_position() - get_center()

func add_action(name: String, label: String, helpText: String = "") -> void:
	var a = RadialMenuAction.new(name, label)
	a.helpText = helpText
	_actions.push_back(a)	
	
	var actionLabel = Label.new()	
	actionLabel.text = a.label
	
	actionLabel.name = "Action_" + str(_actions.size())
	$Background/Actions.add_child(actionLabel)
	actionLabel.set_owner($Background/Actions)
	
	# update positions
	var segmentSizeDeg = (PI * 2.0) / _actions.size()
	for label in $Background/Actions.get_children():
		var segmentPosDeg = segmentSizeDeg * label.get_index()
		var labelPos = get_center() + (Vector2(cos(segmentPosDeg), sin(segmentPosDeg)) * 85)
		label.rect_position = labelPos - (label.rect_size * 0.5)
	
	pass
	
func _ready():	
	hide_menu()
	pass
	
func reset():
	for node in $Background/Actions.get_children():
		$Background/Actions.remove_child(node)
		node.queue_free()
	_actions.clear()
	_currentActionIndex = -1
	pass
	
func _input(event):
	if event is InputEventMouseMotion:
		var angle = get_global_center().angle_to_point(event.global_position) + PI
		$Background.LineAngle = angle
		_currentActionIndex = angle_deg_to_action_index(rad2deg(angle))				
		_highlight_current_action()	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed  and _currentActionIndex >= 0:
			emit_signal("radial_menu_action", _actions[_currentActionIndex])
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and event.pressed:
			emit_signal("radial_menu_canceled")
	pass
	
func _highlight_current_action():
	var i = 0
	for label in $Background/Actions.get_children():		
		if (i == _currentActionIndex):
			(label as Control).set("custom_colors/font_color", Color.yellow)
		else:
			(label as Control).set("custom_colors/font_color", Color.white)
		i= i + 1
		
func angle_deg_to_action_index(angleDeg: float) -> int:
	if _actions.empty():
		return -1
	var segmentSizeDeg = 360.0 / _actions.size()
	var testAngle = angleDeg + (segmentSizeDeg / 2.0)
	if (segmentSizeDeg == 0):
		return -1
	return int(max(0, min(_actions.size(), int(testAngle / segmentSizeDeg))))
	
func get_center() -> Vector2:
	return Vector2($Background.rect_size.x / 2.0, $Background.rect_size.y / 2.0)
	
func get_global_center() -> Vector2:
	return get_global_transform().get_origin() + get_center()
	
class RadialMenuAction:
	var name: String
	var label: String
	var helpText: String
	
	func _init(name, label):
		self.name = name
		self.label = label
