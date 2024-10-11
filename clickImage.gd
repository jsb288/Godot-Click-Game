extends Area2D

# NODE PARAMETERS
var speed = 500 	 		# player speed while not clicking
var default_color = Color(1,1,1,1)

# NODE INTERNAL VARIABLES
var mouse_down = false
var space_down = false
var is_immune = false
var right_down = false
var mouse_position = Vector2(0,0)
var screen_size
var anim_progress = 0		# progress of the shake animation to jump back to
var portal_down = false		# is a portal currently placed (using right click)
var portal_before_press = false	# was there a portal placed before current right click

# NODE COUNTERS and COOLDOWNS
# "counter": [is_active, time_elapsed, duration, is_completed] 
var counters = {
	"space_immunity": [false, 0, 3, false],
	"space_cooldown": [false, 0, 3, false],
	"recovery_iframes": [false, 0, 3, false] # how much time the player is immune after a hit (in seconds)
}

# EXTERNAL NODES
@onready var animator = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var portal = $"../portal"
@onready var portal_sprite = $"../portal/Sprite2D"

func _ready():
	resize()
	#resize boundaries whenever the viewport dimensions change
	get_tree().get_root().size_changed.connect(resize)

func _process(_delta):
	var move_any = Input.is_action_pressed("move_left") or \
					Input.is_action_pressed("move_right") or \
					Input.is_action_pressed("move_up") or \
					Input.is_action_pressed("move_down")
	
#	if Time.get_ticks_msec()%1000 <= 10:
#		print("mouse: ", mouse_down, ", move: ", move_any, ", anim: ", anim_progress)

	# make the player green when space is down
	if space_down:
		sprite.set_modulate( Color(0,1,0,1) )
	# else reset color 
	else:
		sprite.set_modulate( default_color )
	
	# play shake animation if trying 2 actions at once (moving, clicking, spacebar)
	if (space_down and (move_any or mouse_down or (right_down and portal_before_press))) \
		or (mouse_down and move_any):
		if !animator.is_playing():
			animator.play("shake")
			animator.seek(anim_progress)
	# else save point in animation and stop it
	elif animator.is_playing():
		anim_progress = animator.current_animation_position
		animator.stop()

# Follow the mouse while left-clicking,
# Use WASD controls otherwise
func _physics_process(delta):
	if Input.is_action_pressed("move_space"):
		
		#print("space ", Time.get_ticks_msec())
		pass
	elif mouse_down:
		position = mouse_position
	else:
		var velocity = Vector2.ZERO
		
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
		
		position = (position + velocity * delta).clamp(Vector2.ZERO, screen_size)
	
	# tick down for each cooldown,
	# reset and stop a cooldown if it finishes
	count_down(delta)
	
	# reset default color when the iframes are completed
	if count_is_complete("recovery_iframes"):
		default_color = Color(1,1,1,1)
		count_reset("recovery_iframes")
	
	# check for collision with hurtbox
	if !space_down and !counters["recovery_iframes"][0] and has_overlapping_bodies():
		hurt()

func _input(event):
	if event is InputEventKey:				# if a key is pressed/unpressed
		if event.get_key_label() == 32:		# if spacebar
			space_down = event.pressed
	if event is InputEventMouseButton:		# if a mouse button is pressed
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_down = event.pressed
		if event.button_index == MOUSE_BUTTON_RIGHT:
			right_down = event.pressed
			if event.pressed:
				if portal_down:
					portal_pickup()
				else:
					portal_place()
			else:
				portal_before_press = portal_down
	elif event is InputEventMouseMotion:	# if the mouse moves
		mouse_position = event.position

# resize image boundaries based on viewport dimentions
func resize():
	screen_size = get_viewport_rect().size

# for every active counter
#	increment by time elapsed,
#	reset and stop a counter if it finishes
func count_down(delta):
	for c in counters:
		if counters[c][0] == true:
			counters[c][1] += delta
			if counters[c][1] >= counters[c][2]:
				print(c, " completed its count")
				counters[c][0] = false
				counters[c][3] = true

# start the counter named in the parameter
func count_start(count_name):
	counters[count_name][0] = true

# reset the counter named in the parameter
func count_reset(count_name):
	counters[count_name] = [ false, 0, counters[count_name][2], false ]

# return whether the counter named in the parameter is actively counting
func count_is_counting(count_name):
	return counters[count_name][0]

# return whether the counter named in the parameter has finished counting
func count_is_complete(count_name):
	return counters[count_name][3]

func hurt():
	print("HIT! GAME OVER")
	default_color = Color(1,0,0,1)
	count_start("recovery_iframes") # start iframes

# place a portal at the mouse's position
func portal_place():
	portal.position = get_viewport().get_mouse_position()
	portal_sprite.set_modulate( Color(1,0,1,1) )
	portal_down = true

# teleport the player to the portal then remove the portal
func portal_pickup():
	if !space_down:
		position = portal.position
		portal_sprite.set_modulate( Color(1,0,1,0) )
		portal_down = false
