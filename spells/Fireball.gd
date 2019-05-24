extends Spell

func set_stats():
	title = "Fireball"
	icon = load("res://icons/fireball.png")
	energy = 15
	cast_time = 4
	hp = 30
	dist = 50
	speed = 100

func action_start():
	caster.set_anim("Strike")
	projectile_launch()