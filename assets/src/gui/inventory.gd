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

# Pointer --------------
var item_des : Control

func _ready():
	Info.inventory = self
	
	item_des = $item_des
	slots = $slot_grid.get_children()
	passive_slot = $passive_slot.get_children()
	active_slot = $active_slot
	
func _process(delta):
	_control_slots()
	_control_item_des()
	_check_full()
	_check_empty()
	#_check_active()
	
	
	if Input.is_action_just_pressed("inventory"):
		if is_open == true:
			visible = false
		elif is_open == false:
			visible = true
		is_open = !is_open
	elif Input.is_action_just_pressed("pick_up"):
		if Info.near_dropItem != null:
			var item_name = Info.near_dropItem.itemName
			var success = Command.give_item(item_name)
			if success:
				Info.near_dropItem.queue_free()
				Info.near_dropItem = null
				give_item_to_ui(item_name)


	elif Input.is_action_just_pressed("item_drop") and select_slot != null and select_slot.held_itemName != "":
		var item_name = select_slot.held_itemName
		Command.summon_item(item_name, Info.player_pos)
		select_slot.held_itemName = ""
		give_item_to_ui("")  # 슬롯 비웠으니 이미지도 제거
		
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

