extends Node2D
# play_scene에 있는 all_entities 코드

func _process(_delta):
	for node in get_children():
		if node.has_node("hp_bar") == false and node is Monster: # 자식 노드 중 hp 객체를 안 가졌다면
			var hp_bar_path = load("res://assets/objects/gui/hp_bar.tscn")
			var hp_bar = hp_bar_path.instantiate()
			node.add_child(hp_bar)
