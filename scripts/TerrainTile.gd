"""
This object is a single terrain 'tile'.
It is created from a section of a terrain image file.
The tile size is defined in the parent 'Terrain' object.
This class also handles LOD based on distance from player.
"""

extends StaticBody

var TERRAIN_MATERIAL = preload("res://materials/Terrain2.tres")

var x
var y
var img
var rect

var col_shape
var mesh_inst
var water

var res = null

"""
func _init(x, y, img, rect):
	self.x = x
	self.y = y
	self.img = img
	self.rect = rect
	
	col_shape = CollisionShape.new()
	mesh_inst = MeshInstance.new()
	#add_child(col_shape)
	#add_child(mesh_inst)
	call_deferred("add_child", col_shape)
	call_deferred("add_child", mesh_inst)
	
	var water = WATER.instance()
	water.set_translation(Vector3(rect.size.x/2, game.WATER_LEVEL, rect.size.y/2))
	#add_child(water)
	call_deferred("add_child", water)
	
	call_deferred("set_translation", Vector3(rect.position.x, 0, rect.position.y))
"""

func init(x, y, img, rect):
	self.x = x
	self.y = y
	self.img = img
	self.rect = rect
	
	col_shape = get_node("CollisionShape")
	mesh_inst = get_node("MeshInstance")
	water = get_node("Water")
	
	water.set_translation(Vector3(rect.size.x/2, game.WATER_LEVEL, rect.size.y/2))
	
	call_deferred("set_translation", Vector3(rect.position.x, 0, rect.position.y))

func set_res(res):
	if res == self.res:
		return
	self.res = res
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.add_smooth_group(true)
	
	for y in range(0, rect.size.y, res):
		for x in range(0, rect.size.x, res):
			add_vertex(st, x, y)
			add_vertex(st, x+res, y)
			add_vertex(st, x, y+res)
			add_vertex(st, x+res, y+res)
			add_vertex(st, x, y+res)
			add_vertex(st, x+res, y)
	
	st.set_material(TERRAIN_MATERIAL)
	st.generate_normals()
	st.index()
	
	call_deferred("load_st", st)  # Changing mesh is not thread safe, needs deferred function
	
	#if res==1: col_shape.set_shape(mesh.create_trimesh_shape())  # Only collide closest tiles
	#else: col_shape.set_shape(null)

func load_st(st):
	var mesh = st.commit()
	mesh_inst.set_mesh(mesh)
	col_shape.set_shape(mesh.create_trimesh_shape())

func add_vertex(st, x, y):
	var g_x = x+rect.position.x  # 'g' for global
	var g_y = y+rect.position.y
	var v = img.get_pixel(g_x,g_y).r
	st.add_uv(Vector2(g_x,g_y))
	st.add_vertex(Vector3(float(x), v*64-32, float(y)))
