"""
Spells: Events that can be activated at the cost of the caster's energy.
Handles all spell logic and timing; Caster need not check energy etc.
Uses as inputs a caster and a ray collision dictionary (which in turn holds a
target object plus the exact casting target position).
This class also includes some helper functions that handle common events (deal
damage, launch projectiles etc.)

Use:
	- Use 'set_target' to update spell target whenever necessary.
	- Use 'start_try_casting' to start spell casting (will loop).
	- Use 'stop_try_casting' to finally stop spell casting.
	- If the caster moves, 'caster_moved' should be called.

All spell variations are stored in the 'spells' folder.
"""

extends Node

var PROJECTILE = preload("res://objects/Projectile.tscn")

var title = "Spell"
var icon

var energy = 0
var cast_time = 0
var hp = 0  # Direct HP damage
var can_move = false

var dist = 0  # Spell range
var speed = 0  # Projectile speed

var caster

var c = {}  # Ray collision dictionary

func init(caster):
	self.caster = caster
	_ready()

func set_target(c):
	self.c = c

func caster_moved():
	if not can_move:
		if caster == game.player and not caster.spell_timer.is_stopped():
			game.hud.show_warning("Can't move while casting!")
		stop_try_casting()

func start_try_casting():
	if caster.energy >= energy:
		caster.spell_timer.set_wait_time(cast_time)
		caster.spell_timer.connect("timeout", self, "start_cast")
		caster.spell_timer.start()
	elif caster == game.player:
		game.hud.show_warning("Not enough mana!")

func stop_try_casting():
	caster.spell_timer.stop()
	caster.spell_timer.disconnect("timeout", self, "start_cast")

func start_cast():
	caster.energy -= energy
	casting()

func casting():
	stop_cast()

func stop_cast():
	start_try_casting()

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
