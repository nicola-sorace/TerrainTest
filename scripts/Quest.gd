"""
Defines any quest.
This object meant to be presented by and 'Actor', for the player to add to their 'quests' list.
The player can then increase the task counts as necessary.
"""

extends Node

var title = "First Steps"
var desc = """Ahoy there, traveler!

You must've come a long way, that sword you've got there looks awfully worn out. Bet you could do with some new equipment...

You see, I used to be quite the adventurer too, but now I'm but a tired old man. I don't even have the strength to climb down this damn hill!

Would you do me a favor? I've been eating nothing but berries and fruit for [i]weeks[/i] now and I sure could do with some nice bacon. I'd even trade you my old sword for some. Heck, I'll throw in a cool spell too! Anything for some decent food.

There's some pigs roaming down there. Think your scrap iron's got a couple more hits left in it?
"""

# Task index constants:
enum{I_TYPE, I_OBJ, I_NAME, I_COUNT, I_CUR_COUNT}

# Task type constants:
enum{T_KILL, T_ITEM, T_ACT}

# Quest tasks
#  (trigger object, human readable name, count required, current count)
# 'trigger object' is given as a class name so that superclasses can be used
var tasks = [
	[T_KILL, "Mob", "pig", 1, 0],
	[T_ITEM, "Flesh", "slice of pork", 1, 0]
]

var reward_items = [["Sword", "Cool sword", 1]]  # Items granted on completion (same format as tasks minus current count)
var reward_misc = ["Levitation spell"]  # Descriptions of any custom rewards (must be handled by overloading 'custom_reward')

onready var start = self
onready var end = self

static func get_task_string(t):
	var prefix
	match t[I_TYPE]:
		T_KILL: prefix =  "Kill "
		T_ITEM: prefix = "Get "
		T_ACT: prefix = ""
	
	if t[I_CUR_COUNT]<t[I_COUNT]:
		return prefix+t[I_NAME]+" ("+str(t[I_CUR_COUNT])+"/"+str(t[I_COUNT])+")"
	else:
		return prefix+t[I_NAME]+" ("+str(t[I_COUNT])+"/"+str(t[I_COUNT])+")"

static func get_task_bbcode(t):
	var prefix
	match t[I_TYPE]:
		T_KILL: prefix =  "- Kill "
		T_ITEM: prefix = "- Get "
		T_ACT: prefix = ""
	
	return prefix+str(t[I_COUNT])+" [b]"+t[I_NAME]+"[/b]\n"

func _init(start, end = null):
	self.start = start
	if end != null:
		self.end = end
	else:
		self.end = start

func is_same_quest(quest):
	if quest.title == title and quest.desc == desc:
		return true
	else:
		return false

func try_complete(actor):
	for t in tasks:
		if t[I_CUR_COUNT]<t[I_COUNT]:
			game.hud.show_warning("You have not completed all tasks.")
			return false
	
	var space = 0
	for k in range(actor.inv_len):
		if not actor.inventory.has(k):
			space += 1
	if space < len(reward_items):
		game.hud.show_warning("Not enough inventory space.")
		return false
	
	complete(actor)
	return true

func custom_reward():
	game.hud.get_node("Spellbar").set_spell(3, "Levitate")

func complete(actor):
	for t in tasks:
		if t[I_TYPE] == T_ITEM:
			game.Item.take_item(actor, t[I_OBJ], t[I_COUNT])
	for r in reward_items:
		game.Item.give_new_item(actor, r[0], r[2])
	custom_reward()
	actor.complete_quest(self)