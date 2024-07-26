## A generic render target that you can place at any layer of a scene.
## _draw() calls are rendered to the object that makes draw calls. 
## If main scene's script makes the draw calls, they're drawn under everything else
## and can't be seen. So we use this to get around that.
extends Node2D

var polyline : Array[Vector2]
var should_draw_step_numbers := false
var should_draw_path := false

var default_font := ThemeDB.fallback_font
var default_font_size := ThemeDB.fallback_font_size

func _ready():
	default_font = ThemeDB.fallback_font
	default_font_size = ThemeDB.fallback_font_size

func clear():
	polyline = []
	should_draw_path = false
	should_draw_step_numbers = false
	queue_redraw()
	
func render_polyline(polyline):
	self.polyline = polyline
	should_draw_path = true
	queue_redraw()

func show_step_number(path : Array[Vector2]):
	self.polyline = path
	should_draw_step_numbers = true
	queue_redraw()
	
func _draw():
	##from = from.normalized() * 100
	##to = to.normalized() * 100
	## blue outer
	#draw_line(from, to , Color(0, 0, 1), 8)
	## white inner
	#draw_line(from, to, Color(1, 1, 1), 3)
	
	if (null == polyline) or polyline.is_empty():
		return
	
	#--- Faster
	#draw_polyline(polyline, Color.GREEN, 1)
	
	#--- Can draw circles on each point
	var last_point = polyline[0]
	if should_draw_path:
		draw_circle(last_point, 6, Color.GOLD, true)
	if should_draw_step_numbers:
		draw_string(default_font, last_point, "1")
	for index in range(1, len(polyline)):
		var current_point = polyline[index]

		if should_draw_path:
			#print("drawing from=" + str(last_point) + " to " + str(current_point))
			draw_line(last_point, current_point, Color.MAROON, 3, true)
			draw_circle(current_point, 6, Color.GOLD, true)
		if should_draw_step_numbers:
			var centered_coord = current_point - Vector2(5,-5)
			draw_string(default_font, centered_coord, str(index))
		
		last_point = current_point
