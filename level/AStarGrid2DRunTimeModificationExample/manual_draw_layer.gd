## A generic render target that you can place at any layer of a scene.
## _draw() calls are rendered to the object that makes draw calls. 
## If main scene's script makes the draw calls, they're drawn under everything else
## and can't be seen. So we use this to get around that.
extends Node2D

var polyline : Array[Vector2]

func clear():
	polyline = []
	queue_redraw()
	
func render_polyline(polyline):
	self.polyline = polyline
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
	draw_circle(last_point, 6, Color.GOLD, true)
	for index in range(1, len(polyline)):
		var current_point = polyline[index]
		#print("drawing from=" + str(last_point) + " to " + str(current_point))
		draw_line(last_point, current_point, Color.MAROON, 3, true)
		draw_circle(current_point, 6, Color.GOLD, true)
		last_point = current_point
