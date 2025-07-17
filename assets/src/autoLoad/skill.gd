extends Node

const delta : float = 0.02

func up_maxHp(value):
	Info.player_max_hp += value[0]

func down_maxHp(value):
	Info.player_max_hp -= value[0]
	
func ansuz_up(a):
	Info.player_max_hp -= 2
	Info.player_attack_damage += 1
	Info.player_movement_speed += 0.1
	
func ansuz_down(a):
	Info.player_max_hp += 2
	Info.player_attack_damage -= 1
	Info.player_movement_speed -= 0.1
