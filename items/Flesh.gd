extends Item
func is_class(type): return type=="Flesh" or .is_class(type)

func _init():
	title = "Raw meat"
	description = "Not very appetizing...yet."
	icon = load("res://icons/flesh.png")
	cost = 1
	stack_size = 20