extends Node

# 커맨드 코드 마인크래프트 커맨드 느낌 함수들
#인벤토리 불러오기
#@export var detect_item_range : float = 40

# 몬스터 소환 함수 / 몬스터 이름, 생성 할 좌표
func summon_monster(monster_name : String, pos : Vector2):
	if get_tree().current_scene.name != 'play_scene':
		return
	
	var monster_data = Cfile.get_jsonData("res://assets/data/monsters/" + monster_name + ".json")

	if monster_data == null:
		Command.error('데이터에 없는 객체입니다.')
		return
	
	var monster_path = preload("res://assets/objects/entities/monster.tscn")
	var monster : Monster = monster_path.instantiate()
	monster.max_hp = monster_data["hp"]
	monster.hp = monster_data["hp"]
	
	monster.speed = monster_data["speed"]
	monster.accel = monster_data["accel"]
	monster.collision_rect = Rect2(monster_data["collision"][0], monster_data["collision"][1], monster_data["collision"][2], monster_data["collision"][3])
	
	monster.detect_range = monster_data["detect_range"]
	
	monster.meleeAttack_damage = int(monster_data["attack"]["damage"])
	monster.attack_method = monster_data["attack"]["method"]
	monster.knockback_force = monster_data["attack"]["knockback"]
	monster.meleeAttack_rect = Rect2(monster_data["attack"]["collision"][0], monster_data["attack"]["collision"][1], monster_data["attack"]["collision"][2], monster_data["attack"]["collision"][3])
	monster.meleeAttack_frames = monster_data["animation"]["attack_frames"]
	monster.meleeAttack_delay = monster_data["attack"]["delay"]
	
	monster.load_animation = load("res://assets/animations/monsters/" + monster_name + ".tres")
	monster.texture_pivot = Vector2(monster_data["animation"]["texture_pivot"][0], monster_data["animation"]["texture_pivot"][1])
	
	if monster_data['attack']['method'] == 'projectile':
		monster.shoot_func = monster_data['attack']["projectile"]["shoot_func"]
		monster.projectile_pos = Vector2(monster_data['attack']["projectile"]["shoot_pos"][0], monster_data['attack']["projectile"]["shoot_pos"][1])
		monster.projectile_name = monster_data['attack']["projectile"]["name"]
		monster.projectile_delay_range = monster_data['attack']["projectile"]["delay"]
		monster.shoot_frames = monster_data['animation']["shoot_frames"]
	
	monster.global_position = pos
	
	get_tree().current_scene.find_child("all_entities").add_child(monster)
	return monster

func summon_projectile(project_name : String, pos : Vector2, dir : Vector2 = Vector2(0, 0)):
	if get_tree().current_scene.name != 'play_scene':
		return
	
	var project_data = Cfile.get_jsonData("res://assets/data/projectiles/" + project_name + ".json")
	if project_data == null:
		Command.error('데이터에 없는 객체입니다.')
		return
	
	var pro_path = preload("res://assets/objects/entities/projectiles.tscn")
	var pro : Projectile = pro_path.instantiate()
	pro.speed = project_data["speed"]
	pro.dir = dir
	pro.damage = project_data["damage"]
	pro.knockback = project_data["knockback"]
	pro.collision_size = Vector2(project_data["collision_size"][0], project_data["collision_size"][1])
	
	pro.find_child("anim_sp").sprite_frames = load("res://assets/animations/projectiles/" + project_name + ".tres")

	pro.global_position = pos
	
	get_tree().current_scene.find_child("all_entities").add_child(pro)

