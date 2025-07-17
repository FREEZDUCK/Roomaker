extends Control

@export var slot_active : Texture2D
@export var slot_default : Texture2D

var is_open : bool = false
var is_empty : bool = true
var is_full : bool = false
var slots : Array
var select_slot : Control
var passive_slot : Array
var active_slot : Control
var catalyst_slot : Array
var catalyst_open : bool = false
var target_door: Node2D = null

# Pointer
var item_des : Control
var current_item_des_state := "inventory"  # 기본값


func _ready():
	Info.inventory = self  # 전역 접근용 등록

	item_des = $item_des
	slots = $slot_grid.get_children()
	passive_slot = $passive_slot.get_children()
	active_slot = $active_slot
	catalyst_slot = $catalyst_slot.get_children()


func _process(delta):
	_control_slots()
	_control_item_des()
	_check_full()
	_check_empty()

	if Input.is_action_just_pressed("insert"):
		if is_open and select_slot and select_slot.held_itemName != "":
			var item_data = Cfile.get_jsonData("res://assets/data/items/" + select_slot.held_itemName + ".json")
			if item_data.has("type") and item_data["type"] == "catalyst":
				var catalyst_slot_node = $catalyst_slot.get_child(0)
				if catalyst_slot_node.held_itemName == "":
					insert_to_catalyst_slot(select_slot.held_itemName)
					select_slot.held_itemName = ""
				else:
					pass


	if Input.is_action_just_pressed("inventory"):
		if is_open:
			visible = false
			$catalyst_panel.visible = false
			$catalyst_slot.visible = false
		else:
			visible = true
			$catalyst_panel.visible = false
			$catalyst_slot.visible = false
		is_open = !is_open

	elif Input.is_action_just_pressed("pick_up"):
		if Info.near_dropItem != null:
			var item_name = Info.near_dropItem.itemName
			var item_type = Info.near_dropItem.itemType
			var success = Command.give_item(item_name)
			if success:
				Info.near_dropItem.queue_free()
				Info.near_dropItem = null
				if item_type == "active":
					give_item_to_ui(item_name)

	elif Input.is_action_just_pressed("item_drop") and select_slot != null and select_slot.held_itemName != "":
		var item_name = select_slot.held_itemName
		var item_data = Cfile.get_jsonData("res://assets/data/items/" + item_name + ".json")
		var item_type = ""
		if item_data.has("type"):
			item_type = item_data["type"]

		Command.summon_item(item_name, Info.player_pos)
		select_slot.held_itemName = ""
		
		if item_type == "active":
			give_item_to_ui("")  # 슬롯 비웠으니 이미지 제거
		Skill.call(item_data["drop_func"]["name"], item_data["drop_func"]["args"])

func has_item(item_name : String):
	for slot in slots:
		if slot.held_itemName == item_name:
			return true
	for p_slot in passive_slot:
		if p_slot.held_itemName == item_name:
			return true
	if active_slot.held_itemName == item_name:
		return true
	return false
		
func _control_item_des():
	if select_slot != null and select_slot.held_itemName != "":
		item_des.visible = true
		var item_data = Cfile.get_jsonData("res://assets/data/items/" + select_slot.held_itemName + ".json")
		item_des.text = Command.stylize_description(item_data["name"], item_data["subname"], item_data["type"],item_data["des"], item_data["ability"], current_item_des_state)
	elif select_slot == null or select_slot.held_itemName == "":
		item_des.text = "체력 ㅣ " + str(Info.player_hp) + "\n" + "스피드 ㅣ " + str(Info.player_movement_speed) + "\n" + "공격력 ㅣ " + str(Info.player_attack_damage) + "\n" + "밀치기 ㅣ " + str(Info.player_knockback_force) + "\n"

func _control_slots():
	var all_slots = slots + passive_slot + [active_slot] + catalyst_slot
	for slot in all_slots:
		var slot_panel = slot.find_child("panel")
		if slot_panel != null:
			var slot_center_pos = slot.global_position + Vector2(slot_panel.size.x/2, slot_panel.size.y/2)
			if slot_center_pos.distance_to(get_global_mouse_position()) < slot_panel.size.x / 2 and is_open:
				select_slot = slot
				slot_panel.texture = slot_active
				return
			else:
				slot_panel.texture = slot_default
		else:
			print("slot에 panel이 없음:", slot.name)

func _check_full():
	var all_slots = slots + passive_slot + [active_slot] + catalyst_slot
	for slot in all_slots:
		if slot.held_itemName == "":
			is_full = false
			return
	is_full = true

func _check_empty():
	var all_slots = slots + passive_slot + [active_slot] + catalyst_slot
	for slot in all_slots:
		if slot.held_itemName != "":
			is_empty = false
			return
	is_empty = true

func give_item_to_ui(item_name: String):
	var ui = get_node("/root/play_scene/front_ui")
	if ui and ui.has_method("update_active_icon"):
		ui.update_active_icon(item_name)

func show_catalyst_panel():
	if $catalyst_panel.visible:
		$catalyst_panel.visible = false
		$catalyst_slot.visible = false
		visible = false
		is_open = false
		current_item_des_state = "inventory"
		return

	$catalyst_panel.visible = true
	$catalyst_slot.visible = true
	current_item_des_state = "catalyst"
	if not is_open:
		visible = true
		is_open = true

	# 아이템 설명 표시
	if select_slot != null and select_slot.held_itemName != "":
		var item_data = Cfile.get_jsonData("res://assets/data/items/" + select_slot.held_itemName + ".json")
		item_des.text = Command.stylize_description(
			item_data["name"], item_data["subname"], item_data["type"],
			item_data["des"], item_data["ability"], current_item_des_state
		)
		item_des.visible = true
	else:
		item_des.visible = false


		
func insert_to_catalyst_slot(item_name: String):
	var catalyst_slot = $catalyst_slot.get_child(0)
	if catalyst_slot.held_itemName == "":
		catalyst_slot.held_itemName = item_name
		current_item_des_state = "inventory"
	else:
		print("이미 촉매 슬롯이 찼습니다.")
		
func set_target_door(door):
	target_door = door

func _on_button_pressed():
	var catalyst_slot = $catalyst_slot/catalyst_slot
	if catalyst_slot.held_itemName != "":
		if target_door:
			Command.new_room(str(randi_range(0, 30)), target_door.name)
			target_door.queue_free()
			target_door = null  # 문 참조 해제

		# catalyst 사용 처리
		catalyst_slot.held_itemName = ""

		# UI 닫기
		$catalyst_panel.visible = false
		$catalyst_slot.visible = false
		visible = false
		is_open = false
