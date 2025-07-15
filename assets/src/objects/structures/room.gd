extends Node2D

# 24x16

var tile_data : Array

# Pointer------------
var tiles : TileMap

# # = 벽타일, . = 바닥타일
const WALL_TILE_TERRAIN = 1
const FLOOR_TILE_TERRAIN = 0

func _ready():
	tiles = $tiles
	set_tiles()
	
func _process(delta):
	for area in $room.get_overlapping_areas():
		if area.name == "player" and area.get_parent() is Player:
			Info.room_in_player_pos = global_position

func set_tiles():
	for y in tile_data.size():
		for x in tile_data[y].length():
			var char = tile_data[y][x]
			var tile_terrain_num = -1

			if char == "#":
				tiles.set_cells_terrain_connect(2, [Vector2i(x, y)], 0, WALL_TILE_TERRAIN)
			elif char == ".":
				tiles.set_cells_terrain_connect(2, [Vector2i(x, y)], 0, FLOOR_TILE_TERRAIN)
			elif char == "@":
				tiles.set_cell(1, Vector2i(x, y), 0, Vector2i(randi_range(20, 24), 18))
			elif char == "l":
				tiles.set_cell(1, Vector2i(x, y), 0, Vector2i(5, 19))
				tiles.set_cell(0, Vector2i(x, y-1), 0, Vector2i(5, 18))
			elif char == 'o':
				tiles.set_cell(1, Vector2i(x, y), 0, Vector2i(24, 17))
			elif char == "X":
				Command.summon_monster("wraith", global_position - Vector2(224, 128) + Vector2(x * 16 + 8, y * 16 + 8))
				
			if char != "#":
				tiles.set_cells_terrain_connect(2, [Vector2i(x, y)], 0, FLOOR_TILE_TERRAIN)
			

