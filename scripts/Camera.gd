"""
Handles all user input, excluding movement and HUD controls.
This is to say camera movement and all clicks in the game world.
Also handles cursor display and screenspace shaders.
"""

extends Camera

onready var shader = game.hud.get_node("Shader").get_material()
onready var actor_tooltip = game.hud.get_node("ActorTooltip")

# Cursor images:
const C_NORMAL = preload("res://cursors/normal.png")
const C_OPEN_F = preload("res://cursors/open_full.png")
const C_OPEN_E = preload("res://cursors/open_empty.png")
const C_TALK = preload("res://cursors/talk.png")

var dist = 10  # Camera distance
var dir = deg2rad(180)  # y-rotation
var ang = 0  # Altitude angle

var rotating_view = false
var rotating_play = false
var casting = false
var last_mouse = Vector2(0,0)
var mouse_hit = {}  # Stores latest mouse-ray collision info

var underwater = false

func _ready():
	set_cursor(C_NORMAL)

func _get_terrain_height() -> float:
	var hit : Dictionary = get_world().get_direct_space_state().intersect_ray(translation + Vector3(0,500,0), translation + Vector3(0,-500,0), [self], 1)
	if "position" in hit:
		return hit.position.y
	return 0.0

func _process(delta):
	if game.MOBILE:
		var v = game.hud.get_node("JoystickCam").v
		dir += v.x*delta * 2
		ang -= v.y*delta * 2
	elif rotating_view or rotating_play:
		var mouse = get_viewport().get_mouse_position()
		var diff = mouse - last_mouse
		dir -= diff.x/100
		ang -= diff.y/100
		last_mouse = mouse
		if rotating_play: game.player.set_rotation(Vector3(0,dir,0))
	
	set_translation(Vector3(0, 2, 0))
	set_rotation(Vector3(ang, dir, 0)-game.player.get_rotation())
	translate_object_local(Vector3(0, 0, dist))
	translation.y = max(_get_terrain_height()+2, translation.y)
	
	if not get_viewport().is_input_handled():
		update_mouse_hit()
	elif not mouse_hit.empty():  #i.e. if input just became handled
		mouse_hit = {}
		set_cursor(C_NORMAL)
		actor_tooltip.deactivate()
	
	if get_global_transform().origin.y <= game.WATER_LEVEL:
		if not underwater:
			shader.set_shader_param("shader", 1)
			AudioServer.set_bus_effect_enabled(0,0,true)
			AudioServer.set_bus_effect_enabled(0,0,true)
			underwater = true
	else:
		if underwater:
			shader.set_shader_param("shader", 0)
			AudioServer.set_bus_effect_enabled(0,0,false)
			AudioServer.set_bus_effect_enabled(0,0,false)
			underwater = false

func update_mouse_hit():
	var mouse = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse)
	var to = from + project_ray_normal(mouse) * 100
	mouse_hit = get_world().get_direct_space_state().intersect_ray(from, to, [game.player], 1)
	
	if not mouse_hit.empty() and mouse_hit.collider.is_class("Entity"):
		var obj = mouse_hit.collider
		
		if obj.is_class("Actor"):
			actor_tooltip.activate(obj)
		else: actor_tooltip.deactivate()
		
		if obj.action == game.Entity.A_OPEN:
			if obj.inventory.empty(): set_cursor(C_OPEN_E)
			else: set_cursor(C_OPEN_F)
		elif obj.action == game.Entity.A_TALK:
			set_cursor(C_TALK)
		
	else:
		set_cursor(C_NORMAL)
		actor_tooltip.deactivate()

func set_cursor(c):
	Input.set_custom_mouse_cursor(c, Input.CURSOR_ARROW, Vector2(3,3))

func _unhandled_input(event):
	if event is InputEventMouseButton:
		last_mouse = get_viewport().get_mouse_position()
		
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if not mouse_hit.empty():
					casting = true
					game.player.start_cast(mouse_hit)
			else:
				casting = false
				game.player.stop_cast()
		elif event.button_index == BUTTON_RIGHT:
			if not event.pressed:
				if not rotating_play and not mouse_hit.empty():
					var obj = mouse_hit.collider
					if obj != null and obj.is_class("Entity"):
						if (obj.get_translation()-game.player.get_translation()).length() <= game.MELEE_RANGE:
							obj.use()
						elif obj.action != obj.A_NONE:
							game.hud.show_warning("That is too far away.")
				rotating_play = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		dist += float(event.button_index == BUTTON_WHEEL_DOWN)-float(event.button_index == BUTTON_WHEEL_UP)
	
	elif event is InputEventMouseMotion:
		if casting and not mouse_hit.empty():
			game.player.casting(mouse_hit)
		if Input.is_mouse_button_pressed(BUTTON_RIGHT) and (last_mouse-get_viewport().get_mouse_position()).length()>20:
			rotating_play = true
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
