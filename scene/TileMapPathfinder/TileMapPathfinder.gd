class_name TileMapPathfinder extends Node

# TODO: Switch to an array of TileMapLayer objects.
# 		What is the new Godot 4.3 TileMap thing?
@export var tileMap : TileMap

func _ready():
	assert(tileMap, "TileMap hasn't been set.")
	buildGraph()

func buildGraph():
	pass