func summon_item(item_name : String, pos : Vector2):
	if get_tree().current_scene.name != 'play_scene':
		return
	
	var item_data = Cfile.get_jsonData("res://assets/data/items/" + item_name + ".json")

	if item_data == null:
		Command.error('데이터에 없는 객체입니다.')
		return
	
	var dropItem_path = preload("res://assets/objects/entities/drop_item.tscn")
	var dropItem : DropItem = dropItem_path.instantiate()
	dropItem.global_position = pos
	
	dropItem.find_child("sp").texture = load("res://assets/sprites/items/" + item_name + ".png")
	
	dropItem.itemName = item_name
	dropItem.itemDisplayName = item_data["name"]
	dropItem.itemSubName = item_data["subname"]
	dropItem.itemDes = item_data["des"]
	dropItem.itemType = item_data["type"]
	dropItem.itemAbility = item_data["ability"]
	
	get_tree().current_scene.find_child("all_entities").add_child(dropItem)

func new_room(room_key : String, dir : String = "here", type : String = "basic"):
	# dir은 이제 생성 할 방의 방향 "left", "right", "up", "down"
	# type는 방의 속성 : "water", "lava" .... 등
	var rooms_data = Cfile.get_jsonData("res://assets/data/rooms.json")
	if (room_key in rooms_data.keys()) == false:
		Command.error("데이터에 없는 방입니다.")
		return
	var target_room_data = rooms_data[room_key]
	
	var room_path = load("res://assets/objects/structures/room.tscn")
	var room = room_path.instantiate()
	
	room.tile_data = target_room_data
	# 타일맵 중앙 배치
	room.find_child("tiles").position = -Vector2(224, 128)
	
	if dir == "right":
		room.global_position = Info.room_in_player_pos + Vector2(448, 0)
	elif dir == 'left':
		room.global_position = Info.room_in_player_pos - Vector2(448, 0)
	elif dir == 'up':
		room.global_position = Info.room_in_player_pos - Vector2(0, 256)
	elif dir == 'down':
		room.global_position = Info.room_in_player_pos + Vector2(0, 256)
		
	get_tree().current_scene.find_child("all_rooms").add_child(room)
	

func give_item(item_name: String) -> bool:
	var item_data = Cfile.get_jsonData("res://assets/data/items/" + item_name + ".json")
	if item_data == null:
		Command.error("데이터에 없는 아이템을 가져올 수 없습니다.")
		return false

	var item_type = item_data["type"]
	var target_slot = null

	if item_type == "passive":
		for slot in Info.inventory.passive_slot:
			if slot.held_itemName == "":
				target_slot = slot
				break
	elif item_type == "active":
		if Info.inventory.active_slot != null and Info.inventory.active_slot.held_itemName == "":
			target_slot = Info.inventory.active_slot
	else:
		for slot in Info.inventory.slots:
			if slot.held_itemName == "":
				target_slot = slot
				break

	if target_slot == null:
		Command.error("해당 타입의 빈 슬롯이 없습니다.")
		return false

	target_slot.held_itemName = item_name
	return true
	
	target_slot.held_itemName = item_name

# 넉백 주는 함수 / 넉백을 주게 만든 대상, 넉백 받는 대상, 넉백 파워
func apply_knockback(target_pos: Vector2, body: Node2D, force: float) -> void:
	var direction = (body.global_position - target_pos).normalized()
	var distance = body.global_position.distance_to(target_pos)
	
	# 거리가 가까울수록 힘이 세고, 멀수록 약하게
	var knockback_strength = force * 500 / max(distance, 1.0)
	
	knockback_strength = clamp(knockback_strength, 0, 600)
	
	var knockback_vector = direction * knockback_strength
	
	# CharacterBody2D일 경우
	if body is CharacterBody2D:
		body.velocity.x += knockback_vector.x
		body.velocity.y += knockback_vector.y / 1.8

# 카메라 흔드는 함수 / 흔들 카메라, 지속 시간, 흔들림 강도
func shake_camera(camera: Camera2D, duration: float, intensity: float) -> void:
	var time_elapsed = 0.0
	intensity = clamp(intensity, 0.5, 35)

	while time_elapsed < duration:
		var shake_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		camera.offset = shake_offset

		await get_tree().process_frame
		time_elapsed += get_process_delta_time()

	camera.offset = Vector2(0, 0)

