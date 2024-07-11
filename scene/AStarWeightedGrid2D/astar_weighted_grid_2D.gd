class_name AStarWeightedGrid2D extends AStarGrid2D

var tile_map : TileMapLayer

func _init(tile_map : TileMapLayer) -> void:
	load_from(tile_map)
	#--- Nope. Jump Point Search produces a SLD path rather than grid-aligned, meaning it clips
	#---	corners of tiles instead of spending full time in the tile. 
	#---	Can't accurately calculate diagonals cost when using weighted links.
	# NOTE: User can turn this on after construction. Not sure how to stop that so oh well. Bad paths for them.
	jumping_enabled = false
	
func load_from(tile_map : TileMapLayer):
	self.tile_map = tile_map

func _compute_cost(from_id: Vector2i, to_id: Vector2i) -> float:
	#var terrain_cost = get_terrain_cost(to_id)
	var terrain_cost = get_terrain_cost(from_id)
	if is_diagonal(from_id, to_id):
		#--- Weird number courtsey of Pythagoras.
		#terrain_cost *= 1.41422
		terrain_cost *= 1.5
		#print("that's diagonal, new cost=" + str(terrain_cost))
	#print("_compute_cost from=" + str(from_id) + " to=" + str(to_id) + " is " + str(terrain_cost))
	return terrain_cost

func is_diagonal(from: Vector2i, to: Vector2i) -> bool:
	#--- Vector distance requires a squareroot, more expensive than the alternative.
	#var distance = (from - to).length()
	var is_diagonal = (abs(from.x - to.x) + abs(from.y - to.y)) > 1
	#print("distance from=" + str(from) + " to=" + str(to) + " is " + str(distance))
	return is_diagonal

#func _estimate_cost(from_id: Vector2i, to_id: Vector2i) -> float:
	##print("_estimate_cost")
	#if is_point_solid(to_id):
		#return 999999
	#return get_terrain_cost(to_id)

func get_terrain_cost(map_coord : Vector2i) -> float:
	var tile_data : TileData = tile_map.get_cell_tile_data(map_coord)
	var terrain_cost = tile_data.get_custom_data("terrain_cost")
	if null == terrain_cost:
		print("No terrain_cost for " + str(map_coord))
		return 999999
	return terrain_cost
