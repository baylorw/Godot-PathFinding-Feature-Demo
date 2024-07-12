extends Node2D

@onready var terrain_tilemap : TileMapLayer = %GroundTileMap
@onready var blocker_tilemap : TileMapLayer = %WallsTileMap
@onready var group_1_start_marker : Marker2D = $SpawnStuff/Group1StartMarker
@onready var group_2_start_marker : Marker2D = $SpawnStuff/Group2StartMarker
@onready var goal_marker : Marker2D = $SpawnStuff/GoalMarker

var should_show_path := true

var astar_grid = AStarGrid2D.new()

var group_1_start_coord_global : Vector2
var group_1_start_coord_map : Vector2i
var group_1_path_global : Array[Vector2] = []
var group_2_start_coord_global : Vector2
var group_2_start_coord_map : Vector2i
var group_2_path_global : Array[Vector2] = []
var goal_coord_global : Vector2
var goal_coord_map : Vector2i

var spawn_delay_in_wave_ms : float = 500

func _ready():
	build_astar_grid()

	group_1_start_coord_global = group_1_start_marker.position
	group_2_start_coord_global = group_2_start_marker.position
	group_1_start_coord_map = coordinate_global_to_map(group_1_start_coord_global)
	group_2_start_coord_map = coordinate_global_to_map(group_2_start_coord_global)
	goal_coord_map = coordinate_global_to_map(goal_marker.position)
	#print("goal_marker.position=" + str(goal_marker.position))
	#print("goal_coord_map=" + str(goal_coord_map))
	#print("start=" + str(group_1_start_coord_map) + " end=" + str(goal_coord_map))

	#--- Force the path line to show.
	calculate_default_paths()
	show_default_paths()

func build_astar_grid():
	astar_grid.cell_size = terrain_tilemap.tile_set.tile_size
	astar_grid.region = terrain_tilemap.get_used_rect()
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.default_compute_heuristic  = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar_grid.update()
	
	#--- Remove spots where there is no nav layer.
	# ASSUMPTION: User doesn't want to assume all terrain is navigable and specifies that using
	#			  the built-in nav layer.
	var terrain_positions : Array[Vector2i] = terrain_tilemap.get_used_cells()
	for terrain_position in terrain_positions:
		var tile_data = terrain_tilemap.get_cell_tile_data(terrain_position)
		var nav_shape : NavigationPolygon = tile_data.get_navigation_polygon(0)
		var oc = nav_shape.get_outline_count()
		if oc == 0:
			astar_grid.set_point_solid(terrain_position)

	#--- Remove spots where they can't walk because something is already there.
	var blocker_positions : Array[Vector2i] = blocker_tilemap.get_used_cells()
	for blocker_position in blocker_positions:
		astar_grid.set_point_solid(blocker_position)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://main_menu.tscn")
	elif event.is_action_pressed("left_click"):
		plant_tree()
	elif event.is_action_pressed("right_click"):
		remove_blocker()

func print_mouse_location():
	var mouse_place_g = get_global_mouse_position()
	var l = to_local(mouse_place_g)
	var mt = terrain_tilemap.local_to_map(l)
	var mb = blocker_tilemap.local_to_map(l)
	print("g="+str(mouse_place_g)+" l="+str(l)+" mt="+str(mt)+" mb="+str(mb))

func plant_tree():
	var coord_local = get_local_mouse_position()
	var coord_map = blocker_tilemap.local_to_map(coord_local)
	#--- Sheet 3 tile (0,0) is a wall.
	blocker_tilemap.set_cell(coord_map, 3, Vector2i(0, 0))
	astar_grid.set_point_solid(coord_map)
	repath_creeps()

func remove_blocker():
	var coord_local = get_local_mouse_position()
	var coord_map = blocker_tilemap.local_to_map(coord_local)
	blocker_tilemap.erase_cell(coord_map)
	astar_grid.set_point_solid(coord_map, false)
	repath_creeps()
	
func repath_creeps():
	calculate_default_paths()
	show_default_paths()

	var creeps = get_tree().get_nodes_in_group("creeps")
	print("creeps size=" + str(creeps.size()))
	for creep in creeps:
		var creep_position_map = coordinate_global_to_map(creep.position)
		var path_in_map_coords = astar_grid.get_id_path(creep_position_map, goal_coord_map)
		var path = coords_map_to_global(path_in_map_coords)
		creep.follow(path)

func calculate_default_paths():
	var path_in_map_coords = astar_grid.get_id_path(group_1_start_coord_map, goal_coord_map)
	#print("path map from=" + str(group_1_start_coord_map) + " to=" + str(goal_coord_map) + " path=" + str(path_in_map_coords))
	#print("path local=" + str(coords_map_to_local(path_in_map_coords)))
	group_1_path_global = coords_map_to_global(path_in_map_coords)
	#print("path local=" + str(coords_map_to_global(path_in_map_coords)))
	#print("p1 map" + str(path_in_map_coords))
	#print("repathing... group_1_path_global=" + str(group_1_path_global))
	
	#print("p2 map from=" + str(group_2_start_coord_map) + " to=" + str(goal_coord_map))
	path_in_map_coords = astar_grid.get_id_path(group_2_start_coord_map, goal_coord_map)
	group_2_path_global = coords_map_to_global(path_in_map_coords)
	#print("p2 map" + str(path_in_map_coords))
	#print("p2 map" + str(p2))
	#print("repathing... group_2_path_global=" + str(group_2_path_global))

func show_default_paths():
	%ManualDrawLayer.clear()
	%ManualDrawLayer.render_polyline(group_1_path_global.duplicate())
	%ManualDrawLayer2.render_polyline(group_2_path_global.duplicate())

func spawn_creeps():
	if group_1_path_global.is_empty() or group_2_path_global.is_empty():
		calculate_default_paths()
		show_default_paths()

	for i in 5:
		spawn_creep_at(group_1_start_coord_global, group_1_path_global)
		spawn_creep_at(group_2_start_coord_global, group_2_path_global)
		await get_tree().create_timer(spawn_delay_in_wave_ms / 1000).timeout

func spawn_creep_at(start_position_global : Vector2, path : Array[Vector2]):
	var new_enemy : PathFollower = %PathFollowerPrototype.duplicate()
	new_enemy.add_to_group("creeps")
	new_enemy.position = start_position_global
	%Creeps.add_child(new_enemy, true)
	print("new_enemy.position=" + str(new_enemy.position) + " name=" + new_enemy.name)

	if path.is_empty():
		print("!!! NO PATH FOUND !!! from=" + str(start_position_global) + " to=" + str(goal_coord_global))
		new_enemy. queue_free()
	else:
		#--- Path following is destructive so give each agent their own copy of the path.
		new_enemy.follow(path.duplicate())

func coords_map_to_local(list : Array[Vector2i]) -> Array[Vector2]:
	#--- The word "map" is used for levels, TileMaps, hash tables and collection map/reduce functions. Ugh.
	#--- GDSscript Array.map() doesn't work with types so we use this hack.
	var coords_local  : Array[Vector2] = []
	coords_local.assign(list.map(terrain_tilemap.map_to_local))
	#--- Or we could stop using stupid "functional" programming and do it the supportable way.
	return coords_local

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

func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body is PathFollower:
		body.queue_free()

func _on_start_wave_button_pressed() -> void:
	spawn_creeps()
