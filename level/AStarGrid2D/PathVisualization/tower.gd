class_name Tower extends CharacterBody2D

@export var range := 2

#--- Useful if we move, don't have to big loop to recalc absolute
var covered_tiles_relative := {}
#var covered_tiles_absolute := {}

func _ready():
	calculate_relative_coverage()

func calculate_relative_coverage():
	if 0 == range: return
	for x in range(-range, range+1):
		for y in range(-range, range+1):
			if 0==x and 0==y: continue
			if (manhattan_distance(x,y) <= range):
				var relative_tile_coords = Vector2i(x,y)
				covered_tiles_relative[relative_tile_coords] = true
				#var absolute_tile_coord = Vector2i(x+self.position.x, y+self.position.y)
				#covered_tiles_absolute[absolute_tile_coord]= true

func manhattan_distance(relative_x: int, relative_y: int):
	return abs(relative_x)+abs(relative_y)
