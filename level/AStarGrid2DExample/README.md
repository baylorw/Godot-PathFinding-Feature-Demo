AStar2DGrid is a helper class on to of AStar2D, which doesn't need a grid.

_*What's Special About A Grid?*_ AStar2DGrid makes some assumptions:
1. *Neighbors are within 1 (x,y)*. For example, position (2,2)'s neighbors
are every node within 1 - (1,2), (3,2), (2,1) and (2,3) (and maybe the diagonals).
The computer knows exactly how many neighbors there are and where they are.
Compare that something that isn't a nice, uniform grid, like Europe.
Very few countries have exactly 4 neighbors, 1 in each direction. 
Because of that, if you wanted to make a navigation graph of Europe 
the computer couldn't do it automatically and you'd have to wire it all 
together by hand (or a more complex algorithm). 
Assuming a grid makes finding neighbors easier
2. *A tile is connected to its neighbors*. The tile at (2,2) has 4 neighbors
(or 8 if you count diagonals) and you can get to each of them in one step.
That assumption makes it easy to wire the neighbors together.
This assumption is wrong for lots of games. Suppose (2,2) in on the sidewalk
and (1,2) is the roof of a building. You can walk on both tiles but you can't
take a single step from the sidewalk and end up on the roof. 
You can walk from the roof to the sidewalk in a single step but only if you're really sad.
3. *A tile is only connected to its neigihbors*. The tile at (2,2) is not directly
connected to (8,8). Except if you make a game with teleporters or catapults,
maybe it is. 
4. *Neighbors are one step away*. To be more accurate, the time it takes to
move to your left neighbor is the same as the time it takes to move right.
Which isn't true if you have terrain penalties - sand is slower to move through
than pavement. 

AStarGrid2D is designed for games where all of the above assumptions are true.
If they are, AStarGrid2D can do a lot of things for you automatically.
If they aren't, that's cool, but then you have to do things the hard way.
Meaning, you have to manually say which tiles are connected to which other tiles. 
Which is a lot of work to do by hand and a little more work if you have
some clever automated method to do it. 

Because AStarGrid2D assumes a grid, paths look like a grid. You will move to the
center of each tile, even moving diagonally, instead of clipping through
corners so the resulting path looks like a grid. Using AStarGrid.jumping_enabled
smooths some of that out but not all of it. Not sure why. 
But because it doesn't go fully through each node (unknown amount of time 
in each node) it can't use link weights/terrain costs. 
So you get terrain costs or less griddy (but still griddy) lines. Can't have both.
