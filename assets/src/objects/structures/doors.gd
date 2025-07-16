extends Node2D

var doors : Array

func _process(delta):
	doors = get_children()
	for door in doors:
		if Input.is_action_just_pressed("inventory") and door.global_position.distance_to(Info.player_pos) < 20:
			door.queue_free()
			Command.new_room(str(randi_range(0, 30)), door.name)
