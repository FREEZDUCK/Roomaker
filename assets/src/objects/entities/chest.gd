extends StaticBody2D

@export var open_range : float = 10

var is_opened := false
var is_clear : bool = false
var in_item : String = ""

@onready var anim_sp : AnimatedSprite2D = $anim_sp

func _process(delta):
	if Info.player_pos.distance_to(global_position) < open_range and is_opened == false and is_clear == true:
		anim_sp.play("open")
		is_opened = true

func _on_animation_finished():
	if anim_sp.animation == "open":
		await get_tree().create_timer(0.2).timeout
		var path_names = Cfile.get_filesPath("res://assets/data/items/", ".json")
		Command.summon_item(path_names[randi_range(0, path_names.size()-1)].get_file().get_basename(), global_position - Vector2(-20, -1))
		Command.summon_item("hong", global_position - Vector2(20, -1))
