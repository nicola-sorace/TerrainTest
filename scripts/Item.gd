"""
Anything that can be put in an inventory slot.
Also includes a static method for spawning new items.

All item variations are stored in the 'items' folder.
"""

extends Node
class_name Item
func is_class(type): return type=="Item" or .is_class(type)

var title = "Unknown"
var description = "Simply indescribable."
var icon = null
var stack_size = 1  # Maximum stack size
var cost = 0

var count = 1  # Number of items

static func create_item(type, count = 1):
	var item = load("res://items/"+type+".gd").new()
	item.count = count
	return item

# Does not handle deleting source item, be wary of duplications:
static func give_item(entity, item):
	for k in range(entity.inv_len):
		if not entity.inventory.has(k):
			entity.inventory[k] = item
			entity.emit_signal("inventory_changed")
			return true
	return false  # No space found in inventory

static func give_new_item(entity, type, count=1):
	return give_item(entity, create_item(type, count))

# Searches inventory for item count (in any stack arrangement)
# If found, delete from inventory and return as single stack
static func take_item(entity, type, count = 1):
	var keys_to_delete = []
	var cur_count = 0
	for k in range(entity.inv_len):
		if entity.inventory.has(k):
			var item = entity.inventory[k]
			if item.is_class(type):
				if item.count <= count - cur_count:
					keys_to_delete.append(k)
					cur_count += item.count
					if cur_count == count:
						break
				else:  # Last stack bigger than necessary
					item.count -= count-cur_count
					cur_count = count
					break
	
	if cur_count == count:
		for k in keys_to_delete:
			entity.inventory.erase(k)
		entity.emit_signal("inventory_changed")
		return create_item(type, count)
	else:
		return null  # Entity does not have enough item