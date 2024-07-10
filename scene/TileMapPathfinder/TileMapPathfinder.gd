class_name TileMapPathfinder extends Node

## TileMapLayer should have a Navigation Layer and an optional custom data layer 
##	named terrain_cost (float)
@export var terrain_map : TileMapLayer
@export var blockers_map : TileMapLayer

#--- We could have them pass in the influence objects but we'd have to know
#---	their influence level, decay function and range. Might be better to
#---	ask the user to calculate that data for each influencer, combine them
#---	and submit it as one influence map.
#--- If we combine this with terrain cost/A* then we're assuming high is bad. 
#---	Make them a repulser (avoid danger), not attractor (bomb highest value). 
#---	And we can't do things like identify the front.
@export var influence_map : TileMapLayer
@export var temp_influence_map : TileMapLayer

#--- We could take this as a grid but the player probably has agents in 
#---	a get_children() collection or something not TileMapLayer. 
#--- No value in forcing them to switch that to a grid.
var temp_blockers_by_map_position := {}

## Internally we'll store all this info in... custom array? Can AStar2D take that?
##	TileMapLayer so that AStarGrid2D can take it?
##	Say screw it and implement my own cached Floyd-Djistra algorithm?


func _ready():
	assert(terrain_map, "TileMap hasn't been set.")
	buildGraph()

func buildGraph():
	pass
