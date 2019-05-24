"""
Spells: Events that can be activated at the cost of the caster's energy.
Handles all spell logic and timing; Caster need not check energy etc (SEE USAGE BELOW)
Uses as inputs a caster and a ray collision dictionary (which in turn holds a
target object plus the exact casting target position).
This class also includes some helper functions that handle common events (deal
damage, launch projectiles etc.)

Usage:
	- 'casting(delta)' must be called regulary when 'casting' is true (this is implemented in the 'Actor' class)
	- Use 'set_target' to update spell target whenever necessary.
		(must be called at least once before 'star_try_casting')
	- Use 'start_try_casting' to start spell casting (will loop).
	- Use 'stop_try_casting' to finally stop spell casting.
	- If the caster moves, 'caster_moved' should be called.

All spell variations are stored in the 'spells' folder.
"""

extends Node
class_name Spell

var PROJECTILE = preload("res://objects/Projectile.tscn")

# Error strings:
const E_ENERGY = "Not enough energy!"  # Not enough energy
const E_MOVED = "Cannot move while casting this!"  # Not enough energy

var title = "Spell"
var icon

var energy = 0
var cast_time = 0
var hp = 0  # Direct HP damage
var can_move = false

# Spells that act for a certain amount of time if held:
var dur_time = 0
var dur_energy = 0  # Energy per second

var dist = 0  # Spell range
var speed = 0  # Projectile speed

var caster
var c = {}  # Ray collision dictionary
var casting = false

# Overloadable methods:
func set_stats():  # Called on init
	pass
func action_start():  # Initial action (after 'time')
	pass
func action_dur(delta):  # Continuous action (during 'dur_time')
	pass
func action_stop_always():  # Always executed after spell
	pass
func action_stop():  # Executed only after fully completed spell
	pass

func init(caster):
	self.caster = caster
	set_stats()

func error(err):
	if caster == game.player:
		game.hud.show_warning(err)

func set_target(c):
	self.c = c

func caster_moved():
	if not can_move and not caster.spell_timer.is_stopped():
			error(E_MOVED)
			stop_try_casting()

func start_try_casting():
	if caster.energy >= energy:
		caster.spell_timer.set_wait_time(cast_time)
		caster.spell_timer.connect("timeout", self, "start_cast")
		caster.spell_timer.start()
	else:
		error(E_ENERGY)

func stop_try_casting():
	action_stop_always()
	caster.spell_timer.stop()
	caster.spell_timer.disconnect("timeout", self, "start_cast")
	caster.spell_timer.disconnect("timeout", self, "stop_cast")
	casting = false

func start_cast():
	caster.energy -= energy
	action_start()
	
	if dur_time != 0:
		casting = true
		caster.spell_timer.set_wait_time(dur_time)
		caster.spell_timer.disconnect("timeout", self, "start_cast")
		caster.spell_timer.connect("timeout", self, "stop_cast")
		caster.spell_timer.start()
	else:
		stop_cast()

func casting(delta):
	var en = dur_energy*delta
	if caster.energy >= en:
		caster.energy -= en
		action_start()
	else:
		error(E_ENERGY)
		stop_try_casting()

func stop_cast():
	stop_try_casting()
	action_stop()
	start_try_casting()  # Loop casting

# Deal direct damage to target
func damage(obj, hp=self.hp, dist = self.dist):
	if obj.is_class("Actor"):
		if dist != 0 and (caster.get_translation()-obj.get_translation()).length() > dist:
			return
		obj.damage(hp, caster)

# Projectile functions
func projectile_launch(hp = self.hp, dist = self.dist):
	var p = PROJECTILE.instance()
	caster.get_parent().add_child(p)
	var cast_source = Vector3(0,1.5,0)+caster.get_translation()
	p.init(self, cast_source, speed*(c.position-cast_source).normalized(), dist)
func projectile_hit(obj, pos):
	damage(obj)
