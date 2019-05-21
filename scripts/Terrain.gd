"""
This object rapresents the world map.
It handles the loading of terrain tiles.
"""

extends Spatial
const TerrainTile = preload("res://scripts/TerrainTile.gd")

# Red channel: Height
const TERRAIN_MATERIAL = preload("res://materials/Terrain.tres")

onready var player = get_node("/root/root/Player")

var TS = 32  # Tile size

var W = 32  # Map size (in tiles)
var H = 32

func _ready():
	var img = load("res://maps/test3.png").get_data()
	img.decompress()
	
	for y in range(H):
		for x in range(W):
			add_child(TerrainTile.new( player, img, Rect2(x*TS, y*TS, TS, TS) ))