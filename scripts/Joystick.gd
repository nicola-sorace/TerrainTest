extends ReferenceRect

# Values expressed as a percentage of screen width:
export(float) var X = 0.05 # Distance from left edge
export(float) var Y = 0.05 # Distance from bottom edge
export(float) var W = 0.2 # Joystick width

var touchID = -1  #Holds touch index, or -1 if inactive.
var v = Vector2(0,0)
var rect

signal input

func _ready():
	connect("draw", self, "paint")
	update()

func paint():
	var S = get_viewport_rect().size
	
	set_position(Vector2( X*S.x, S.y - (W+Y)*S.x ))
	set_size(Vector2( W*S.x, W*S.x ))
	rect = get_rect()
	
	draw_circle(rect.size/2, rect.size.x/2, Color(0.5,0.5,0.5, 0.5))
	if touchID != -1:
		draw_circle((Vector2(v.x,-v.y)+Vector2(1,1))*rect.size/2, 100, Color(1,1,1,0.5))

func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag and (touchID == event.index or touchID == -1):
		emit_signal("input")
		var id = event.index
		var d = event.position - (rect.position+rect.size/2)
		var in_circle = d.length() <= rect.size.x/2
		
		if in_circle and touchID == -1:
			touchID = event.index
		
		if touchID == event.index:
			if in_circle:
				v = d / (rect.size.x/2)
			else:
				v = d.normalized()
			v.y *= -1
		
		if event is InputEventScreenTouch:
			if touchID == -1 and event.pressed and d.length()<rect.size.x/2:
				touchID = id
			if id == touchID and not event.pressed:
				touchID = -1
				v = Vector2(0,0)
		
		update()
