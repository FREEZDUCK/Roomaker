extends CanvasLayer

@export var heart : PackedScene
@export var heart_full : Texture2D
@export var heart_half : Texture2D
@export var detect_item_range : float = 40

var near_dropItem : Area2D

# Pointer----------------
var dash_bar : TextureProgressBar
var heart_container : HBoxContainer
var item_des : Control

func _ready():
	dash_bar = $player_ui/V/dash
	heart_container = $player_ui/V/H
	item_des = $item_des

func _process(delta):
	control_item_des()
	control_dash_bar()
	control_player_heart()

func spawn_heart(spawn_count : int):
	for i in range(spawn_count):
		var heart = heart.instantiate()
		heart_container.add_child(heart)

func control_dash_bar():
	if dash_bar.value == 0:
		dash_bar.visible = false
	elif dash_bar.value != 0:
		dash_bar.visible = true
	dash_bar.value = round((Info.player.dash_timer / Info.player_dash_delay) * 100)

func control_player_heart():
	var spawn_count = int(Info.player_max_hp / 2)
	if Info.player_max_hp % 2 != 0:
		spawn_count += 1

	# 기존 하트 개수와 다르면 전부 삭제 후 다시 생성
	var heart_container_children = heart_container.get_children()
	if spawn_count != heart_container_children.size():
		for heart in heart_container_children:
			heart.queue_free()
		spawn_heart(spawn_count)

	# 다시 불러옴 (기존 배열은 queue_free 무효)
	heart_container_children = heart_container.get_children()

	# 체력 표시
	for i in range(spawn_count):
		var texture_rect = heart_container_children[i].find_child("progress")
		var hp_index = i * 2

		if Info.player_hp >= hp_index + 2:
			texture_rect.texture = heart_full
		elif Info.player_hp == hp_index + 1:
			texture_rect.texture = heart_half
		else:
			texture_rect.texture = null  # 비어 있는 하트

func control_item_des():
	for entity in Info.all_entities:
		if entity is DropItem:
			if Info.near_dropItem == null:
				Info.near_dropItem = entity
			else:
				if entity.global_position.distance_to(Info.player_pos) < Info.near_dropItem.global_position.distance_to(Info.player_pos):
					Info.near_dropItem = entity
	# 가장 가까운 아이템 마저도 플레이어와 거리가 detect_item_range 초과하면 그냥 가까운 아이템 없음
	if Info.near_dropItem != null and Info.near_dropItem.global_position.distance_to(Info.player_pos) > detect_item_range:
		Info.near_dropItem.find_child("outline").visible = false
		Info.near_dropItem = null
		
	if Info.near_dropItem != null:
		item_des.visible = true
		item_des.text = Command.stylize_description(Info.near_dropItem.itemDisplayName, Info.near_dropItem.itemSubName, Info.near_dropItem.itemType, Info.near_dropItem.itemDes, Info.near_dropItem.itemAbility, "dropitem")
		Info.near_dropItem.find_child("outline").visible = true
	elif Info.near_dropItem == null:
		item_des.visible = false
