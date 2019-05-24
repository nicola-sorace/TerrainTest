extends Item
func is_class(type): return type=="Sword" or .is_class(type)

func _init():
	title = "Sword"
	description = "Slashy, stabby, deadly."
	icon = load("res://icons/sword.png")
	cost = 10
	stack_size = 20