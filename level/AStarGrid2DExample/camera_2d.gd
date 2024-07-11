extends Camera2D

@onready var level_tilemap : TileMapLayer = %GroundTileMapLayer
@onready var viewport_size = get_viewport().size

var threshold = 50
var step = 2

func _ready():
	var level_region  = level_tilemap.get_used_rect()
	var tile_size     = level_tilemap.tile_set.tile_size
	self.limit_top    = level_tilemap.map_to_local(level_region.position).y - (tile_size.y / 2)
	self.limit_left   = level_tilemap.map_to_local(level_region.position).x - (tile_size.x / 2)
	self.limit_bottom = level_tilemap.map_to_local(level_region.end).y - (tile_size.y / 2)
	self.limit_right  = level_tilemap.map_to_local(level_region.end).x - (tile_size.x / 2)

func _process(_delta):
	var local_mouse_pos = get_local_mouse_position()
	if local_mouse_pos.x < threshold:
		position.x -= step
	elif local_mouse_pos.x > viewport_size.x - threshold:
		position.x += step
	if local_mouse_pos.y < threshold:
		position.y -= step
	elif local_mouse_pos.y > viewport_size.y - threshold:
		position.y += step
