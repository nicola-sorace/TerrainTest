"""
Any object in the game world that can be interacted with.
Includes inventory logic.
Handles actions when right-clicked by player (e.g. browse inventory).
"""

extends KinematicBody
func is_class(type): return type=="Entity" or .is_class(type)

var title = "Unknown"

# Action type constants:
const A_NONE = 0
const A_GENERIC = 1
const A_TALK = 2
const A_OPEN = 3

var action = A_NONE
var inventory = {}  # Index
var inv_len = 8  # Max. inventory size
var inv_view = null  # Stores inventory popup if open

func use():
	if action == A_OPEN: open_inventory()

func destroy():
	if inv_view != null: inv_view.close()
	queue_free()

func open_inventory(toggle = false):
	if inv_view == null:
		inv_view = game.hud.show_inventory(self)
	elif toggle: inv_view.close()