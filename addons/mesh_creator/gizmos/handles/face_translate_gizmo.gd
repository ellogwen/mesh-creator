tool
extends Spatial

enum Handles { UP, DOWN, LEFT, RIGHT, FORWARD, BACKWARD }

func _ready():
	if Engine.is_editor_hint():
		$handle_up.connect("mouse_entered", self, "_on_handle_mouse_entered", [ Handles.UP ])
	pass

func _on_handle_mouse_entered(handleType):
	prints("mouse entered handle", handleType)

func _input(event):
	prints("general input", event)
