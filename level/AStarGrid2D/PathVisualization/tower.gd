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
			#if (sld(x,y) <= range):
			#if (sld_relaxed(x,y) <= range):
				var relative_tile_coords = Vector2i(x,y)
				covered_tiles_relative[relative_tile_coords] = true
				#var absolute_tile_coord = Vector2i(x+self.position.x, y+self.position.y)
				#covered_tiles_absolute[absolute_tile_coord]= true

func manhattan_distance(relative_x: int, relative_y: int) -> int:
	return abs(relative_x)+abs(relative_y)
## Help smooth out the nipples.
func sld_relaxed(relative_x: int, relative_y: int) -> float:
	var distance : float = sld(relative_x, relative_y)
	var rounded := roundf(distance)
	return rounded
func sld(relative_x: int, relative_y: int) -> float:
	var a2 : float = relative_x*relative_x
	var b2 : float = relative_y*relative_y
	var c2 : float = a2 + b2
	var c  : float = sqrt(c2)
	return c
