"""
Anything with a healthbar.
This handles health, energy, casting spells and movement.
Simple states and targets can be set (attack target, move to point etc).
No AI is included (actor stays still by default).
"""

extends Entity
class_name Actor
func is_class(type): return type=="Actor" or .is_class(type)

const DECAY_TIME = 60

var timer = Timer.new()  # General action timer (next roam target, decay time etc.)
var spell_timer = Timer.new()  # Handles spell casting timing
var anim = null  # Holds animation player

var max_health = 100
var health = max_health
var health_regen = 1
var max_energy = 100
var energy = max_energy
var energy_regen = 2

var speed = 4
var swim_speed = 1.5
var fly_speed = 10
var g = Vector3(0, -9.81, 0)  # Gravity (but const. velocity)

var v = Vector3(0,0,0)
var underwater = false
var flying = false
var can_fly = false
var spell = null  # Active spell (ready to cast)

var target_coords = null  # Vector3
var target = null  # Actor

# State constants:
enum {S_NONE, S_ROAM, S_ATTACK, S_FLEE, S_DEAD}

var state = S_NONE

signal killed

func point_at(c):  # Takes ray collision dictionary
	point_in(c.position-get_translation())
func point_in(dir):
	set_rotation(Vector3(0, -(Vector2(dir.x, dir.z).angle()+PI/2), 0))

func move():  # Returns movement direction vector
	if state == S_ATTACK:
		target_coords = target.get_translation()
	if target_coords != null:
		var d = target_coords - get_translation()
		if not (underwater or can_fly): d.y = 0
		if d.length() > game.MELEE_RANGE*0.7:
			point_in(d)
			return d
	return Vector3(0,0,0)

func start_attack(obj):
	if obj != target:
		target = obj
		start_cast({'collider':obj, 'position':obj.get_translation()})
		set_state(S_ATTACK)
	elif state == S_ATTACK:
		timer.start()

func set_state(s):
	timer.stop()
	state = s
	match s:
		S_DEAD:
			set_scale(Vector3(1,0.5,1))
			stop_cast()
			spell = null
			action = A_OPEN
			if DECAY_TIME > 0:
				timer.set_wait_time(DECAY_TIME)
				timer.start()
			emit_signal("killed")
		S_ATTACK:
			timer.set_wait_time(10)
			timer.start()

func timeout():
	if state == S_DEAD:
		destroy()

func set_anim(name):
	if anim != null:
		if anim.assigned_animation != name:
			anim.play(name)

func start_cast(c):
	point_at(c)
	if spell!=null:
		spell.set_target(c)
		spell.start_try_casting()

func casting(c):
	point_at(c)
	if spell!=null: spell.set_target(c)

func stop_cast():
	if spell!=null: spell.stop_try_casting()

func damage(hp, attacker = null):
	if attacker != null:
		connect("killed", attacker, "confirm_kill", [self])
	if state != S_DEAD:
		health -= hp
		var l = game.LABEL.instance()
		l.init(-hp, game.cam.unproject_position(get_translation()+Vector3(0,1,0)))
		game.hud.add_child(l)
		if health <= 0: set_state(S_DEAD)

func confirm_kill(actor):
	pass

func _ready():
	add_child(timer)
	spell_timer.set_one_shot(true)
	add_child(spell_timer)
	timer.connect("timeout", self, "timeout")

func _physics_process(delta):
	
	if state == S_DEAD: return
	
	health += min(max_health-health, health_regen*delta)
	energy += min(max_energy-energy, energy_regen*delta)
	
	underwater = get_translation().y < game.WATER_LEVEL-1
	
	var dir = Vector3(0,0,0)
	if is_on_floor() or underwater or flying:
		v = Vector3(0,0,0)
		dir = move().normalized()
		
		if underwater:
			v += dir * swim_speed
		elif flying:
			if is_on_floor(): flying = false
			else: v += dir * fly_speed
		else:
			if dir.y>0.5:  # Jump
				v.y += 6
				translate(Vector3(0,0.1,0))
				set_anim("Jump")
				dir.y=0
				if can_fly: flying = true
			else: v.y = -5
			v += dir * speed
			
	else: v += g*delta
	
	#move_and_slide(dir.rotated(Vector3(0,1,0), rotation_degrees.y))
	move_and_slide(
		v,
		Vector3(0,1,0),  # Up
		0.5,  # Min. velocity
		4,  # Max. slides
		deg2rad(50)  # Max slope
	)
	
	if spell != null:
		if dir.length() > 0: spell.caster_moved()
		if spell.casting: spell.casting(delta)
	
	#TODO new system:
	if anim != null:
		if not is_on_floor():
			if anim.get_assigned_animation() != "Jump" or not anim.is_playing():
				set_anim("Fall-loop")
		elif anim.get_assigned_animation() != "Strike" or not anim.is_playing():
			var d2d = Vector3(dir.x,0,dir.z).rotated(-Vector3(0,1,0), get_rotation().y)
			if d2d.length() > 0:
				if d2d.z<0: set_anim("Run-loop")
				else: set_anim("RunBack-loop")
			else: set_anim("Idle-loop")
