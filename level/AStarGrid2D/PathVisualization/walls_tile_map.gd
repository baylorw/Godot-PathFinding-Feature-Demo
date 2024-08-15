extends TileMapLayer

var should_show_availability := false
var should_show_grid := true
	#set(value):
		#show_grid(value)
		
var grid_size : Vector2i
var tile_width : int
var grid_color: Color = Color.REBECCA_PURPLE

func _ready():
	grid_size = get_used_rect().size
	tile_width = tile_set.tile_size.x
	show_grid(should_show_grid)
	
func show_grid(should_show : bool):
	should_show_grid = should_show
	queue_redraw()

func show_availability(should_show : bool):
	should_show_availability = should_show
	queue_redraw()

func _draw():
	if should_show_grid:
		_draw_grid_lines()
	if should_show_availability:
		_draw_grid_availibility()

## Draw a thick border around the entire used TileMap area.
func draw_grid_border():
	#--- The tile's coordinate is its BOTTOM RIGHT, not top left, which is fucking weird.
	#---	Have to subtract 1 to get to the top and left side of the tile.
	var min_x_global = -1 * tile_width
	var min_y_global = -1 * tile_width
	var max_x_global = (grid_size.x-1) * tile_width
	var max_y_global = (grid_size.y-1) * tile_width
	
	var top_left     = Vector2i(min_x_global, min_y_global)
	var top_right    = Vector2i(max_x_global, min_y_global)
	var bottom_left  = Vector2i(min_x_global, max_y_global)
	var bottom_right = Vector2i(max_x_global, max_y_global)

	#--- Outerbox
	# TODO: Could do this with a single draw_rect()
	draw_line(top_left, top_right, Color.RED, 5)
	draw_line(top_left, bottom_left, Color.RED, 5)
	draw_line(bottom_left, bottom_right, Color.RED, 5)
	draw_line(top_right, bottom_right, Color.RED, 5)
	
func _draw_grid_lines():
	var start: Vector2i
	var end: Vector2i
	
	var min_x_global = -1 * tile_width
	var min_y_global = -1 * tile_width
	var max_x_global = (grid_size.x-1) * tile_width
	var max_y_global = (grid_size.y-1) * tile_width
	
	#--- Move along X and draw vertical lines down
	#--- The tile's coordinate is its BOTTOM RIGHT, not top left, which is fucking weird.
	#---	Have to subtract 1 to get to the top and left side of the tile.
	for x in range(-1, grid_size.x):
		start = Vector2i(x * tile_width, min_y_global)
		end = Vector2i(x * tile_width, max_y_global)
		draw_line(start, end, grid_color, 2)

	#--- Move along Y and draw horizontal lines across
	for y in range(-1, grid_size.y):
		start = Vector2i(min_x_global, y * tile_width)
		end = Vector2i(max_x_global, y * tile_width)
		draw_line(start, end, grid_color, 2)

func _draw_grid_availibility():
	var color : Color
	for tile_x in range(-1, grid_size.x-1):
		for tile_y in range(-1, grid_size.y-1):
			var global_x = tile_x * tile_width
			var global_y = tile_y * tile_width
			var position_is_empty := is_empty(Vector2i(tile_x, tile_y))
			var r = Rect2(Vector2(global_x, global_y), tile_set.tile_size)
			if position_is_empty:
				color = Color.GREEN
			else:
				color = Color.RED
			color.a = .75
			draw_rect(r, color)

func get_tile_data_at_global(position_global) -> TileData:
	var position_local = to_local(position_global)
	var position_tilemap = local_to_map(position_local)
	var tile_data : TileData = get_cell_tile_data(position_tilemap)
	return tile_data

func is_empty(tile_position : Vector2i) -> bool:
	var source_id = get_cell_source_id(tile_position)
	var is_empty = (-1 == source_id)
	return is_empty

func is_empty_at_global(position_global : Vector2) -> bool:
	var position_local = to_local(position_global)
	var position_tilemap = local_to_map(position_local)
	return is_empty(position_tilemap)
