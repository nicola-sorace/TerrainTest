extends Item
func is_class(type): return type=="Eyeball" or .is_class(type)

func _init():
	title = "Eyeball"
	description = "You avoid its gaze."
	icon = load("res://icons/eyeball.png")
	cost = 2
	stack_size = 20