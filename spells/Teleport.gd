extends Spell

func set_stats():
	title = "Teleport"
	icon = load("res://icons/teleport.png")
	energy = 70
	cast_time = 4
	dist = 100

func action_start():
	if (caster.get_translation()-c.position).length() <= dist:
		caster.set_translation(c.position + Vector3(0,2,0))