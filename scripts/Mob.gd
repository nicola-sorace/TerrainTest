"""
Describes creature behaviour, i.e. things that spawn, roam around and can be killed for loot.
Includes basic MOB AI such as responding to attacks.
"""

extends Actor
class_name Mob
func is_class(type): return type=="Mob" or .is_class(type)

var spawn_area = null

var MELEE = preload("res://spells/Melee.gd")

# Temperment constants:
enum{T_AGRESSIVE, T_COWARD, T_PASSIVE_AGRESSIVE, T_PASSIVE_COWARD}

const temperment = T_PASSIVE_AGRESSIVE

func _ready():
	spell = MELEE.new()
	spell.init(self)
	spell.hp *= 0.5
	spell.cast_time *= 2
	set_state(S_ROAM)
	game.Item.give_new_item(self, "Flesh")
	game.Item.give_new_item(self, "Eyeball")

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
	if spawn_area != null:
		match state:
			S_DEAD:
				spawn_area.mobs.erase(self)
			S_ROAM:
				target_coords = spawn_area.get_point()
				timer.set_wait_time(rand_range(1, 10))
				timer.start()
			S_ATTACK:
				if (translation-spawn_area.translation).length() > spawn_area.radius:
					disconnect("killed", target, "confirm_kill")
					set_state(S_ROAM)