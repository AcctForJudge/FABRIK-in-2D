extends Node2D

var points :Array[Node2D] = []
var distances: Array[Vector2] = []
@export var chain_length:int = 250
@export var tolerance:int = 50
@onready var connectors: Node2D = $"../Connectors"
@export var weight = 0.1
var total_length

var target
func get_points():
	for point in get_children():
		if point.name.begins_with("Point"):
			points.append(point)
	
func set_points():
	var d = chain_length
	for point in get_children():
		point.position = Vector2.ONE * d
		d += chain_length
	
func get_distances():
	for ind in range(points.size() - 1):
		distances.append(points[ind + 1].position - points[ind].position)

func _ready() -> void:
	get_points()
	set_points()
	get_distances()
	set_lines()
	total_length = sum(distances)

func _draw() -> void:
	draw_circle(points[0].position, total_length, Color.WHEAT, false, 5.0)
	
func _physics_process(delta: float) -> void:
	target = get_global_mouse_position()
	solve_distances()
	
func solve_distances():
	var distance_to_target = (points[0].position - target).length()
	if total_length < distance_to_target:
		straight()
	else:
		solve()
	draw_lines()
	
	#print(sum(distances))
	#print(points[0].position - target)
	
	
func straight():
	var new_distances:Array[Vector2]
	
	for ind in range(points.size() - 1):
		var point = points[ind]
		var r = (target - point.position).length()
		var lambda = distances[ind].length() / r
		var points_target = (1 - lambda) * point.position + lambda * target
		points[ind + 1].position = lerp(points[ind + 1].position, points_target, weight)

		
	


func solve():
	var initial = points[0].position
	var distance_to_target = (points[-1].position - target).length()
	var passes = 0
	while distance_to_target > tolerance and passes < 100:
		passes += 1
		
		#forward
		points[-1].position = lerp(points[-1].position, target, weight / 100)
		for ind in range(points.size() - 2, 0, -1):
			var r = (points[ind + 1].position - points[ind].position).length()
			var lambda = distances[ind].length() / r
			var points_target = (1 - lambda) * points[ind + 1].position + lambda * points[ind].position
			points[ind].position = lerp(points[ind].position, points_target, weight)
		
		#backward
		points[0].position = initial
		for ind in range(points.size() - 1):
			var r = (points[ind + 1].position - points[ind].position).length()
			var lambda = distances[ind].length() / r
			var points_target = (1 - lambda) * points[ind].position + lambda * points[ind + 1].position
			points[ind + 1].position = lerp(points[ind + 1].position, points_target, weight)			
		
		distance_to_target = (points[-1].position - target).length()

		
func sum(arr:Array[Vector2]):
	var s = 0
	for i in arr:
		s += i.length()
	return s


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
		#line.points[i] = points[i]
		#line.points[i + 1] = points[i + 1]
		#line.width = 10.0
		
