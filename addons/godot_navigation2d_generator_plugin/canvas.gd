extends Node2D

var collision_shapes_to_draw = []

func _draw() -> void:
	for transformed_shape in collision_shapes_to_draw:
		draw_set_transform_matrix(transformed_shape.transform)
		if transformed_shape.shape:
			transformed_shape.shape.draw(get_canvas_item(), Color.black)
		else:
			draw_colored_polygon(transformed_shape.polygon, Color.black)
