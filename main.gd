extends Node2D

@export var echo_scene: PackedScene

var echo_rate = 0.1
var echo_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(echo_timer)
	echo_timer += delta
	if echo_timer >= echo_rate:
		echo_timer = 0
		var echo = echo_scene.instantiate()
		var original_sprite = $Player/clickImage/Sprite2D
		echo.position = original_sprite.global_position
		echo.set_modulate( Color( original_sprite.get_modulate() ) )
		add_child(echo)
