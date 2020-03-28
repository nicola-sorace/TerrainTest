extends "res://scripts/Terrain.gd"

const TOOL_SHADER = preload("TerrainToolShader.tres")

onready var map_view = get_node("../ViewportContainer/MapViewport")
onready var map_cam = map_view.get_node("MapCamera")

func _ready():
	._ready()
	set_block_dist(4)
	terrain_material.set_next_pass(TOOL_SHADER)
	
	map_cam.set_size(TS)
	#map_view.set_size(Vector2(TS,TS))
	#gen_minimap()

func gen_map():
	var map = Image.new()
	map.create(img.get_width(), img.get_height(), true, Image.FORMAT_RGB8)#Image.FORMAT_BPTC_RGBA)
	
	set_block_dist(0)
	TOOL_SHADER.set_shader_param("active", false)
	set_physics_process(false)
	
	for y in range(0, int(map.get_height()/TS)):
		for x in range(0, int(map.get_width()/TS)):
			map_cam.set_translation(Vector3((x+0.5)*TS, 100, (y+0.5)*TS))
			urgent_update = true
			update([x, y])
			yield(get_tree(), "idle_frame")  # Lets camera position update
			var shot = map_view.get_texture().get_data()
			shot.flip_x()
			shot.convert(map.get_format())
			map.blit_rect(shot, Rect2(Vector2(0,0), shot.get_size()), Vector2(x*TS, y*TS))
	map.save_png("res://maps/"+game.map_name+"/map.png")
	
	set_block_dist(4)
	TOOL_SHADER.set_shader_param("active", true)
	set_physics_process(true)

func alter_point(p, d):
	img.set_pixelv(p, Color(d, 0, 0))

func update_rect(rect):
	var coords = []
	
	for y in range( int(rect.position.y/TS), int(rect.end.y/TS)+1 ):
		for x in range( int(rect.position.x/TS), int(rect.end.x/TS)+1 ):
			coords.append([x,y])
	
	var i=0
	for t in tiles:
		if t != null:
			for i in range(len(coords)):
				var c = coords[i]
				if t.x == c[0] and t.y == c[1]:
					t.set_res(t.res, true)
					coords.remove(i)
					break
		i+=1

# Store current image data in history queue
func save_img_hist():
	pass