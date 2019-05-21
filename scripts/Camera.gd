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

var dist = 10  # Camera distance
var dir = deg2rad(180)  # y-rotation
var ang = 0  # Altitude angle

var rotating_view = false
var rotating_play = false
var casting = false
var last_mouse = Vector2(0,0)
var mouse_hit = {}  # Stores latest mouse-ray collision info

func _ready():
	set_cursor(C_NORMAL)

func _process(delta):
	
	if rotating_view or rotating_play:
		var mouse = get_viewport().get_mouse_position()
		var diff = mouse - last_mouse
		dir -= diff.x/100
		ang -= diff.y/100
		last_mouse = mouse
		if rotating_play: game.player.set_rotation(Vector3(0,dir,0))
	
	set_translation(Vector3(0, 2, 0))
	set_rotation(Vector3(ang, dir, 0)-game.player.get_rotation())
	translate_object_local(Vector3(0, 0, dist))
	
	if get_global_transform().origin.y <= game.WATER_LEVEL:
		shader.set_shader_param("shader", 1)
	else:
		shader.set_shader_param("shader", 0)

func update_mouse_hit():
	var mouse = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse)
	var to = from + project_ray_normal(mouse) * 100
	mouse_hit = get_world().get_direct_space_state().intersect_ray(from, to, [game.player], 1)
	
	if not mouse_hit.empty() and mouse_hit.collider.is_class("Entity"):
		var obj = mouse_hit.collider
		
		if obj.is_class("Actor"):
			actor_tooltip.activate(obj, unproject_position(obj.get_translation()+Vector3(0,2.5,0)))
		else: actor_tooltip.deactivate()
		
		if obj.action == game.Entity.A_OPEN:
			if obj.inventory.empty(): set_cursor(C_OPEN_E)
			else: set_cursor(C_OPEN_F)
		
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
					if obj != null and obj.is_class("Entity") and (obj.get_translation()-game.player.get_translation()).length() <= game.MELEE_RANGE:
						obj.use()
				rotating_play = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		dist += float(event.button_index == BUTTON_WHEEL_DOWN)-float(event.button_index == BUTTON_WHEEL_UP)
	
	elif event is InputEventMouseMotion:
		update_mouse_hit()
		if casting and not mouse_hit.empty():
			game.player.casting(mouse_hit)
		if Input.is_mouse_button_pressed(BUTTON_RIGHT) and (last_mouse-get_viewport().get_mouse_position()).length()>20:
			rotating_play = true
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)