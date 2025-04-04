extends Camera2D
@export var speed:int = 50
const zooom:Vector2 = Vector2(0.01,0.01)
@export var min_zoom =  Vector2(0.15,0.15)
@export var max_zoom =  Vector2(2,2)
func _physics_process(delta: float) -> void:
	
	var input_direction = Input.get_vector("left", "right", "up", "down")
	position += input_direction * speed
	if Input.is_action_just_pressed("zoom-in"):
		zoom = max_zoom.min(zoom + zooom)
	elif Input.is_action_just_pressed("zoom-out"):
		zoom = min_zoom.max(zoom - zooom)
	pass
