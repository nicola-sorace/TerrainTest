extends Actor
func is_class(type): return type=="QuestGiver" or .is_class(type)

const QUEST_VIEW = preload("res://gui/Quest.tscn")
var QUEST = preload("res://scripts/Quest.gd")

var quest

func _ready():
	quest = QUEST.new(self)
	action = A_TALK
	set_translation(Vector3(365,70,360))

func use():
	.use()
	if action == A_TALK:
		show_quest()

func show_quest():
	var quest_view = QUEST_VIEW.instance()
	game.hud.add_child(quest_view)
	quest_view.open_conv(quest)