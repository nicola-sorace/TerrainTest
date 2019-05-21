"""
Anything that can be put in an inventory slot.
Also includes a static method for spawning new items.
"""

extends Node

# Item type constants:
const T_MISC = 0
const T_CONSUMABLE = 1
const T_WEAPON = 2
const T_WEARABLE = 3

var title = "Unknown"
var description = "Simply indescribable."
var icon = null
var type = T_MISC
var stack_size = 1  # Maximum stack size
var cost = 0

var count = 1  # Number of items

func use(caster):
	pass

static func create_item(name, count = 1):
	var item = load("res://items/"+name+".gd").new()
	item.count = count
	return item