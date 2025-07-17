extends CharacterBody2D

class_name Monster # 클래스 설정으로 충돌 인식 간편하게 함

# 몬스터 객체의 코드

# 작동 이해 / 몬스터라는 플레이어를 따라가며, 체력이 없으면 죽는 객체의 거푸집을
# 만든다고 생각하면 편함, 이미지도 없는 거푸집에 Command.gd의 summon_monster 함수로
# 몬스터의 이름을 받아 그 이름에 맞는 animation과 .json에 있는 체력, 스피드 등등 데이터를
# 거푸집에 씌운다고 생각하면 됨.

# 1은 가소 값임 추후에 .json 에 있는 데이터로 바뀜.
var speed : float = 1
var accel : float = 1 # 가속력 속도에 비해 작을 수록 미끄러 지듯이 움직임

var hp : float = 1
var max_hp : float = 1

var direction : Vector2
var target_pos : Vector2

var detect_range : float

var is_dead : bool = false
var is_attacking : bool = false
var is_shooting : bool = false

var allow_meleeAttack : bool = true
var allow_move : bool = true
var allow_shoot : bool = true

var meleeAttack_damage : int
var meleeAttack_delay : float
var meleeAttack_delay_timer : float = 0
var meleeAttack_rect : Rect2
var meleeAttack_frames : Array # 공격을 넣는 타이밍이 두번도 가능하기 때문

var attack_method : String

var projectile_delay_timer : float = 0
var projectile_delay : float
var projectile_pos : Vector2 # 발사체 소환 위치
var projectile_name : String
var projectile_delay_range : Array # 랜덤한 딜레이 범위를 위한 변수

var last_projectile_frame : int # 총알 한 번에 여러개 소환 막기
var last_meleeAttack_frame : int # 근접 공격 한 번에 여러번 막기

var shoot_func : String # 어떻게 날릴지 형식
var shoot_frames : Array # 딱 날리는 프레임들

var knockback_force : float

var texture_pivot : Vector2
var load_animation : SpriteFrames

# Pointer--------------
var anim_sp : AnimatedSprite2D
var meleeAttack_collision : CollisionShape2D
var meleeAttack_detect_collision : CollisionShape2D
var collision : CollisionShape2D
var area_collision : CollisionShape2D
var sight : RayCast2D

func _ready():
	anim_sp = $anim_sp
	meleeAttack_collision = $attack/coll
	meleeAttack_detect_collision = $detect_attack/coll
	collision = $coll
	area_collision = $monster/coll
	sight = $sight

	anim_sp.sprite_frames = load_animation
	anim_sp.offset = texture_pivot
	
	anim_sp.material = anim_sp.material.duplicate()
	
	area_collision.shape = RectangleShape2D.new()
	#collision.shape = RectangleShape2D.new()
	
	#공격, 공격 감지 범위 collision 크기 위치 조정
	for coll in [meleeAttack_collision, meleeAttack_detect_collision]:
		coll.shape = RectangleShape2D.new()
		coll.shape.size = meleeAttack_rect.size
		coll.position = meleeAttack_rect.position
	
	anim_sp.play("idle")
	if attack_method == "projectile":
		projectile_delay = randf_range(projectile_delay_range[0], projectile_delay_range[1])

func _physics_process(delta):
	if global_position.distance_to(Info.player_pos) > 18.0 and allow_move == true and is_attacking == false and is_shooting == false and is_dead == false:
		direction = (Info.player_pos - global_position).normalized()
	else:
		direction = Vector2.ZERO
	
	control_attack_timer(delta)
	control_attackAnim()
	control_of_dir()
	control_sight()

	if attack_method == "projectile":
		control_projectile(delta)
		
	velocity = velocity.move_toward(direction * speed, accel)
	move_and_slide()

func melee_attack():
	if not allow_meleeAttack:
		return
	is_attacking = true
	allow_move = false
	anim_sp.play("attack")
func shoot_projectile():
	Shoot.call(shoot_func, projectile_name, global_position + projectile_pos)

