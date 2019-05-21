"""
Describes creature behaviour, i.e. things that spawn, roam around and can be killed for loot.
Includes basic MOB AI such as responding to attacks.
"""

extends "Actor.gd"
func is_class(type): return type=="Mob" or .is_class(type)

var spawn_area = null

var MELEE = preload("res://spells/Melee.gd")

# Temperment constants:
const T_AGRESSIVE = 0  # Attacks on sight
const T_COWARD = 1  # Flees on sight
const T_PASSIVE_AGRESSIVE = 2  # Attacks when attacked
const T_PASSIVE_COWARD = 3  # Flees when attacked

const temperment = T_PASSIVE_AGRESSIVE

func _ready():
	spell = MELEE.new()
	spell.init(self)
	spell.hp *= 0.5
	spell.cast_time *= 2
	set_state(S_ROAM)
	inventory[0] = game.Item.create_item("Flesh")
	inventory[1] = game.Item.create_item("Eyeball")

func damage(hp, attacker = null):
	.damage(hp, attacker)
	if state != S_DEAD:
		if temperment==T_PASSIVE_AGRESSIVE:
			if attacker != null: start_attack(attacker)
			else: timer.start()

func set_state(s):
	.set_state(s)
	if s == S_ROAM:
		target = null
		timer.emit_signal("timeout")

func timeout():
	.timeout()
	if state == S_DEAD:
		spawn_area.mobs.erase(self)
	elif state == S_ROAM:
		target_coords = spawn_area.get_point()
		timer.set_wait_time(rand_range(1, 10))
		timer.start()
	elif state == S_ATTACK:
		if (get_translation()-spawn_area.get_translation()).length() > spawn_area.radius:
			set_state(S_ROAM)