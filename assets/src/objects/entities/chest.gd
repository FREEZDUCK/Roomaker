extends StaticBody2D

@export var open_range : float = 10

var is_opened := false

@onready var anim_sp : AnimatedSprite2D = $anim_sp

func _process(delta):
	if Info.player_pos.distance_to(global_position) < open_range and is_opened == false:
		anim_sp.play("open")
		is_opened = true

func _on_animation_finished():
	if anim_sp.animation == "open":
		await get_tree().create_timer(0.2).timeout
		Command.summon_item("algiz", global_position - Vector2(0, -1))
