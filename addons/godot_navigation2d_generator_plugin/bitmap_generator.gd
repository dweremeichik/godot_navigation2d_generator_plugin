extends Reference

var viewport: Viewport
var canvas: Node2D


func generate_bitmap(root_node: Node, bounds: Array, shapes: Array) -> BitMap:
	# Setup Viewport
	viewport = Viewport.new()
	root_node.add_child(viewport)
	viewport.owner = root_node
	var size = Vector2(bounds[1].x - bounds[0].x, bounds[1].y - bounds[0].y)
	viewport.size = size
	viewport.gui_disable_input = true
	viewport.transparent_bg = true
	viewport.usage = Viewport.USAGE_2D
	viewport.render_target_clear_mode = Viewport.CLEAR_MODE_NEVER
	viewport.render_target_update_mode = Viewport.UPDATE_DISABLED
	# Set viewport offset to top left
	viewport.global_canvas_transform.origin = -bounds[0]

	# Setup Canvas
	canvas = preload("res://addons/godot_navigation2d_generator_plugin/canvas.gd").new()
	viewport.add_child(canvas)
	canvas.collision_shapes_to_draw = shapes

	# Render content
	viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	yield(VisualServer, "frame_post_draw")

	# Fix orientation
	var image = viewport.get_texture().get_data()
	image.flip_y()

	# Clean up
	root_node.remove_child(viewport)
	viewport.queue_free()

	# Create bitmap
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)

	return bitmap


func get_nodes_recursive(type: String, node: Node, array: Array) -> void:
	for child in node.get_children():
		if child.is_class(type):
			array.append(child)
		get_nodes_recursive(type, child, array)


func get_polygon_bounds(polygon: PoolVector2Array) -> Array:
	var maximums = polygon[0]
	var minimums = polygon[0]
	for vertex in polygon:
		if vertex.x > maximums.x:
			maximums.x = vertex.x
		if vertex.x < minimums.x:
			minimums.x = vertex.x
		if vertex.y > maximums.y:
			maximums.y = vertex.y
		if vertex.y < minimums.y:
			minimums.y = vertex.y
	return [minimums, maximums]
