The NavigationAgent2d *MUST* be a direct child of the CharacterBody2D. 
Unlike what some tutorials show, it cannot be anywhere else. 
It must be a child, not a grandchild.

Pathfinding assumes the agent is no bigger than one tile. 
It will create paths that fit through 1-tile gaps and bigger
agents will get stuck and will not re-route.

Navigation agents get stuck on edges a LOT. Options:
1. Set NavigationAgent2d.path_postprocessing=Edgecentered
2. Project Settings -> navigation/2d/default_edge_connection_margin to half a tile width
3. CharacterBody2D.motion_mode=Floating
4. CharacterBody2D.wall_min_slide_angle=0
You might need all of them plus making sure your agent is 1 tile wide.
