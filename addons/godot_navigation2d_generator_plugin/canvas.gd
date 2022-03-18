extends Node2D

var collision_shapes_to_draw = []

func _draw() -> void:
	for collision_shape in collision_shapes_to_draw:
		draw_set_transform_matrix(collision_shape.global_transform)
		collision_shape.shape.draw(get_canvas_item(), Color.black)
