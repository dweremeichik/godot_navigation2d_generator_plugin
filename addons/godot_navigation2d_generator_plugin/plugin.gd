tool
extends EditorPlugin

var plugin

func _enter_tree() -> void:
	plugin = preload("res://addons/godot_navigation2d_generator_plugin/inspector_plugin.gd").new()
	plugin.undo_redo = get_undo_redo()
	add_inspector_plugin(plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(plugin)
