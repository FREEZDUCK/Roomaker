extends CharacterBody2D

class_name Player


# 플레이어 객체의 코드

# 능력치 데이터는 Info.gd에 있는 데이터 들고옴.
var ACCEL : float = 15.0

var hp : float
var max_hp : float

var direction : Vector2
var last_dir = 'front' # or "side", "back"
var is_attacking : bool = false
var is_dashing : bool = false

var allow_dash : bool = false
var dash_timer : float = 0

# Pointer--------------
var anim_sp : AnimatedSprite2D
var attack_collision : CollisionShape2D

func _ready():
	Info.player = self
	anim_sp = $anim_sp
	attack_collision = $attack/coll

func _physics_process(delta):
	#print("대쉬 허용 : ", allow_dash, "  공격 중인가 : ", is_attacking, "  대쉬 중인가? : ", is_dashing)
	$cam.global_position = Info.room_in_player_pos + Vector2(0, -4)
	Info.player_pos = global_position
	max_hp = Info.player_max_hp
	hp = Info.player_hp

	if is_attacking == false:
		direction = Input.get_vector("A","D","W","S")
		
	control_attackAnim()
	control_of_dir()
	dash_charge(delta)
	velocity.x = move_toward(velocity.x, Info.player_movement_speed * direction.x, ACCEL)
	velocity.y = move_toward(velocity.y, Info.player_movement_speed * direction.y, ACCEL)

	move_and_slide()

func melee_attack():
	if is_attacking == true or is_dashing == true:
		return
	is_attacking = true
	direction = Vector2(0, 0)
	Sound.force_play("small_whoosh", 20)
	Sound.force_play("swing_sword", 1)
	Command.particle("slash_" + Info.slash_type + "_" + last_dir, global_position, Vector2(0,0), Color(1,1,1,1), anim_sp.flip_h)
	anim_sp.play("attack_" + last_dir)

func control_of_dir():
	# 방향에 따른 애니메이션, 공격 범위 위치, 이미지 반전 조정
	if is_dashing == true:
		return
	
	if direction.x > 0:
		anim_sp.play("move_side")
		last_dir = 'side'
		attack_collision.position = Vector2(18, 0)
		anim_sp.flip_h = true
	elif direction.x < 0:
		anim_sp.play("move_side")
		last_dir = 'side'
		attack_collision.position = Vector2(-18, 0)
		anim_sp.flip_h = false
	elif direction.y > 0:
		anim_sp.play("move_front")
		last_dir = 'front'
		attack_collision.position = Vector2(0, 18)
	elif direction.y < 0:
		anim_sp.play("move_back")
		last_dir = 'back'
		attack_collision.position = Vector2(0, -18)
	elif is_attacking == false and is_dashing == false:
		anim_sp.play("idle_" + last_dir)
func control_attackAnim():
	# 공격 애니메이션 조정
	if "attack" in anim_sp.animation: # 현재 실행 중인 애니메이션 이름에 attack이 들어가는가
		if anim_sp.frame == 1: # 딱 검기가 뻗어나가는 프레임이 1이라서 1일때만
			attack_collision.disabled = false # 공격 범위 활성화
		elif anim_sp.frame != 1:
			attack_collision.disabled = true

	if Input.is_action_just_pressed("melee_attack"):
		melee_attack()
	
	# 구르기 코드인데 아직 불안정 함(추후 수정 or 삭제 예정)
	if Input.is_action_just_pressed("dash"):
		if allow_dash == true and is_attacking == false:
			is_dashing = true
			var power = 270 # 구르기 추가 예정
			Command.shake_camera(Info.player.find_child("cam"), 0.1,  0.5)
			anim_sp.play("roll_" + last_dir)
			Sound.force_play("clothes_drop", -2)
			if last_dir == 'front':
				velocity.y = power
			elif last_dir == 'back':
				velocity.y = -power
			elif last_dir == 'side':
				if anim_sp.flip_h == true:
					velocity.x = power
				elif anim_sp.flip_h == false:
					velocity.x = -power
			allow_dash = false

func dash_charge(delta):
	if allow_dash == true:
		return

	dash_timer += delta
	if dash_timer > Info.player_dash_delay:
		allow_dash = true
		dash_timer = 0

func _on_animation_finished():
	# 원래는 애니메이션이 끝나면 발동되는 함수이지만,
	# move, idle은 반복 애니메이션 이므로 끝나지 않아, 끝나는 애니매이션은 attack 졸류뿐
	if "attack" in anim_sp.animation:
		is_attacking = false
	if "roll" in anim_sp.animation:
		is_dashing = false

func _on_body_area_entered(area):
	if area.get_parent() is Monster and area.name == 'attack': # 공격 준 상대가 몬스터 라면
		Command.hurt(self, area.get_parent().meleeAttack_damage)
		Command.apply_knockback(area.global_position, self, area.get_parent().knockback_force)
