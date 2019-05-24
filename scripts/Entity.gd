"""
Any object in the game world that can be interacted with.
Includes inventory logic.
Handles actions when right-clicked by player (e.g. browse inventory).
"""

extends KinematicBody
class_name Entity
func is_class(type): return type=="Entity" or .is_class(type)

export(String) var title = "Unknown"

# Action type constants:
enum{A_NONE, A_GENERIC, A_TALK, A_OPEN}

var action = A_NONE
var inventory = {}  # Index
var inv_len = 8  # Max. inventory size
var inv_view = null  # Stores inventory popup if open

signal inventory_changed

func use():
	if action == A_OPEN: open_inventory()

func destroy():
	if inv_view != null: inv_view.close()
	queue_free()

func open_inventory(toggle = false):
	if inv_view == null:
		inv_view = game.hud.show_inventory(self)
	elif toggle: inv_view.close()