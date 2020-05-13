tool
extends Panel

export (float) var LineAngle = 0.0 setget set_line_angle
export (Color) var LineColor = Color.yellow
export (bool) var DrawLine = true

var font = preload("res://addons/mesh_creator/ui/fonts/df_roboto_regular.tres").duplicate()

func _ready():
	font.size = 24

func _draw():	
	var center = get_center()	
	if DrawLine:				
		var endPoint = center + (Vector2(cos(LineAngle), sin(LineAngle)) * 85)
		var angleDeg = rad2deg(LineAngle)
		draw_line(center, endPoint, LineColor)				

func set_line_angle(angle):
	LineAngle = angle
	update()
	
func get_center() -> Vector2:
	return Vector2(self.rect_size.x / 2.0, self.rect_size.y / 2.0)
