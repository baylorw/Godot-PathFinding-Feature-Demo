extends Node2D

@onready var terrain_tilemap : TileMapLayer = %GroundTileMap
@onready var blocker_tilemap : TileMapLayer = %WallsTileMap
@onready var shade_tile_map: TileMapLayer = %ShadeTileMap
@onready var tile_borders_tile_map: TileMapLayer = %TileBordersTileMap
@onready var path_tile_map: TileMapLayer = %PathTileMap
@onready var annotations_tile_map: TileMapLayer = %AnnotationsTileMap
@onready var border_size_ddlb: OptionButton = %BorderSizeDDLB

@onready var group_1_start_marker : Marker2D = $SpawnStuff/Group1StartMarker
@onready var group_2_start_marker : Marker2D = $SpawnStuff/Group2StartMarker
@onready var goal_marker : Marker2D = $SpawnStuff/GoalMarker

#var should_show_path := true

var astar_grid = AStarGrid2D.new()

var group_1_start_coord_global : Vector2
var group_1_start_coord_map : Vector2i
var group_1_path_global : Array[Vector2] = []
var group_2_start_coord_global : Vector2
var group_2_start_coord_map : Vector2i
var group_2_path_global : Array[Vector2] = []
var goal_coord_global : Vector2
var goal_coord_map : Vector2i

var path_1_in_map_coords : Array[Vector2i]
var path_2_in_map_coords : Array[Vector2i] 

var spawn_delay_in_wave_ms : float = 500

var covered_tiles_absolute := {}
var tile_data := {}
var should_show_path_arrows := false
var should_show_dim_path_arrows := false
var should_show_animated_path := false
var should_show_path_step := false
var should_show_tile_border_for_covered_path := false
var should_show_tile_border_for_uncovered_path := false
var should_show_tile_border_for_range := false
var desired_tile_border_width := 8
var should_mark_covered_path_tiles := false
var should_mark_covered_non_path_tiles := false
var should_shade_path := false
var should_shade_range := false
var should_dim_shade := false

func _ready():
	build_astar_grid()

	group_1_start_coord_global = group_1_start_marker.position
	group_2_start_coord_global = group_2_start_marker.position
	group_1_start_coord_map = coordinate_global_to_map(group_1_start_coord_global)
	group_2_start_coord_map = coordinate_global_to_map(group_2_start_coord_global)
	goal_coord_map = coordinate_global_to_map(goal_marker.position)

	#--- Force the path line to show.
	calculate_default_paths()
	show_default_paths()
	
	show_annotations()

func show_annotations():
	build_map_data()
	tile_borders_tile_map.tile_data = tile_data
	annotations_tile_map.tile_data  = tile_data
	shade_tile_map.tile_data = tile_data
	shade_tile_map.path_1 = path_1_in_map_coords
	shade_tile_map.path_2 = path_2_in_map_coords
	path_tile_map.tile_data = tile_data
	path_tile_map.path_1 = path_1_in_map_coords
	path_tile_map.path_2 = path_2_in_map_coords
	
	tile_borders_tile_map.clear()
	tile_borders_tile_map.desired_tile_border_width = desired_tile_border_width
	if should_show_tile_border_for_range:
		tile_borders_tile_map.show_range_borders()
	if should_show_tile_border_for_covered_path:
		tile_borders_tile_map.show_path_coverage_borders()
	if should_show_tile_border_for_uncovered_path:
		tile_borders_tile_map.show_path_no_coverage_borders()
	
	shade_tile_map.clear()
	shade_tile_map.show_dim_colors(should_dim_shade)
	if should_shade_path:
		shade_tile_map.show_path_colors()
	if should_shade_range:
		shade_tile_map.show_range_colors()
	
	path_tile_map.clear()
	if should_show_path_arrows:
		path_tile_map.show_path_arrows()
	if should_show_dim_path_arrows:
		path_tile_map.show_dim_path_arrows()
	%Group1Line2D.visible = should_show_animated_path
	%Group2Line2D.visible = should_show_animated_path
	show_default_paths()
	
	annotations_tile_map.clear()
	if should_mark_covered_path_tiles:
		annotations_tile_map.show_path_coverage_targets()
	if should_mark_covered_non_path_tiles:
		annotations_tile_map.show_non_path_coverage_targets()

func build_map_data():
	for tower in get_tree().get_nodes_in_group("towers"):
		#tower.calculate_relative_coverage()
		var tower_tile_coord = coordinate_global_to_map(tower.position)
		for relative_coord in tower.covered_tiles_relative:
			var tile_x = relative_coord.x + tower_tile_coord.x
			var tile_y = relative_coord.y + tower_tile_coord.y
			var absolute_coord = Vector2i(tile_x, tile_y)
			covered_tiles_absolute[absolute_coord] = true
	for covered_tile in covered_tiles_absolute.keys():
		var tile_datum = {
			"in_range": true, 
			"on_path": false
		}
		tile_data[covered_tile] = tile_datum
	#print("tile_data=" + str(tile_data))
	for path_step in path_1_in_map_coords:
		if !tile_data.keys().has(path_step):
			tile_data[path_step] = { "in_range": false }
		tile_data[path_step]["on_path"] = true
	for path_step in path_2_in_map_coords:
		if !tile_data.keys().has(path_step):
			tile_data[path_step] = { "in_range": false }
		tile_data[path_step]["on_path"] = true

