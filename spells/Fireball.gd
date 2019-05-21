extends "../scripts/Spell.gd"

func _ready():
	title = "Fireball"
	icon = load("res://icons/fireball.png")
	energy = 15
	cast_time = 4
	hp = 30
	dist = 50
	speed = 100

func start_cast():
	caster.set_anim("Strike")
	projectile_launch()
	.start_cast()