tool
extends Control

signal action(action_name)

var popup
var mesh_texture_submenu : PopupMenu = PopupMenu.new()

func _ready():
	var creator = MeshCreator_Signals.get_editor_plugin()
	creator.connect("mode_changed", self, "_on_editor_mode_changed")
	
	$HBox/MODE_MESH.connect("toggled", self, "_on_mode_button_toggle", [ creator.SelectionModes.MESH ])
	$HBox/MODE_VTX.connect("toggled", self, "_on_mode_button_toggle", [ creator.SelectionModes.VERTEX ])
	$HBox/MODE_EDGE.connect("toggled", self, "_on_mode_button_toggle", [creator.SelectionModes.EDGE ])
	$HBox/MODE_FACE.connect("toggled", self, "_on_mode_button_toggle", [ creator.SelectionModes.FACE ])
	
	popup = $HBox/Menu.get_popup()
	popup.connect("id_pressed", self, "_on_popup_id_pressed")
	
	mesh_texture_submenu.set_name("mesh_texture_menu")
	mesh_texture_submenu.add_item("Dark", 100)
	mesh_texture_submenu.add_item("Light", 101)
	mesh_texture_submenu.add_item("Green", 102)
	mesh_texture_submenu.add_item("Red", 103)
	mesh_texture_submenu.add_item("Purple", 104)
	mesh_texture_submenu.add_item("Orange", 105)
	mesh_texture_submenu.connect("id_pressed", self, "_on_mesh_texture_menu_id_pressed")
	popup.add_child(mesh_texture_submenu)
	
	popup.add_item("Add Cube", 0)
	popup.add_item("Open Generators", 1)
	popup.add_separator()
	popup.add_submenu_item("Mesh Texture", "mesh_texture_menu")
	
	
	
func _on_editor_mode_changed():
	var creator = MeshCreator_Signals.get_editor_plugin()
	$HBox/MODE_MESH.set_pressed(creator.SelectionMode == creator.SelectionModes.MESH)
	$HBox/MODE_VTX.set_pressed(creator.SelectionMode == creator.SelectionModes.VERTEX)
	$HBox/MODE_EDGE.set_pressed(creator.SelectionMode == creator.SelectionModes.EDGE)
	$HBox/MODE_FACE.set_pressed(creator.SelectionMode == creator.SelectionModes.FACE)
	
func _on_popup_id_pressed(id):
	match (id):
		0: emit_signal("action", "ADD_CUBE")
		1: emit_signal("action", "OPEN_GENERATORS")

func _on_mesh_texture_menu_id_pressed(id):
	match (id):
		100: MeshCreator_Signals.emit_UI_MESH_CHANGE_TEXTURE(0) # dark
		101: MeshCreator_Signals.emit_UI_MESH_CHANGE_TEXTURE(1) # light
		102: MeshCreator_Signals.emit_UI_MESH_CHANGE_TEXTURE(2) # red
		103: MeshCreator_Signals.emit_UI_MESH_CHANGE_TEXTURE(3) # green
		104: MeshCreator_Signals.emit_UI_MESH_CHANGE_TEXTURE(4) # purple
		105: MeshCreator_Signals.emit_UI_MESH_CHANGE_TEXTURE(5) # orange

func _on_mode_button_toggle(pressed, button_id):
	if (pressed):
		var creator = MeshCreator_Signals.get_editor_plugin()
		match(button_id):
			creator.SelectionModes.MESH: emit_signal("action", "MODE_MESH")
			creator.SelectionModes.VERTEX: emit_signal("action", "MODE_VERTEX")
			creator.SelectionModes.EDGE: emit_signal("action", "MODE_EDGE")
			creator.SelectionModes.FACE: emit_signal("action", "MODE_FACE")
	
