# Godot Navigation2D Generator

<!-- ![Icon](https://raw.githubusercontent.com/dweremeichik/godot_navigation2d_generator_plugin/main/asset_lib/asset_lib_icon.png) -->

Godot Navigation2D Generator is a plugin for the [Godot Engine](https://godotengine.org). 
It is designed to make 2D navigation polygons significantly faster to create and update. Navigation polygons are generated based on collision shapes you already need and have in your scenes.

## How to install

Official plugin installation instructions may be found [here](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html#installing-a-plugin).
You may either install this plugin through the Godot Asset Library, or you can download a zip file directly from GitHub.

## How to use

To use this plugin simply enable it, you can find the official instructions [here](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html#enabling-a-plugin).

* Select the NavigationPolygonInstance you would like to generate. 
* Create the desired "base" polygon shape (this is usually the shape of a room or area in your game). 
* Set the "Precision" which corisponds to the number of verticies that will be used to create the cutouts. Smaller numbers result in more verticies.
* Set the "Actor Radius" which corrisponds to the collision shape radius of your AI (or "Actors") that will be using this navigation polygon. This will add padding to your collision shapes as Navigation2D does not normally take this into account.
* Any CollisionShape2Ds or CollisionPolygon2Ds that you want to ignore need to have the "exclude_navmesh" group added to them.
* Click the generate button.

> Note: This plugin supports undo/redo so feel free to fiddle with settings!


## License

This plugin is MIT licensed. The license file is located at [addons\godot_navigation2d_generator_plugin\LICENSE](https://github.com/dweremeichik/godot_navigation2d_generator_plugin/blob/main/addons/godot_navigation2d_generator_plugin/LICENSE).
