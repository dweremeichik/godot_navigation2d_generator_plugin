extends Reference

var root_node: Node
var scene_root: Node
var collision_shapes = []
var viewport: Viewport
var canvas: Node2D


func generate_bitmap(navigation_polygon_instance: NavigationPolygonInstance) -> BitMap:
	scene_root = navigation_polygon_instance.get_tree().get_edited_scene_root()
	root_node = navigation_polygon_instance.get_tree().get_root()
	# Get all collision shapes
	_get_nodes_recursive("CollisionShape2D", scene_root, collision_shapes)
	# Get the bounds of our NavigationPolygonInstance so we can set the viewport size 
	var navpoly_bounds = _get_navpoly_bounds(navigation_polygon_instance.navpoly)
	print(collision_shapes, " npi ", navpoly_bounds)
	# Setup Viewport
	viewport = Viewport.new()
	root_node.add_child(viewport)
	viewport.owner = root_node
	viewport.size = navpoly_bounds
	viewport.gui_disable_input = true
	viewport.transparent_bg = true
	viewport.usage = Viewport.USAGE_2D
	viewport.render_target_clear_mode = Viewport.CLEAR_MODE_NEVER
	viewport.render_target_update_mode = Viewport.UPDATE_DISABLED
	
	# Setup Canvas
	canvas = preload("res://addons/godot_navigation2d_generator_plugin/canvas.gd").new()
	viewport.add_child(canvas)
	canvas.collision_shapes_to_draw = collision_shapes
	
	# Render content
	viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	yield(VisualServer, "frame_post_draw")
	
	# Fix orientation
	var image = viewport.get_texture().get_data()
	image.flip_y()
	
#	# Create Sprite
#	var texture = ImageTexture.new()
#	texture.create_from_image(image)
#	var sprite = Sprite.new()
#	scene_root.add_child(sprite)
#	sprite.owner = scene_root
#	sprite.texture = texture
#	sprite.name = "TEXTY"
#	sprite.offset = viewport.size / 2
	
	# Clean up
	root_node.remove_child(viewport)
	viewport.queue_free()
	
	# Create bitmap
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	return bitmap
	

func _get_nodes_recursive(type: String, node: Node, array: Array) -> void:
	for child in node.get_children():
		if child.is_class(type):
			array.append(child)
		_get_nodes_recursive(type, child, array)


func _get_navpoly_bounds(navpoly: NavigationPolygon) -> Vector2:
	var maximums = Vector2.ZERO
	var minimums = Vector2.ZERO
	for vertex in navpoly.get_vertices():
		if vertex.x > maximums.x:
			maximums.x = vertex.x
		if vertex.x < minimums.x:
			minimums.x = vertex.x
		if vertex.y > maximums.y:
			maximums.y = vertex.y
		if vertex.y < minimums.y:
			minimums.y = vertex.y
	return Vector2(maximums.x - minimums.x, maximums.y - minimums.y)
