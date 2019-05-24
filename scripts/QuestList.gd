extends Tree

const COMPLETED_COLOR = Color(0.4,0.4,0.4)

var last_item = null

func _ready():
	set_visible(false)

func update():
	var qs = game.player.quests
	
	if qs.empty():
		set_visible(false)
		return
	
	clear()
	var q_item
	var item
	var q_completed
	for q in qs:
		q_completed = true
		q_item = create_item()
		q_item.set_text(0, q.title)
		q_item.set_selectable(0, false)
		for t in q.tasks:
			item = create_item(q_item)
			item.set_text(0, q.get_task_string(t))
			item.set_selectable(0, false)
			if t[q.I_CUR_COUNT] >= t[q.I_COUNT]:  # Task completed
				item.set_custom_color(0, COMPLETED_COLOR)
			else:
				q_completed = false
		if q_completed:
			q_item.set_text(0, q.title+"  (completed)")
			q_item.set_custom_color(0, COMPLETED_COLOR)
	
	last_item = item
	shrink_to_size()
	
	set_visible(true)

func shrink_to_size():
	set_size(Vector2(get_size().x, get_item_area_rect(last_item).end.y+75))