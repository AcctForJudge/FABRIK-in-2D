extends Node2D

@onready var points = self.get_children()
@onready var connectors: Node2D = $"../Connectors"
@export var distances :int = 300
@export var show_circles:bool = true
@export var radius:Array[int] = [300, 300, 300, 300, 300]
@export var max_constraint:int = 80 #in degrees, turn to radians later
var angles = [0,0,0,0,0]


var radius_ind:int = radius.size() - 1
func _ready() -> void:
	set_lines()
	
func _draw() -> void:
	if show_circles:
		draw_circles()
	
func _physics_process(delta: float) -> void:
	var target = get_global_mouse_position()
 
	resolve(target)
	draw_lines()
	queue_redraw()
	
	#for angle in angles:
		#print(rad_to_deg(angle))

	if points.size() < radius.size():
		if Input.is_action_just_pressed("add-point"):
			add_point(radius[radius_ind])
			radius_ind += 1

func resolve(target):
	angles[0] = points[0].position.angle_to_point(target)
	points[0].position = target
	for ind in range(1, points.size()):
		var raw_angle = points[ind].position.angle_to_point(points[ind - 1].position)
		angles[ind] = constrain_angle(raw_angle,angles[ind - 1], deg_to_rad(max_constraint))
		points[ind].position = points[ind - 1].position - Vector2.from_angle(angles[ind]) * distances

func set_lines():
	var line:Line2D = Line2D.new()
	connectors.add_child(line)
	for i in range(points.size()):
		line.add_point(points[i].position)
		line.width = 10.0	
		
func draw_lines():
	var line:Line2D = connectors.get_child(0)
	for i in range(points.size()):
		line.set_point_position(i, points[i].position)

func draw_circles():
	var ind = 0
	for point in points:
		draw_circle(point.position, radius[ind], Color.WHEAT, false, 10.0, false)
		ind += 1
		


func add_point(r):
	var point:Node2D = load("res://scenes/points.tscn").instantiate()
	add_child(point)
	points.append(point)
	angles.append(0)
	var line:Line2D = connectors.get_child(0)
	line.add_point(point.position)


# angle constrain stuff : https://github.com/argonautcode/animal-proc-anim/blob/main/Util.pde
func constrain_angle(angle:float, anchor:float, constraint:float):
	if abs(relative_angle_diff(angle, anchor)) <= constraint:
		return simplify_angle(angle)
	elif abs(relative_angle_diff(angle, anchor)) > constraint:
		return simplify_angle(anchor - constraint)
	return simplify_angle(anchor + constraint)

func relative_angle_diff(angle:float, anchor:float):
	angle = simplify_angle(angle + PI - anchor)
	anchor = PI
	return anchor - angle

func simplify_angle(angle:float):
	while angle >= 2 * PI:
		angle -= 2 * PI
	while angle < 0:
		angle += 2 * PI
	return angle
