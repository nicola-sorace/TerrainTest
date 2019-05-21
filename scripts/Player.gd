"""
Describes a user-controlled actor ('the player').
Handles keyboard motion (and holds player stats).
"""

extends "Actor.gd"

func _ready():
	inv_len = 20
	speed = 5
	swim_speed = 2
	anim = get_node("Visual/AnimationPlayer")
	anim.set_default_blend_time(0.1)
	set_anim("Idle-loop")
	
	set_translation(Vector3(360,70,360))
	inventory[0] = game.Item.create_item("Sword", 2)

func move():
	var dir = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_up") - Input.get_action_strength("move_down"),
		Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	)
	
	#return to_global(dir)-get_translation()  # Move based on player direction
	return dir.rotated(Vector3(0,1,0), game.cam.dir)  # Move based on camera direction