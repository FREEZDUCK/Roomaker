extends Area2D

class_name DropItem

var itemName : String
var itemDisplayName : String
var itemSubName : String
var itemDes : String
var itemType : String
var itemAbility : String

var time : float = 0

func _process(delta):
	control_move(delta)
	
func control_move(delta):
	time += delta
	$sp.position.y -= sin(time * 3) * 0.1
	$outline.position.y -= sin(time * 3) * 0.1
	$light.position.y -= sin(time * 3) * 0.1
	$light.scale = Vector2(1 + 0.05 * sin(time * 3), 1 + 0.05 * cos(time * 3))
