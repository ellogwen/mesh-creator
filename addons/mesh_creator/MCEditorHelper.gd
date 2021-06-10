tool
extends Spatial

export(bool) var PrintMouseScreen = false
export(bool) var PrintMouseToClosesWorldAxis = false
		
func _process(delta):
	if (Engine.is_editor_hint()):
		if PrintMouseScreen:
			print(get_viewport().get_mouse_position())
		if PrintMouseToClosesWorldAxis:
			_print_mouse_to_closes_world_axis()
		pass
	
func _print_mouse_to_closes_world_axis():	
	var camera = _get_editor_camera()
	var worldCenterToScreen = camera.unproject_position(Vector3.ZERO)
	print (worldCenterToScreen)
	pass
	
func _get_editor_camera():
	print(get_tree().get_edited_scene_root().get_parent().get_camera())
	var cam = get_tree().get_edited_scene_root().get_parent().get_camera()
	
