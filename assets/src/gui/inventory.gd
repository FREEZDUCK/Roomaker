extends Control

@export var slot_active : Texture2D
@export var slot_default : Texture2D

var is_open : bool = false
var is_empty : bool = true
var is_full : bool = false
var slots : Array
var active_slot : Control

# Pointer --------------
var item_des : Control

func _ready():
	Info.inventory = self
	
	item_des = $item_des
	slots = $slot_grid.get_children()
	
func _process(delta):
	_control_slots()
	_control_item_des()
	_check_full()
	_check_empty()
	
	if Input.is_action_just_pressed("inventory"):
		if is_open == true:
			visible = false
		elif is_open == false:
			visible = true
		is_open = !is_open
	elif Input.is_action_just_pressed("pick_up"):
		if Info.near_dropItem != null and Info.inventory.is_full == false:
			Command.give_item(Info.near_dropItem.itemName)
			Info.near_dropItem.queue_free()
			Info.near_dropItem = null

	elif Input.is_action_just_pressed("item_drop") and active_slot != null and active_slot.held_itemName != "":
		Command.summon_item(active_slot.held_itemName, Info.player_pos)
		active_slot.held_itemName = ""
		
func _control_item_des():
	if active_slot != null and active_slot.held_itemName != "":
		item_des.visible = true
		var item_data = Cfile.get_jsonData("res://assets/data/items/fragment/" + active_slot.held_itemName + ".json")
		item_des.text = Command.stylize_description(item_data["name"], item_data["type"], item_data["des"], item_data["ability"], "inventory")
	elif active_slot == null or active_slot.held_itemName == "":
		item_des.visible = false
	
func _control_slots():
	for slot in slots:
		var slot_panel = slot.find_child("panel")
		var slot_center_pos = slot.global_position + Vector2(slot_panel.size.x/2, slot_panel.size.y/2)
		if slot_center_pos.distance_to(get_global_mouse_position()) < slot_panel.size.x / 2 and is_open == true:
			active_slot = slot
			slot_panel.texture = slot_active
			return
		else:
			slot_panel.texture = slot_default
	active_slot = null

func _check_full():
	for slot in slots:
		if slot.held_itemName == "":
			is_full = false
			return
	is_full = true

func _check_empty():
	for slot in slots:
		if slot.held_itemName != "":
			is_empty = false
			return
	is_empty = true
