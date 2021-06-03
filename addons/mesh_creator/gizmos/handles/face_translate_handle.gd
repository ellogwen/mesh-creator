tool
extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	prints("ready")
	connect("mouse_entered", self, "on_mouse_entered")
	pass 
	
func on_mouse_entered(ev):
	prints(ev)
