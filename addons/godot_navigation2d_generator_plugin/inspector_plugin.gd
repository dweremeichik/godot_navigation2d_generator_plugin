extends EditorInspectorPlugin

var bitmap_generator = preload("res://addons/godot_navigation2d_generator_plugin/bitmap_generator.gd").new()


func can_handle(object):
	return object.is_class("NavigationPolygonInstance")


func parse_category(object: Object, category: String) -> void:
	if category == "NavigationPolygonInstance":
		var button = Button.new()
		button.text = "Generate"
		button.connect("pressed", self, "_generate", [object])
		add_custom_control(button)


func _generate(navpoly: NavigationPolygonInstance) -> void:
	# Need to handle yeild of this...
	bitmap_generator.generate_bitmap(navpoly)
#	print(gen_bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, gen_bitmap.get_size())))
#	_viewport_test(navpoly)

#func _viewport_test(node) -> void:
#	# Create viewport
#	var viewport = Viewport.new()
#	viewport.size = Vector2(200, 200)
#	viewport.render_target_update_mode = Viewport.UPDATE_DISABLED
#
#	# Create some test content
#	var rect = ColorRect.new()
#	rect.color = Color(1, 0, 0)
#	rect.rect_size = Vector2(100, 100)
#
#	# Create some more
#	var capsule_shape = CapsuleShape2D.new()
#	capsule_shape.radius = 15
#	capsule_shape.height = 50
#	var collision_shape2d = CollisionShape2D.new()
#	collision_shape2d.position = Vector2(50,50)
#	collision_shape2d.shape = capsule_shape
#
#	# Add to scene
#	viewport.add_child(rect)
#	viewport.add_child(canvas)
#	canvas.collision_shapes_to_draw.append(collision_shape2d)
#	node.add_child(viewport)
#
#	# Wait for content
#	viewport.render_target_update_mode = Viewport.UPDATE_ONCE
#	yield(VisualServer, "frame_post_draw")
#
#	# Fetch viewport content
#	var texture = viewport.get_texture()
#	var image = texture.get_data()
#	image.flip_y()
#	image.save_png("test.png") # just as a debugging check

