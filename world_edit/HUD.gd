extends Control

onready var terrain = get_node("../Terrain")

onready var mode_buts = get_node("Modes").get_children()
onready var action_buts = get_node("Actions").get_children()

onready var submodes = get_node("Submodes")
onready var toolopts = get_node("ToolOptions/VBoxContainer")

var mode = 0
var submode = 0
var opts = [{}]  # Tool options  {name, min, max, step, val}

var terrain_tools = ["Add", "Subtract", "Level", "Flatten"]

func _ready():
	for i in range(len(mode_buts)):
		mode_buts[i].connect("pressed", self, "set_mode", [i])
	for i in range(len(action_buts)):
		action_buts[i].connect("pressed", self, "action", [i])
	submodes.connect("item_selected", self, "set_submode")
	
	set_mode(0)

func set_mode(i):
	mode = i
	
	for j in range(len(mode_buts)):
		mode_buts[j].set_pressed( j == i )
	
	submodes.clear()
	terrain.TOOL_SHADER.set_shader_param("active", false)
	
	match i:
		0:  # Terrain
			terrain.TOOL_SHADER.set_shader_param("active", true)
			for t in terrain_tools:
				submodes.add_item(t)
	
	submodes.select(0)
	set_submode(0)

func set_tool_options(opts):
	self.opts.clear()
	for c in toolopts.get_children():
		toolopts.remove_child(c)
		c.queue_free()
	for i in range(len(opts)):
		var o = opts[i]
		self.opts.append(o)
		
		var label = Label.new()
		label.set_text(o['name'])
		toolopts.add_child(label)
		
		var slider = HSlider.new()
		slider.set_min(o['min'])
		slider.set_max(o['max'])
		slider.set_step(o['step'])
		slider.set_value(o['val'])
		slider.set_ticks(5)
		slider.connect("value_changed", self, "set_tool_value", [i])
		toolopts.add_child(slider)

func set_tool_value(v, i):
	opts[i].val = v

func set_submode(i):
	submode = i
	
	var new_opts = []

	if mode == 0:
		new_opts = ([
				{'name':'Strength', 'min':0, 'max':1, 'step':0.01, 'val':0.5},
				{'name':'Falloff', 'min':0, 'max':1, 'step':0.01, 'val':0.5}
			])
		
		if i == 2:
			new_opts.append({'name':'Level', 'min':0, 'max':1, 'step':0.01, 'val':0.5})
	set_tool_options(new_opts)

# Change height in zone based on current tool settings
func alter_zone_height(p, rad):
	#var falloff = opts[1].val #TODO Use falloff
	
	# Some modes use a weighted average of pixel values
	var mean
	if submode == 3:
		var sum = 0.0
		mean = 0.0
		for y in range(-rad, rad+1):
			for x in range(-rad, rad+1):
				var d = Vector2(x,y).length()/rad
				if d <= 1:
					mean += (1-d)*terrain.get_height(p.x+x, p.y+y)
					sum += 1-d
		mean /= sum
	
	for y in range(-rad, rad+1):
		for x in range(-rad, rad+1):
			var pos = Vector2(x, y)
			var d = pos.length()/rad
			if d <= 1:
				var strength = (1-d) * opts[0].val
				var old_v = terrain.get_height(p.x+x, p.y+y)
				var v
				match submode:
					0: v = old_v + strength * 0.1
					1: v = old_v - strength * 0.1
					2: v = lerp(old_v, opts[2].val, strength)
					3: v = lerp(old_v, mean, strength)
				terrain.alter_height(p+pos, v)

func action(i):
	match i:
		0: terrain.gen_map()
