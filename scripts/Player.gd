"""
Describes a user-controlled actor ('the player').
Handles keyboard motion and holds a quest list.
"""

extends Actor

onready var quest_list = game.hud.get_node("QuestList")

var quests = []
var done_quests = []  # Prevents re-accepting quests after completion

func add_quest(quest):
	quests.append(quest)
	quest_list.update()
	scan_inventory()
func remove_quest(quest):
	quests.erase(quest)
	quest_list.update()
func complete_quest(quest):
	done_quests.append(quest)
	remove_quest(quest)

func confirm_kill(actor):
	.confirm_kill(actor)
	
	for q in quests:
		for t in q.tasks:
			if t[q.I_TYPE] == q.T_KILL and actor.is_class(t[q.I_OBJ]):
				t[q.I_CUR_COUNT] += 1
				quest_list.update()

func scan_inventory():
	for q in quests:
		for t in q.tasks:
			if t[q.I_TYPE] == q.T_ITEM:
				t[q.I_CUR_COUNT] = 0
				for item in inventory.values():
					if item != null and item.is_class(t[q.I_OBJ]):
						t[q.I_CUR_COUNT] += item.count
	quest_list.update()

func _ready():
	connect("inventory_changed", self, "scan_inventory")
	
	inv_len = 20
	speed = 5
	swim_speed = 2
	anim = get_node("Visual/AnimationPlayer")
	anim.set_default_blend_time(0.1)
	set_anim("Idle-loop")
	
	set_translation(Vector3(360,70,360))
	game.Item.give_new_item(self, "Sword", 2)
	emit_signal("inventory_changed")

func move():
	var dir = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_up") - Input.get_action_strength("move_down"),
		Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	)
	
	#return to_global(dir)-get_translation()  # Move based on player direction
	return dir.rotated(Vector3(0,1,0), game.cam.dir)  # Move based on camera direction