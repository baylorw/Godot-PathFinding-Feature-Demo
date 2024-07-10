extends Node2D

@onready var terrain_tilemap : TileMapLayer = %GroundTileMapLayer
@onready var blocker_tilemap : TileMapLayer = %BlockersTileMapLayer
@onready var agent = %PathFollower

var should_show_path := true

var astar_grid = AStarGrid2D.new()

func _ready():
	build_astar_grid()
	
	#--- Show the control values
	%ShowPathCheckButton.button_pressed = should_show_path
	%JumpCheckButton.button_pressed = astar_grid.jumping_enabled
	%COptionButton.selected = astar_grid.default_compute_heuristic
	%HOptionButton.selected = astar_grid.default_estimate_heuristic
	%DiagonalOptionButton.selected = astar_grid.diagonal_mode
	
func build_astar_grid():
	#var tile_size = terrain_tilemap.tile_set.tile_size
	astar_grid.cell_size = terrain_tilemap.tile_set.tile_size
	astar_grid.region = terrain_tilemap.get_used_rect()
	
	#--- We're going to free move, not grid move, but you obviously can't move between blocking walls.
	#		  012
	#		0 X.	You can't get from (0,1) to (1,0) because you can't 
	#		1 .X	squeeze through the Xs.
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	
	#--- What fucking idiot named this a heuristic?
	#--- Euclidean is the default so don't technically have to set this. Doing so for documentation.
	astar_grid.default_compute_heuristic  = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	
	#--- This is just a performance optimization (it does tile compression/culling).
	#--- Has NOTHING to do with jumping.
	#--- If you use this you lose link weights, revert to uniform cost :(.
	astar_grid.jumping_enabled = true

	#--- MUST call this before marking blockers
	astar_grid.update()
	
	#--- Remove spots where they can't walk because something is already there.
	var blocker_positions : Array[Vector2i] = blocker_tilemap.get_used_cells()
	for blocker_position in blocker_positions:
		astar_grid.set_point_solid(blocker_position)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://main_menu.tscn")
	elif event.is_action_pressed("zoom_in"):
		%Camera2D.zoom += Vector2(0.1, 0.1)
	elif event.is_action_pressed("zoom_out"):
		%Camera2D.zoom -= Vector2(0.1, 0.1)
	elif event.is_action_pressed("left_click"):
		start_pathing()

func start_pathing():
	var from = agent.position
	var to   = get_global_mouse_position()
	print("You clicked on global=" + str(to) + " map=" + str(coordinate_global_to_map(to)))

	print("Want a path from " + str(from) + " to " + str(to))
	var path_in_map_coords = astar_grid.get_id_path(coordinate_global_to_map(from), coordinate_global_to_map(to))
	#print("map path=" + str(path_in_map_coords))
	#--- First node (path[0]) is current position, don't need to move to that so get rid of it.
	var path_in_global_coords = coords_map_to_global(path_in_map_coords)
	#print("position=" + str(%PathFollower.position) + " global path=" + str(path_in_global_coords))
	if should_show_path:
		%ManualDrawLayer.clear()
		%ManualDrawLayer.render_polyline(path_in_global_coords.duplicate())
	agent.follow(path_in_global_coords.slice(1))

func coords_map_to_global(list : Array[Vector2i]) -> Array[Vector2]:
	#--- The word "map" is used for levels, TileMaps, hash tables and collection map/reduce functions. Ugh.
	#--- GDSscript Array.map() doesn't work with types so we use this hack.
	var coords_local  : Array[Vector2] = []
	coords_local.assign(list.map(terrain_tilemap.map_to_local))
	#--- Or we could stop using stupid "functional" programming and do it the supportable way.
	var coords_global : Array[Vector2] = []
	for coord_local in coords_local:
		var coord_global = to_global(coord_local)
		coords_global.push_back(coord_global)
	return coords_global

func coordinate_global_to_map(coordinate_global : Vector2i) -> Vector2i:
	var coordinate_local = to_local(coordinate_global)
	var coordinate_map   = terrain_tilemap.local_to_map(coordinate_local)
	return coordinate_map

func coordinate_map_to_global(coordinate_global : Vector2i) -> Vector2i:
	var coordinate_local = to_local(coordinate_global)
	var coordinate_map   = terrain_tilemap.local_to_map(coordinate_local)
	return coordinate_map

func _on_show_path_check_button_toggled(toggled_on: bool) -> void:
	should_show_path = toggled_on
	%ManualDrawLayer.clear()

func _on_jump_check_button_toggled(toggled_on: bool) -> void:
	astar_grid.jumping_enabled = toggled_on

func _on_c_option_button_item_selected(index: int) -> void:
	astar_grid.default_compute_heuristic = index

func _on_h_option_button_item_selected(index: int) -> void:
	astar_grid.default_estimate_heuristic = index

func _on_diagonal_option_button_item_selected(index: int) -> void:
	astar_grid.diagonal_mode = index
