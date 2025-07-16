extends Control

@export var slot_active : Texture2D
@export var slot_default : Texture2D

@onready var door = preload("res://assets/src/objects/structures/doors.gd").new()
@onready var doors = get_node("/root/play_scene/all_rooms/room/doors")


var is_open : bool = false
var is_empty : bool = true
var is_full : bool = false
var slots : Array
var select_slot : Control
var passive_slot : Array
var active_slot : Control
var catalyst_open : bool = false

# Pointer --------------
var item_des : Control

func _ready():
	Info.inventory = self
	
	item_des = $item_des
	slots = $slot_grid.get_children()
	passive_slot = $passive_slot.get_children()
	active_slot = $active_slot
	add_child(door)
	
func _process(delta):
	_control_slots()
	_control_item_des()
	_check_full()
	_check_empty()
	insert_catalyst()
	
	
	if Input.is_action_just_pressed("inventory"):
		if is_open == true:
			visible = false
			$catalyst_panel.visible = false  # 인벤토리 닫을 때 catalyst_panel 숨기기
		elif is_open == false:
			visible = true
			$catalyst_panel.visible = false  # 인벤토리 열 때 기본은 숨김
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

		
func _control_item_des():
	if select_slot != null and select_slot.held_itemName != "":
		item_des.visible = true
		var item_data = Cfile.get_jsonData("res://assets/data/items/" + select_slot.held_itemName + ".json")
		item_des.text = Command.stylize_description(item_data["name"], item_data["subname"], item_data["type"], item_data["des"], item_data["ability"], "inventory")
	elif select_slot == null or select_slot.held_itemName == "":
		item_des.visible = false
	
func _control_slots():
	var all_slots = slots + passive_slot + [active_slot]
	for slot in all_slots:
		var slot_panel = slot.find_child("panel")
		var slot_center_pos = slot.global_position + Vector2(slot_panel.size.x/2, slot_panel.size.y/2)
		if slot_center_pos.distance_to(get_global_mouse_position()) < slot_panel.size.x / 2 and is_open == true:
			select_slot = slot
			slot_panel.texture = slot_active
			return
		else:
			slot_panel.texture = slot_default
	select_slot = null

func _check_full():
	var all_slots = slots + passive_slot + [active_slot]
	for slot in all_slots:
		if slot.held_itemName == "":
			is_full = false
			return
	is_full = true

func _check_empty():
	var all_slots = slots + passive_slot + [active_slot]
	for slot in all_slots:
		if slot.held_itemName != "":
			is_empty = false
			return
	is_empty = true
		
			
func give_item_to_ui(item_name: String):
	var ui = get_node("/root/play_scene/front_ui")
	if ui and ui.has_method("update_active_icon"):
		# 아이템 이름이 비어 있으면 이미지 제거용 신호 전달
		if item_name == "":
			ui.update_active_icon("")  # 또는 null
		else:
			ui.update_active_icon(item_name)

func insert_catalyst():
	if doors == null:
		return

	for door in doors.get_children():
		if Input.is_action_just_pressed("interaction") and door.global_position.distance_to(Info.player_pos) < 20:
			print("문 인터렉션")
			$catalyst_panel.visible = true
			# 인벤토리가 안 열려 있으면 강제로 열어도 됨
			if not is_open:
				visible = true
				is_open = true

			doors.del_door()
			break

