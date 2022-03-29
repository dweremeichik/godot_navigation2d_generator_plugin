extends KinematicBody2D

export (NodePath) var navigation2d_path

var target: int = -1

var _max_speed := 100 #Pixels per second
var _velocity: Vector2
var _navigation2d: Navigation2D
var _path: PoolVector2Array

func _ready() -> void:
	if !navigation2d_path:
		push_error(name + " Navigation2d Path not set")
		return
	_navigation2d = get_node(navigation2d_path)

func _process(_delta: float) -> void:
	update()

func _physics_process(_delta: float) -> void:
	# Navigation2D uses coordinates local to itself, so we need to convert everything to global.
	if _path.size() and target <= _path.size() -1:
		var distance_to_target = _navigation2d.to_global(_path[target]).distance_to(global_position)
		_velocity += global_position.direction_to(_navigation2d.to_global(_path[target])) * _max_speed
		_velocity = _velocity.clamped(_max_speed)
		_velocity = move_and_slide(_velocity)
		
		# Close enough to target, get a new one (this prevents bouncing arond a single point)
		if distance_to_target < 1:
			target += 1


func _unhandled_input(event: InputEvent) -> void:
	# Update navigation path
	if event.is_action_pressed("click"):
		var local_mouse_position = _navigation2d.to_local(get_global_mouse_position())
		var local_actor_position = _navigation2d.to_local(global_position)
		_path = _navigation2d.get_simple_path(local_actor_position, local_mouse_position)
		target = 0
		get_tree().set_input_as_handled()


func _draw() -> void:
	# Draw Actor
	$CollisionShape2D.shape.draw(get_canvas_item(), Color.aqua)
	for point in _path.size():
		# Draw path points
		draw_circle(to_local(_navigation2d.to_global(_path[point])), 5.0, Color.red)
		if point > 0:
			# Connect points with a line
			draw_line(to_local(_navigation2d.to_global(_path[point - 1])), to_local(_navigation2d.to_global(_path[point])), Color.orangered, 2.0)
