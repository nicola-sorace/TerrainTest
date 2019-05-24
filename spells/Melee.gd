extends Spell

func set_stats():
	title = "Meele Attack"
	icon = load("res://icons/sword.png")
	energy = 5
	cast_time = 1.5
	hp = 10
	can_move = true

func action_start():
	caster.set_anim("Strike")
	damage(c.collider, hp, game.MELEE_RANGE)