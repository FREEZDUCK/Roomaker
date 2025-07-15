extends CanvasLayer

var off_console : bool = true
var inputBox : LineEdit

var history_command_list : Array = []
var index_num : int = 0

func _ready():
	inputBox = $input

func _process(delta):
	if Input.is_action_just_pressed("console"):
		off_console = !off_console
		if off_console == false:
			inputBox.grab_focus()
			inputBox.text = "/"
			control_des_text()
			inputBox.caret_column = inputBox.text.length()
			index_num = 0
		
	control_visible()
	
	if off_console == false and Input.is_action_just_pressed("ui_up") and index_num < len(history_command_list):
		var reverse_list = history_command_list.duplicate(false)
		reverse_list.reverse()
		inputBox.text = reverse_list[index_num]
		inputBox.caret_column = inputBox.text.length()
		index_num += 1

func control_visible():
	if off_console == true:
		get_tree().paused = false
		visible = false
	elif off_console == false:
		get_tree().paused = true
		visible = true

func control_des_text():
	var monster_names : String = "[b]<몹 이름 리스트>[/b]\n"
	for path in Cfile.get_filesPath("res://assets/data/monsters/", ".json"):
		monster_names += path.get_file().get_basename() + "\n"
	$des2.text = monster_names

func control_command(command_text : String):
	var sp_text = command_text.split(" ")
	if sp_text[0] == '/summon' and len(sp_text) == 4:
		Command.summon_monster(sp_text[1], Info.player_pos + Vector2(int(sp_text[2]), -int(sp_text[3])))
	elif sp_text[0] == '/item' and len(sp_text) == 4:
		Command.summon_item(sp_text[1], Info.player_pos + Vector2(int(sp_text[2]), -int(sp_text[3])))
	elif sp_text[0] == '/giveitem' and len(sp_text) == 2:
		Command.give_item(sp_text[1])
	elif sp_text[0] == '/newroom' and len(sp_text) == 3:
		Command.new_room(sp_text[1], sp_text[2]) 
	elif sp_text[0] == "/particle" and len(sp_text) == 4:
		Command.particle(sp_text[1], Info.player_pos + Vector2(int(sp_text[2]), -int(sp_text[3])), Vector2(0, 0), Color(1, 1, 1, 1))
	elif sp_text[0] == "/state" and len(sp_text) == 3:
		if sp_text[1] == 'damage':
			Info.player_attack_damage = float(sp_text[2])
		elif sp_text[1] == 'knockback':
			Info.player_knockback_force = float(sp_text[2])
		elif sp_text[1] == 'speed':
			Info.player_movement_speed = float(sp_text[2])
		elif sp_text[1] == 'hp':
			Info.player_hp = int(sp_text[2])
		elif sp_text[1] == 'max_hp':
			Info.player_max_hp = int(sp_text[2])
		elif sp_text[1] == 'dash_delay':
			Info.player_dash_delay = float(sp_text[2])
	elif sp_text[0] == "/debug" and len(sp_text) == 2:
		if sp_text[1] == 'dash_master':
			Info.player_dash_delay = 0.01
		elif sp_text[1] == 'invincible':
			Info.player_max_hp = 99999999999
			Info.player_hp = 99999999999
		elif sp_text[1] == 'GOD':
			Info.player_dash_delay = 0.01
			Info.player_max_hp = 99999999999
			Info.player_hp = 99999999999
			Info.player_attack_damage = 99999
			Info.player_knockback_force = 99
			Info.player_movement_speed = 120.0
	elif sp_text[0] == "/projectile" and len(sp_text) == 4:
		Command.summon_projectile(sp_text[1], Info.player_pos + Vector2(int(sp_text[2]), -int(sp_text[3])), Vector2(0, 0))

func _on_input_text_submitted(new_text):
	index_num = 0
	control_command(new_text)
	history_command_list.append(new_text)
	inputBox.clear()
	off_console = !off_console
	
