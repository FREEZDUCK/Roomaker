extends Node2D

var doors : Array

func del_door():
	doors = get_children()
	for door in doors:
		if door.global_position.distance_to(Info.player_pos) < 20:
			door.queue_free()
			Command.new_room(str(randi_range(0, 30)), door.name)
