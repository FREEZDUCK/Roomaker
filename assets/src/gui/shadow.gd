extends Node2D

# 그림자 객체의 본인의 부모노드 크기에 따른 그림자 크기 변경
var parent_texture_rect : Rect2

func _ready():
	if get_parent().has_node("anim_sp"):
		parent_texture_rect = get_parent().find_child("anim_sp").sprite_frames.get_frame_texture(get_parent().find_child("anim_sp").animation, 0).get_image().get_used_rect()
	elif get_parent().has_node("sp"):
		parent_texture_rect = get_parent().find_child("sp").texture.get_image().get_used_rect()

	# 부모 노드의 콜리션 크기에 맞춰 그림자의 크기 조정 x에 비해 y크기는 적게 변함
	$shadow.size.x = parent_texture_rect.size.x / 1.5
	$shadow.size.y = parent_texture_rect.size.y / 6
	
	# 위치 센터 조정
	$shadow.position.x = -$shadow.size.x / 2
	$shadow.position.y = -$shadow.size.y / 2
