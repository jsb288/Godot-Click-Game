extends Node2D

var mouse_down = false
var mouse_position = Vector2(0,0)

# Follow the mouse whenever it moves
func _process(_delta):
	position = mouse_position

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position
