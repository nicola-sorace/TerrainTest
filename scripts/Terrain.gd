"""
This object represents the world map.
It handles the loading of terrain tiles.

TODO:
	- Update existing thread when lagged behind, rather than pausing until it's finished and then spawning new thread
	  -> Requires changing 'get_new_tiles' to handle more-than-one-tile movement & a partially updated tile state
	- Hide seams between tiles of different res
	  -> Easiest method is probably to extrude edges downwards to cover gaps.
	- Load a circular array of tiles rather than a square one (i.e. avoid wasteful corners)
"""

extends Spatial
const TerrainTile = preload("res://scripts/TerrainTile.gd")

# Red channel: Height
const TERRAIN_MATERIAL = preload("res://materials/Terrain2.tres")

var img

const TS = 64  # Tile size

var tiles = []
var N = 13  # Edge length (in tiles) of 'tiles' array. MUST BE ODD!
onready var D = int((N-1)/2)  # Distance from center tile to one of the edges (perpendicularly)

# Last known tile position of player:
var last_x = 0
var last_y = 0

var thread = Thread.new()  # Terrain loading is threaded when possible
var abort_thread = false  # Set to 'true' to force abbandon threaded process

var TILE = preload("res://objects/TerrainTile.tscn")

func create_tile(x,y, res=0):
	var tile = TILE.instance()
	tile.init(x, y, img, Rect2(x*TS, y*TS, TS, TS))
	
	if res!=0:
		tile.set_res(res)
	
	call_deferred("add_child", tile)
	return tile

func _ready():
	img = load("res://maps/test3.png").get_data()
	img.decompress()
	img.lock()
	
	for y in N:
		for x in N:
			tiles.append(create_tile(x,y))

func _physics_process(delta):
	check_update()

func get_res(D):
	if D <= 2: return 1
	elif D <= 3: return 4
	else: return 16

func check_update():
	var pos = game.player.get_translation()
	var x = int(pos.x/TS)
	var y = int(pos.z/TS)
	
	if x != last_x or y != last_y:
		
		if max(abs(x-last_x), abs(y-last_y)) > 1:
			if thread.is_active():  # Too far behind; give up and reload from scratch:
				abort_thread = true
				thread.wait_to_finish()
				abort_thread = false
			reload(x,y)
		else:
			if thread.is_active():  # Falling behind; let thread catch up before continuing:
				thread.wait_to_finish()
			thread.start(self, "update", [x,y, last_x, last_y], Thread.PRIORITY_NORMAL)
		
		last_x = x
		last_y = y

func update(args):
	var x = args[0]
	var y = args[1]
	var last_x = args[2]
	var last_y = args[3]
	
	var add_new_tiles = get_new_tiles(x,y, last_x,last_y)
	for i in range(len(tiles)):
		if abort_thread:
			print("Aborted!")
			return
		var tile = tiles[i]
		var d = max(abs(tile.x-x), abs(tile.y-y))
		if d>D:  # Replace tile with new tile:
			call_deferred("remove_child", tile)
			tile.queue_free()
			add_new_tiles = add_new_tiles.resume(i)
		else:
			tile.set_res(get_res(d))

# Recreate 'tiles' from scratch
func reload(x,y):
	var i = 0
	for y_d in range(-D,D+1):
		for x_d in range(-D,D+1):
			tiles[i].queue_free()
			tiles[i] = create_tile(x+x_d,y+y_d, get_res(max(abs(x_d),abs(y_d))))
			i+=1

"""
func get_new_tiles(x,y, last_x,last_y):
	var x_dir
	if x != last_x:
		x_dir = 1 if x>last_x else -1
		for i in range(-D,D+1): # New right or left edge tiles:
			for j in range(last_x+x_dir*D+1, x+x_dir*D+1):
				tiles[yield()] = create_tile(j, y+i, get_res(D))
	
	if y != last_y:
		var y_dir = 1 if y>last_y else -1
		for i in range(-D,D+1):  # Same for top and bottom, but avoid corner if it's already been done
			for j in range(last_y+y_dir*D+1, y+y_dir*D+1):
				if not (x != last_x and i >= x_dir*D):
					tiles[yield()] = create_tile(x+i, j, get_res(D))

"""
func get_new_tiles(x,y, last_x,last_y):
	var x_dir
	if x != last_x:
		x_dir = 1 if x>last_x else -1
		for i in range(-D,D+1): # New right or left edge tiles:
			tiles[yield()] = create_tile(x+x_dir*D, y+i, get_res(D))
	
	if y != last_y:
		var y_dir = 1 if y>last_y else -1
		for i in range(-D,D+1):  # Same for top and bottom, but avoid corner if it's already been done
			if not (x != last_x and i == x_dir*D):
				tiles[yield()] = create_tile(x+i, y+y_dir*D, get_res(D))
