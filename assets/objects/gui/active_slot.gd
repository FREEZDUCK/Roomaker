extends Control

var held_itemName : String # 이 슬롯이 가지고 있는 아이템 이름
var prev_held

func _process(delta):
	load_itemImg()

func load_itemImg():
	# 가지고 있는 아이템의 이미지를 로드하여 표시함
	if held_itemName == "":
		$display.texture = null
		return
	$display.texture = load("res://assets/sprites/items/" + held_itemName + ".png")
