extends Node

# 실제 인게임 중에서 계속 공유되어야 하는 값들

# 플레이어 데이터
var player : Player

var player_pos : Vector2
var player_hp : int = 6
var player_max_hp : int = 6
var player_attack_damage : float = 5.5

var player_dash_delay : float = 0.83

var player_knockback_force : float = 1.8
var player_movement_speed : float = 55.0

var inventory : Control
var near_dropItem : Area2D
var all_entities : Array = []

var room_in_player_pos : Vector2 = Vector2(0, 0)

# 풀 스크린 온 오프 / 풀 스크린 키 = F11 or F
var full_screen : bool = false
func _process(_delta):
	if Input.is_action_just_pressed("full_screen"):
		if full_screen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		full_screen = !full_screen
	all_entities = get_tree().current_scene.find_child("all_entities").get_children().duplicate()
		
