extends Node2D

var sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = $Sprite2D
	#print("echo born at ", position)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sprite.set_modulate( Color(1,1,1, sprite.get_modulate().a - delta) )
	scale -= Vector2(delta, delta)
	
	# Destroy self once transparent
	if sprite.get_modulate().a <0:
		#print("echo dies at ", position)
		queue_free()
