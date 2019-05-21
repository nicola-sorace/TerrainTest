"""
This object is made available in all namespaces, via the 'game' keyword.
Provides quick and easy access to core game objects (player, HUD etc).
Also stores some game constants.
"""

extends Node

const Item = preload("res://scripts/Item.gd")
const Entity = preload("res://scripts/Entity.gd")

const LABEL = preload("res://gui/Label.tscn")
const WATER_LEVEL = -1
const MELEE_RANGE = 6

onready var player = get_node("/root/root/Player")
onready var cam = player.get_node("Camera")
onready var hud = player.get_node("/root/root/HUD")

onready var sky = get_node("/root/root/WorldEnvironment").get_environment().get_sky()
onready var sun = get_node("/root/root/Sun")
var time = 0.25

func _ready():
	randomize()
	set_time(time)

func set_time(time):
	self.time = time
	sky.set_sun_latitude(180*time)
	sun.set_rotation(Vector3(deg2rad(180+180*time),0,0))