func build_astar_grid():
	astar_grid.cell_size = terrain_tilemap.tile_set.tile_size
	astar_grid.region = terrain_tilemap.get_used_rect()
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	#astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
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
	show_annotations()

	var creeps = get_tree().get_nodes_in_group("creeps")
	#print("creeps size=" + str(creeps.size()))
	for creep in creeps:
		var creep_position_map = coordinate_global_to_map(creep.position)
		var path_in_map_coords = astar_grid.get_id_path(creep_position_map, goal_coord_map)
		var path = coords_map_to_global(path_in_map_coords)
		creep.follow(path)

func calculate_default_paths():
	path_1_in_map_coords = astar_grid.get_id_path(group_1_start_coord_map, goal_coord_map)
	#print("path map from=" + str(group_1_start_coord_map) + " to=" + str(goal_coord_map) + " path=" + str(path_in_map_coords))
	#print("path local=" + str(coords_map_to_local(path_in_map_coords)))
	group_1_path_global = coords_map_to_global(path_1_in_map_coords)
	#print("path local=" + str(coords_map_to_global(path_in_map_coords)))
	#print("p1 map" + str(path_in_map_coords))
	#print("repathing... group_1_path_global=" + str(group_1_path_global))
	
	#print("p2 map from=" + str(group_2_start_coord_map) + " to=" + str(goal_coord_map))
	path_2_in_map_coords = astar_grid.get_id_path(group_2_start_coord_map, goal_coord_map)
	group_2_path_global = coords_map_to_global(path_2_in_map_coords)
	#print("p2 map" + str(path_in_map_coords))
	#print("p2 map" + str(p2))
	#print("repathing... group_2_path_global=" + str(group_2_path_global))

func show_default_paths():
	%ManualDrawLayer.clear()
	#%ManualDrawLayer.render_polyline(group_1_path_global.duplicate())
	#%ManualDrawLayer2.render_polyline(group_2_path_global.duplicate())
	%ManualDrawLayer.show_step_number(should_show_path_step, group_1_path_global)
	%ManualDrawLayer2.show_step_number(should_show_path_step, group_2_path_global)
	
	%Group1Line2D.points = PackedVector2Array(group_1_path_global)
	%Group2Line2D.points = PackedVector2Array(group_2_path_global)

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
	#print("new_enemy.position=" + str(new_enemy.position) + " name=" + new_enemy.name)

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
	#for coord_local in coords_local:
		#var coord_global = to_global(coord_local)
		#coords_global.push_back(coord_global)
	coords_global.assign(coords_local.map(to_global))
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
	#print("kill zone entered by " + str(body))
	#if body is PathFollower:
	body.queue_free()

func _on_start_wave_button_pressed() -> void:
	spawn_creeps()


#################################################
# UI EVENTS
#################################################
func _on_show_path_arrows_check_box_toggled(toggled_on: bool) -> void:
	should_show_path_arrows = toggled_on
	show_annotations()

func _on_show_dim_path_arrows_check_box_toggled(toggled_on: bool) -> void:
	should_show_dim_path_arrows = toggled_on
	show_annotations()

func _on_show_animated_path_check_box_toggled(toggled_on: bool) -> void:
	should_show_animated_path = toggled_on
	show_annotations()

func _on_show_path_step_check_box_toggled(toggled_on: bool) -> void:
	should_show_path_step = toggled_on
	show_annotations()

func _on_show_tile_border_for_covered_path_check_box_toggled(toggled_on: bool) -> void:
	should_show_tile_border_for_covered_path = toggled_on
	show_annotations()

func _on_show_tile_border_for_uncovered_path_check_box_toggled(toggled_on: bool) -> void:
	should_show_tile_border_for_uncovered_path = toggled_on
	show_annotations()

func _on_show_tile_border_for_range_check_box_toggled(toggled_on: bool) -> void:
	should_show_tile_border_for_range = toggled_on
	show_annotations()

func _on_border_size_ddlb_item_selected(_index: int) -> void:
	desired_tile_border_width = border_size_ddlb.get_selected_id()
	show_annotations()

func _on_show_marker_for_covered_path_check_box_toggled(toggled_on: bool) -> void:
	should_mark_covered_path_tiles = toggled_on
	show_annotations()

func _on_show_marker_for_not_path_covered_check_box_toggled(toggled_on: bool) -> void:
	should_mark_covered_non_path_tiles = toggled_on
	show_annotations()

func _on_show_shade_path_check_box_toggled(toggled_on: bool) -> void:
	should_shade_path = toggled_on
	show_annotations()

func _on_show_shade_range_check_box_toggled(toggled_on: bool) -> void:
	should_shade_range = toggled_on
	show_annotations()

func _on_show_shade_range_check_box_2_toggled(toggled_on: bool) -> void:
	should_dim_shade = toggled_on
	show_annotations()
