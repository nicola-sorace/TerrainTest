extends "../scripts/Spell.gd"

func _ready():
	title = "Meele Attack"
	icon = load("res://icons/sword.png")
	energy = 5
	cast_time = 1.5
	hp = 10
	can_move = true

func start_cast():
	caster.set_anim("Strike")
	damage(c.collider, hp, game.MELEE_RANGE)
	.start_cast()