func control_projectile(delta):
	projectile_delay_timer += delta
	
	if anim_sp.animation == 'shoot' and float(anim_sp.frame) in shoot_frames and last_projectile_frame != int(anim_sp.frame):
		shoot_projectile()
		last_projectile_frame = int(anim_sp.frame)
	
	if projectile_delay_timer >= projectile_delay and allow_move == true and is_attacking == false and is_dead == false:
		allow_move = false
		is_shooting = true
		anim_sp.play("shoot")
		projectile_delay_timer = 0
		projectile_delay = randf_range(projectile_delay_range[0], projectile_delay_range[1])
func control_sight():
	var player_distance = global_position.distance_to(Info.player_pos)
	if player_distance <= detect_range:
		sight.target_position = to_local(Info.player_pos + Vector2(0, 5))
	if sight.is_colliding():
		if sight.get_collider() is Player:
			allow_move = true
		elif not sight.get_collider() is Monster:
			allow_move = false
func control_attack_timer(delta):
	if allow_meleeAttack:
		return
	meleeAttack_delay_timer += delta
	if meleeAttack_delay_timer >= meleeAttack_delay:
		allow_meleeAttack = true
		meleeAttack_delay_timer = 0
func control_of_dir():
	# 방향에 따른 애니메이션, 공격 범위 위치, 이미지 반전 조정
	if is_attacking or is_dead or is_shooting:
		return  # 공격 중이거나 죽은 상태면 걷기 애니메이션 중단
	
	if direction.length() > 0:
		anim_sp.play("walk")
	elif direction.length() == 0:
		anim_sp.play("idle")
	
	if direction.x > 0:
		anim_sp.offset.x = -texture_pivot.x
		if attack_method == "projectile":
			projectile_pos.x = abs(projectile_pos.x)
		meleeAttack_collision.position.x = meleeAttack_rect.position.x
		meleeAttack_detect_collision.position.x = meleeAttack_rect.position.x
		anim_sp.flip_h = true
	elif direction.x < 0:
		anim_sp.offset.x = texture_pivot.x
		if attack_method == "projectile":
			projectile_pos.x = -abs(projectile_pos.x)
		meleeAttack_collision.position.x = -meleeAttack_rect.position.x
		meleeAttack_detect_collision.position.x = -meleeAttack_rect.position.x
		anim_sp.flip_h = false

func control_attackAnim():
	if is_attacking == false and is_dead == false and is_shooting == false:
		for area in $detect_attack.get_overlapping_areas():
			if area.name == "player" and area.get_parent() is Player:
				melee_attack()
				break

	# 공격 중일 때만 프레임 체크
	if anim_sp.animation == "attack" and float(anim_sp.frame) in meleeAttack_frames and last_meleeAttack_frame != anim_sp.frame:
		# json에서 frames에 있는 값들이 float임 json엔 Float만 가능하나봄 ㅅㅂ
		meleeAttack_collision.disabled = false
		Sound.force_play("small_whoosh")
		last_meleeAttack_frame = int(anim_sp.frame)
	else:
		meleeAttack_collision.disabled = true
func _on_animation_finished():
	match anim_sp.animation:
		"attack":
			is_attacking = false
			allow_move = true
			allow_meleeAttack = false
			last_meleeAttack_frame = -1
		"shoot":
			last_projectile_frame = -1
			is_shooting = false
			allow_move = true
		"death":
			var sp_rect = anim_sp.sprite_frames.get_frame_texture("idle", 0).get_image().get_used_rect()
			var area = sp_rect.size.x * sp_rect.size.y
			var density = 0.0025  # 면적당 파티클 개수 비율 (조절 가능)
			var particle_count = int(area * density)
			Sound.force_play("blood_squishy", 12)
			for i in range(particle_count):
				var rand_offset = Vector2(randf_range(-sp_rect.size.x / 2, sp_rect.size.x / 2),randf_range(-sp_rect.size.y / 2, sp_rect.size.y / 2))
				var spawn_pos = global_position + rand_offset
				Command.particle("blood_explosion", spawn_pos)
			queue_free()
func _on_body_area_entered(area):
	if area.name == "attack" and area.get_parent() is Player and is_dead == false:
		Command.hurt(self, Info.player_attack_damage)
		Command.apply_knockback(area.global_position, self, Info.player_knockback_force)
		if hp <= 0:
			Command.kill(self)
