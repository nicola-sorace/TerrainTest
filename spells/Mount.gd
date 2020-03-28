extends Spell

var MOUNT = preload("res://mobs/Pig.tscn")
var mounted = false

func set_stats():
	title = "Mount"
	icon = load("res://icons/dash.png")
	
	energy = 25
	cast_time = 5

func action_start():
	if not mounted:
		caster.set_mount(MOUNT)
	else:
		caster.unset_mount()
	
	mounted = not mounted