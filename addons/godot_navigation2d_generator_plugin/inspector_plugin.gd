extends EditorInspectorPlugin


func can_handle(object):
	return object.is_class("NavigationPolygonInstance")


func parse_category(object: Object, category: String) -> void:
	if category == "NavigationPolygonInstance":
		var button = Button.new()
		button.text = "Generate"
		add_custom_control(button)
