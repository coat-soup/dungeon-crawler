extends RefCounted
class_name AStarNode

var parent : AStarNode
var position : Vector3i

var g : float
var h : float
var f : float

func _init(p : AStarNode, pos : Vector3i) -> void:
	parent = p
	position = pos
	g = 0
	h = 0
	f = 0
