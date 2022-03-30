extends EditorInspectorPlugin

var undo_redo
var bitmap_generator = preload("res://addons/godot_navigation2d_generator_plugin/bitmap_generator.gd").new()
var precision = 2.0
var actor_radius = 10.0


func can_handle(object):
	return object.is_class("NavigationPolygonInstance")


func parse_category(object: Object, category: String) -> void:
	if category == "NavigationPolygonInstance":
		var button = Button.new()
		button.text = "Generate"
		button.connect("pressed", self, "_generate", [object])
		add_custom_control(button)

		var spin_slider = EditorSpinSlider.new()
		spin_slider.label = "Precision"
		spin_slider.value = precision
		spin_slider.max_value = 10.0
		spin_slider.min_value = 0.01
		spin_slider.step = 0.01
		spin_slider.connect("value_changed", self, "_update_precision")
		add_custom_control(spin_slider)

		var actor_spin_slider = EditorSpinSlider.new()
		actor_spin_slider.label = "Actor Radius"
		actor_spin_slider.value = actor_radius
		actor_spin_slider.max_value = 1000.0
		actor_spin_slider.min_value = 0.0
		actor_spin_slider.step = 0.1
		actor_spin_slider.connect("value_changed", self, "_update_actor_radius")
		add_custom_control(actor_spin_slider)


func _update_precision(value: float) -> void:
	precision = value


func _update_actor_radius(value: float) -> void:
	actor_radius = value


func _generate(navpoly_instance: NavigationPolygonInstance) -> void:
	# Create working copy
	var working_navpoly = navpoly_instance.navpoly.duplicate(true)

	# Clear navpoly polygons
	var main_outline = working_navpoly.get_outline(0)
	working_navpoly.clear_outlines()
	working_navpoly.clear_polygons()

	# Get collision shape2ds, exclude nodes in "exclude_navmesh" group:
	var scene_root = navpoly_instance.get_tree().get_edited_scene_root()
	var shapes = []
	var polygons = []
	bitmap_generator.get_nodes_recursive("CollisionShape2D", scene_root, shapes, "exclude_navmesh")
	bitmap_generator.get_nodes_recursive("CollisionPolygon2D", scene_root, polygons, "exclude_navmesh")

	# Add actor radius
	var transformed_shapes = []
	for collision_shape in shapes:
		var new_shape = TransformedShape2D.new()
		new_shape.shape = _scale_shape(collision_shape)
		new_shape.transform = collision_shape.global_transform
		transformed_shapes.push_back(new_shape)

	for collision_polygon in polygons:
		var new_polygons = Geometry.offset_polygon_2d(collision_polygon.polygon, actor_radius)
		if new_polygons.size() > 1:
			push_warning("Polygon " + collision_polygon.name + " split when scailing.")
		var new_shape = TransformedShape2D.new()
		new_shape.polygon = new_polygons[0]
		new_shape.transform = collision_polygon.global_transform
		transformed_shapes.push_back(new_shape)

#		print(shapes[collision_shape].shape.radius)
#		shapes[collision_shape].shape = _scale_shape(shapes[collision_shape])
#		print(shapes[collision_shape].shape.radius)

	# Generate bitmap
	var bounds = bitmap_generator.get_polygon_bounds(main_outline)
	var root_node = navpoly_instance.get_tree().get_root()
	var function_state = bitmap_generator.generate_bitmap(root_node, bounds, transformed_shapes)
	var bitmap: BitMap = yield(function_state, "completed")

	# Create outlines
	var outlines = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, bitmap.get_size()), precision)

	# Apply bitmap offset
	for outline in outlines.size():
		for vertex in outlines[outline].size():
			outlines[outline][vertex] += bounds[0]

	# Clip overlaping polygons from navpoly
	var modified_main_outline = Array(main_outline)
	var hole_outlines = []
	var clipped_outline
	var clipped_size
	var good_clip = false
	for outline in outlines:
		# Clip against modified base
		clipped_outline = Geometry.clip_polygons_2d(modified_main_outline, outline)
		clipped_size = clipped_outline.size()
		if clipped_size == 0:
			push_warning("A collision shape is completly overlapping it's navmesh.")
		else:
			# Check if polygons are holes
			good_clip = true
			for polygon in clipped_outline:
				if Geometry.is_polygon_clockwise(polygon):
					good_clip = false
					break
			# Polygons is not a hole, it is a clip
			if good_clip:
				modified_main_outline = clipped_outline[0]
			# Polygon is a hole, let navpoly take care of it
			else:
				hole_outlines.push_back(outline)

	# Apply outlines to navpoly
	working_navpoly.add_outline(modified_main_outline)
	for outline in hole_outlines:
		working_navpoly.add_outline(outline)
	working_navpoly.make_polygons_from_outlines()

	# Undo/Redo
	undo_redo.create_action("Generate navpoly")
	undo_redo.add_do_property(navpoly_instance, "navpoly", working_navpoly)
	undo_redo.add_undo_property(navpoly_instance, "navpoly", navpoly_instance.navpoly)
	undo_redo.commit_action()


func _scale_shape(collision_shape: CollisionShape2D) -> Shape2D:
	var shape := collision_shape.shape.duplicate(true) as Shape2D
	match shape.get_class():
		"CapsuleShape2D":
			shape.radius += actor_radius
		"CircleShape2D":
			shape.radius += actor_radius
		"RectangleShape2D":
			shape.extents.x += actor_radius
			shape.extents.y += actor_radius
	return shape
