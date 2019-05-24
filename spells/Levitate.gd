extends Spell

var original_can_fly = false  # Just in case caster can already fly, we restore original state

func set_stats():
	title = "Levitate"
	icon = load("res://icons/dash.png")
	
	energy = 25
	cast_time = 5
	dur_time = 30
	dur_energy = 10
	
	original_can_fly = caster.can_fly

func action_start():
	caster.can_fly = true
	can_move = true

func action_stop_always():
	caster.can_fly = original_can_fly
	caster.flying = false
	can_move = false