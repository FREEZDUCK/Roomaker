extends Area2D

class_name Projectile

var dir : Vector2
var speed : float
var damage : float
var knockback : float
var collision_size : Vector2

# Pointer ----------
var anim_sp : AnimatedSprite2D
var collision : CollisionShape2D
var visibleBox : VisibleOnScreenEnabler2D

func _ready():
	anim_sp = $anim_sp
	collision = $coll
	visibleBox = $visibleBox
	
	dir = dir.normalized()
	collision.shape = RectangleShape2D.new()
	collision.shape.size = collision_size
	
	visibleBox.rect = Rect2(-anim_sp.sprite_frames.get_frame_texture("shoot", 0).get_size().x * 10 / 2, -anim_sp.sprite_frames.get_frame_texture("shoot", 0).get_size().y * 10 / 2, anim_sp.sprite_frames.get_frame_texture("shoot", 0).get_size().x * 10, anim_sp.sprite_frames.get_frame_texture("shoot", 0).get_size().y * 10)
	
	anim_sp.rotation = dir.angle()
	collision.rotation = dir.angle()
	anim_sp.play("flying")
	
func _process(delta):
	global_position += dir * speed * delta

func hit():
	print(11)
	dir = Vector2.ZERO
	collision.set_deferred("disabled", true)
	anim_sp.rotation = 0
	anim_sp.play("hit")

func _on_body_entered(body):
	print(body.name)
	if body.name == 'tiles':
		hit()
	if body is Player:
		Command.hurt(Info.player, damage)
		Command.apply_knockback(global_position, Info.player, knockback)
		hit()

func _on_animation_finished():
	if anim_sp.animation == 'hit':
		queue_free()

func _on_visible_screen_exited():
	queue_free()