# 애니메이션 파티클 소환 함수 / 파티클 이름, 생성 위치, 바라볼 방향, 색상 변경 할 색상
func particle(par_name : String, pos : Vector2, dir : Vector2 = Vector2(0, 0), color : Color = Color(1, 1, 1, 1), flipV : bool = false):
	var par_path = preload("res://assets/objects/particles/animated_particle.tscn")
	var par = par_path.instantiate()
	
	par.modulate = color
	par.find_child("anim_sp").sprite_frames = load("res://assets/animations/particles/" + par_name + ".tres")
	par.find_child("anim_sp").play("play")
	par.find_child("anim_sp").flip_h = flipV
	par.global_position = pos
	par.rotation = dir.angle()
	get_tree().current_scene.find_child("all_particles").add_child(par)

# 데미지 주는 코드 / 대상 노드, 줄 데미지
func hurt(node, damage : float):
	if (node.has_node("anim_sp") or node.has_node("sp")) == false:
		# 스프라이트를 안 가지고 있다면 그냥 반환
		return
	
	if node is Player: # 데미지 받는 대상이 플레이어면
		Info.player_hp -= damage
		node.find_child("animation").play("hurt")
		Command.shake_camera(node.find_child("cam"), 0.08, damage * 8)
		node.find_child("anim_sp").material.set_shader_parameter("enabled", true)
		await get_tree().create_timer(0.2).timeout
		node.find_child("anim_sp").material.set_shader_parameter("enabled", false)
	else: # 플레이어가 아니라면
		node.hp -= damage
		Sound.force_play("blood_hit", -8)
		Sound.force_play("swing_sword", 15)
		Info.player.find_child("animation").play("impact_zoom")
		Command.shake_camera(Info.player.find_child("cam"), 0.04, damage * 0.8)
		Command.particle("attack_hit", node.global_position + Info.player_pos.direction_to(node.global_position).normalized() * 13, Info.player_pos.direction_to(node.global_position).normalized(), Color("#b81a33"))
		node.find_child("anim_sp").material.set_shader_parameter("enabled", true)
		timestopBBU(0.45, 0.5)
		await get_tree().create_timer(0.1).timeout
		node.find_child("anim_sp").material.set_shader_parameter("enabled", false)

func kill(node : Node2D):
	if node.is_dead:
		return
	if node.has_node("anim_sp") == false: # anim_sp가 없는 엔티티면 그냥 삭제
		queue_free()
		return
	node.is_dead = true
	node.find_child("coll").call_deferred("set", "disabled", true)
	node.find_child("anim_sp").play("death")
	
func timestopBBU(scale : float, duration : float):
	Engine.time_scale = scale
	await get_tree().create_timer(duration * scale).timeout
	Engine.time_scale = 1.0
	
func error(text : String):
	if get_tree().current_scene.name != 'play_scene':
		return
	
	var error_text_path = preload("res://assets/objects/gui/error_text.tscn")
	var error_text = error_text_path.instantiate()
	
	error_text.error = text
	get_tree().current_scene.find_child("front_ui").add_child(error_text)

func stylize_description(itemName : String, itemSubName : String, itemType : String, itemDes : String, itemAbility : String, state : String):
	# state는 이 아이템이 인벤에 있는 건지 drop아이템 상태인지 등등 판별
	# state = "inventory" or "dropitem"
	var result_text = "[b]<" + itemName + ">[/b][color=#747474] ㅣ" + itemType + "[/color]\n" +"[color=#747474]" + itemSubName + "[/color]" +"\n\n" + itemAbility + "\n\n[color=#999999]" + itemDes +"[/color]"
	if state == "dropitem":
		result_text += "\n\n[img]res://assets/sprites/gui/buttons/key_f.png[/img] [b] 줍기[/b]"
	elif state == "inventory":
		result_text += "\n\n[img]res://assets/sprites/gui/buttons/key_q.png[/img] [b] 버리기[/b]"
	elif state == "catalyst":
		result_text += "\n\n[img]res://assets/sprites/gui/buttons/key_e.png[/img] [b] 넣기[/b]"
		
	return result_text
