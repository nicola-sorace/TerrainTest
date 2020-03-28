"""
Superclass of all popup windows: inventories, quests, conversations etc.
Handles things like closing when moving too far.
"""

extends WindowDialog
class_name Window

var source = null

func _ready():
	move_to_top()
	connect("focus_entered", self, "move_to_top")
	get_close_button().connect("pressed", self, "close")

func _process(delta):
	if source != null:
		if (game.player.translation-source.translation).length() > game.MELEE_RANGE:
			close()

func close():
	game.hud.play_sound("BagClose")
	queue_free()

func move_to_top():
	get_parent().move_child(self, get_parent().get_child_count()-2)