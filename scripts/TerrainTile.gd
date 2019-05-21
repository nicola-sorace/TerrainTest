"""
This object is a single terrain 'tile'.
It is created from a section of a terrain image file.
The tile size is defined in the parent 'Terrain' object.
This class also handles LOD based on distance from player.
"""

extends StaticBody

var TERRAIN_MATERIAL = preload("res://materials/Terrain2.tres")
var WATER = preload("res://objects/Water.tscn")

var player

var img
var rect
var res

var col_shape
var mesh_inst

func _init(player, img, rect):
	self.player = player
	self.img = img
	self.rect = rect
	
	col_shape = CollisionShape.new()
	mesh_inst = MeshInstance.new()
	add_child(col_shape)
	add_child(mesh_inst)
	set_translation(Vector3(rect.position.x, 0, rect.position.y))
	
	var water = WATER.instance()
	water.set_translation(Vector3(rect.size.x/2, game.WATER_LEVEL, rect.size.y/2))
	add_child(water)
	
	update_LOD()

func _physics_process(delta):
	update_LOD()

func update_LOD():
	var d = (player.get_translation() - (get_translation()+Vector3(rect.size.x/2,0,rect.size.y/2))).length()
	
	var res
	if d<64: res = 1
	elif d<128: res = 2
	elif d<256: res = 8
	else: res = 16
	
	if res != self.res: set_res(res)

func set_res(res):
	self.res = res
	var rect = self.rect
	rect.size += Vector2(res,res)
	var img = self.img.get_rect(rect)
	img.lock()
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.add_smooth_group(true)
	
	for y in range(0, img.get_height()-res, res):
		for x in range(0, img.get_width()-res, res):
			add_vertex(st, img, x, y)
			add_vertex(st, img, x+res, y)
			add_vertex(st, img, x, y+res)
			add_vertex(st, img, x+res, y+res)
			add_vertex(st, img, x, y+res)
			add_vertex(st, img, x+res, y)
	
	st.set_material(TERRAIN_MATERIAL)
	st.generate_normals()
	
	var mesh = st.commit()
	
	mesh_inst.set_mesh(mesh)
	
	#if res==1: col_shape.set_shape(mesh.create_trimesh_shape())  # Only collide closest tiles
	#else: col_shape.set_shape(null)
	
	col_shape.set_shape(mesh.create_trimesh_shape())

func add_vertex(st, img, x, y):
	var v = img.get_pixel(x,y).r
	st.add_uv(rect.position + Vector2(x,y))
	st.add_vertex(Vector3(float(x), v*64-32, float(y)))