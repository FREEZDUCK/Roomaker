extends Node2D

var doors : Array

func _process(delta):
	var doors = get_children()
	for door in doors:
		if Input.is_action_just_pressed("interaction") and door.global_position.distance_to(Info.player_pos) < 20:
			if Info.inventory:
				# 문을 지정하고
				Info.inventory.set_target_door(door)
				# 촉매 UI를 연다
				Info.inventory.show_catalyst_panel()
				
