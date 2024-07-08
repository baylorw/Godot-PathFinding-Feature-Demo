Navigation looks at tiles marked as navigable 
rather than assuming everything is navigable and you mark what isn't.

As a result, if you put a blocking object on top of a navigable tile,
pathfinding will try to go through it and get stuck.

As of July 2024 there is no way to use TileMap navigation layers 
+ NavigationAgent2D to find paths that avoid blocking objects. 
There was a PR opened to fix it in 2022 which never got merged in
and stopped working once 4.0 came out.

NavigationAgent2D appears to be useless for all but the most
basic (single tile layer) uses. It's a dead end.
