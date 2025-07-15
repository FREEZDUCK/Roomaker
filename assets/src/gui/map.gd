extends Node2D

@export var room_icon : Texture2D
@export var active_room_icon : Texture2D

var center_pos := Vector2(32, 32)
var rooms : Array
var icons : Array

const x_ratio : int = 52
const y_ratio : int = 40

func _process(delta):
	rooms = get_tree().current_scene.find_child("all_rooms").get_children()
	icons = $clip_rect/rooms_icon.get_children()
	
	$clip_rect/rooms_icon.position = -Vector2(Info.room_in_player_pos.x / x_ratio, Info.room_in_player_pos.y / y_ratio)
	
	if icons.size() != rooms.size():
		load_map_icon()
		
	for icon in icons:
		if icon.position == Vector2(Info.room_in_player_pos.x / x_ratio, Info.room_in_player_pos.y / y_ratio) + center_pos:
			icon.texture = active_room_icon
		else:
			icon.texture = room_icon


func load_map_icon():
	for icon in icons:
		icon.queue_free()
	
	for room in rooms:
		var mini_room = Sprite2D.new()
		mini_room.position = Vector2(room.global_position.x / x_ratio, room.global_position.y / y_ratio) + center_pos
		mini_room.texture = room_icon
		$clip_rect/rooms_icon.add_child(mini_room)
	icons = $clip_rect/rooms_icon.get_children()
