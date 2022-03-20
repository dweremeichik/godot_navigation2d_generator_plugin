extends EditorInspectorPlugin

var undo_redo
var bitmap_generator = preload("res://addons/godot_navigation2d_generator_plugin/bitmap_generator.gd").new()
var precision = 2.0


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


func _update_precision(value: float) -> void:
	precision = value


func _generate(navpoly_instance: NavigationPolygonInstance) -> void:
	# Create working copy
	var working_navpoly = navpoly_instance.navpoly.duplicate(true)

	# Clear navpoly polygons
	var main_outline = working_navpoly.get_outline(0)
	working_navpoly.clear_outlines()
	working_navpoly.clear_polygons()

	# Get collision shape2ds:
	var scene_root = navpoly_instance.get_tree().get_edited_scene_root()
	var shapes = []
	bitmap_generator.get_nodes_recursive("CollisionShape2D", scene_root, shapes)

	# Generate bitmap
	var bounds = bitmap_generator.get_polygon_bounds(main_outline)
	var root_node = navpoly_instance.get_tree().get_root()
	var function_state = bitmap_generator.generate_bitmap(root_node, bounds, shapes)
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
