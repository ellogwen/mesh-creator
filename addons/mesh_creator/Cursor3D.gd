extends Position3D

signal transform_changed

func _notification(what):
	if (what == NOTIFICATION_TRANSFORM_CHANGED):
		emit_signal("transform_changed")