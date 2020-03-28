"""
This object represents the world map. It handles the loading of terrain tiles.
Terrain data is stored as an image, with the red chanel as height data and green channel as terrain texture index.

TODO:
	- Hide seams between tiles of different res
	  -> Easiest method is probably to extrude edges downwards to cover gaps.
	- Load a circular array of tiles rather than a square one (i.e. avoid wasteful corners)
	- Fix whatever is causing occasional freeze (deadlock?)
"""

extends Spatial

# Red channel: Height
var terrain_material = preload("res://materials/Terrain2.tres")

var img

const TS = 64  # Tile size

var tiles = []

var N  # Edge length (in tiles) of 'tiles' array. MUST BE ODD!
var D  # Distance from center tile to one of the edges (perpendicularly): D = int((N-1)/2)

# Last known tile position of player:
var last_x = 0
var last_y = 0

var thread = Thread.new()  # Terrain loading is threaded to avoid lag
var abort_thread = false  # Set to 'true' to make threaded process quit as soon as possible
var urgent_update = true  # Set to 'true' to force a non-threaded terrain update (used when thread is about to fall behind player)

var TILE = preload("res://objects/TerrainTile.tscn")

func create_tile(x,y, res=0):
	var tile = TILE.instance()
	tile.init(x, y, img, Rect2(x*TS, y*TS, TS, TS), terrain_material)
	
	if res!=0:
		tile.set_res(res)
	
	call_deferred("add_child", tile)
	return tile

func _ready():
	img = load("res://maps/"+game.map_name+"/terrain.png").get_data()
	img.decompress()
	img.lock()
	
	set_block_dist(6)

func _physics_process(delta):
	check_update()

func delete_tile(i):
	var t = tiles[i]
	if t != null:
		call_deferred("remove_child", t)
		t.queue_free()
		tiles[i] = null

func set_block_dist(D):
	self.D = D
	N = D*2+1
	
	for i in range(len(tiles)):
		delete_tile(i)
	
	tiles = []
	for y in N:
		for x in N:
			tiles.append(null)

func get_res(D):
	if D <= 2: return 1
	elif D <= 3: return 4
	else: return 16

func check_update():
	var pos = game.player.translation
	var x = int(pos.x/TS)
	var y = int(pos.z/TS)
	
	if urgent_update:
		print("Jumping")
		update([x,y])
		urgent_update = false
	elif x != last_x or y != last_y:
		if thread.is_active():  # Falling behind; let thread catch up before continuing:
				abort_thread = true
				thread.wait_to_finish()
				abort_thread = false
		thread.start(self, "update", [x,y], Thread.PRIORITY_LOW)
		
		last_x = x
		last_y = y

# - Create array of desired tile coords
# - Iterate over existing tiles:
#   - If tile in array, update res & remove coord from array
#   - Else, delete tile
# - Reiterate over tiles:
#   - If empty, add next coord & delete from array
func update(args):
	var x = args[0]
	var y = args[1]
	var desired_coords = []  # Stores desired tileset in [x,y] tile coordinates
	for y_c in range(y-D, y+D+1):
		for x_c in range(x-D, x+D+1):
			desired_coords.append([x_c,y_c])
	
	for i in range(len(tiles)):
		if abort_thread: return
		var tile = tiles[i]
		if tile != null:
			var d = max(abs(tile.x-x), abs(tile.y-y))
			if d > D:  # Tile is not desired. Remove it:
				delete_tile(i)
			else:  # Tile is desired but already present. Update resolution and remove from list:
				tile.set_res(get_res(d))
				for j in range(len(desired_coords)):
					var c = desired_coords[j]
					if tile.x == c[0] and tile.y == c[1]:
						desired_coords.remove(j)
						break
	
	for c in desired_coords:  # Remaining coords are not currently present and hence must be created:
		if abort_thread: return
		var d = max(abs(c[0]-x), abs(c[1]-y))
		if not urgent_update and d <= 2:  # Nearby tile missing! Force whole map reload without threading:
			urgent_update = true
			return
		for i in range(len(tiles)):
			if tiles[i] == null:
				tiles[i] = create_tile(c[0], c[1], get_res(d))
				break
