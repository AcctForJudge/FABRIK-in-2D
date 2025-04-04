extends Node2D

func _physics_process(delta: float) -> void:
	var pos = get_global_mouse_position()
	self.position = pos
