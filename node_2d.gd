extends Node2D

var astar_grid = AStarGrid2D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	build_astar_grid()
	var start_map = %TileMapLayer.local_to_map(%StartPoint.position)
	var goal_map = %TileMapLayer.local_to_map(%EndPoint.position)
	var path_in_map_coords = astar_grid.get_id_path(start_map, goal_map)
	var path = coords_map_to_global(path_in_map_coords)
	%Line2D.points = PackedVector2Array(path)
	
	
func build_astar_grid():
	astar_grid.cell_size = %TileMapLayer.tile_set.tile_size
	astar_grid.region = %TileMapLayer.get_used_rect()
	#astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	#astar_grid.default_compute_heuristic  = AStarGrid2D.HEURISTIC_EUCLIDEAN
	#astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar_grid.update()

func coords_map_to_global(list : Array[Vector2i]) -> Array[Vector2]:
	var coords_local  : Array[Vector2] = []
	coords_local.assign(list.map(%TileMapLayer.map_to_local))
	var coords_global : Array[Vector2] = []
	coords_global.assign(coords_local.map(to_global))
	return coords_global
