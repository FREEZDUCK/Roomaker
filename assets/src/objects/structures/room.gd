extends Node2D

var tile_data : Array

# Pointer------------
var tile : TileMap

# # = 벽타일, . = 바닥타일
const WALL_TILE_ID = 1
const FLOOR_TILE_ID = 0

func _ready():
	tile = $tile
	set_tiles()
	
func set_tiles():
	for y in tile_data.size():
		for x in tile_data[y].length():
			var char = tile_data[y][x]
			var tile_id = -1

			if char == "#":
				tile_id = WALL_TILE_ID
			elif char == ".":
				tile_id = FLOOR_TILE_ID

			if tile_id != -1:
				tile.set_cells_terrain_connect(0, [Vector2i(x, y)], 0, tile_id)
