extends Node2D

# 24x16

var tile_data : Array
var clear : bool = false
var in_monsters : Array = []
var inter_targets : Array = []

# Pointer------------
var tiles : TileMap

# # = 벽타일, . = 바닥타일
const WALL_TILE_TERRAIN = 1
const FLOOR_TILE_TERRAIN = 0

func _ready():
	tiles = $tiles
	set_tiles()

	if is_battlefield() == true:
		clear = false
	else:
		set_doors()
		clear = true
		
func _process(delta):
	if clear == true:
		for obj in inter_targets:
			obj.is_clear = true
	
	for monster in in_monsters:
		if is_instance_valid(monster) == false:
			in_monsters.erase(monster)
			
	for target in inter_targets:
		if is_instance_valid(target) == false:
			inter_targets.erase(target)
	
	if in_monsters.size() == 0 and is_battlefield() == true:
		clear = true
	
	for area in $room.get_overlapping_areas():
		if area.name == "player" and area.get_parent() is Player:
			Info.room_in_player_pos = global_position
			if is_battlefield() == true and has_node("doors") == false:
				set_doors()

	var connected_dir : Array = []
	var rooms = get_tree().current_scene.find_child("all_rooms").get_children()
	var rooms_pos : Array = []

	for room in rooms:
		rooms_pos.append(room.global_position)

	if clear == true and has_node("doors") == true:
		if global_position + Vector2(448, 0) in rooms_pos and get_node("doors").has_node("right") == true:
			get_node("doors").get_node("right").queue_free()
		if global_position + Vector2(-448, 0) in rooms_pos and get_node("doors").has_node("left") == true:
			get_node("doors").get_node("left").queue_free()
		if global_position + Vector2(0, 256) in rooms_pos and get_node("doors").has_node("down") == true:
			get_node("doors").get_node("down").queue_free()
		if global_position + Vector2(0, -256) in rooms_pos and get_node("doors").has_node("up") == true:
			get_node("doors").get_node("up").queue_free()

func set_doors():
	var doors_path = preload("res://assets/objects/structures/doors.tscn")
	var doors = doors_path.instantiate()
	add_child(doors)
	inter_targets.append(doors)


func is_battlefield():
	for data in tile_data:
		if "X" in data:
			return true
	return false

func set_tiles():
	for y in tile_data.size():
		for x in tile_data[y].length():
			var char = tile_data[y][x]

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
				var path_names = Cfile.get_filesPath("res://assets/data/monsters/", ".json")
				#path_names[randi_range(0, path_names.size()-1)].get_file().get_basename()
				in_monsters.append(Command.summon_monster(path_names[randi_range(0, path_names.size()-1)].get_file().get_basename(), global_position - Vector2(224, 128) + Vector2(x * 16 + 8, y * 16 + 8)))
			elif char == "C":
				var chest_path = preload("res://assets/objects/entities/chest.tscn")
				var chest = chest_path.instantiate()
				chest.global_position = global_position - Vector2(224, 128) + Vector2(x * 16 + 8, y * 16 + 8)
				get_tree().current_scene.find_child("all_entities").add_child(chest)
				inter_targets.append(chest)
				
			if char != "#":
				tiles.set_cells_terrain_connect(2, [Vector2i(x, y)], 0, FLOOR_TILE_TERRAIN)


