extends Node2D
class_name Entity

export(bool) var is_movable = true
export(bool) var is_connection_source = true

func on_mouse_drop(current_button, current_drop_target, current_drop_preview):
	if is_movable and current_button == BUTTON_LEFT:
		perform_movement_drop(current_drop_target, current_drop_preview)
	elif is_connection_source and current_button == BUTTON_RIGHT:
		perform_connect_drop(current_drop_target, current_drop_preview)

func perform_movement_drop(current_drop_target, current_drop_preview):
	if current_drop_preview and current_drop_preview.has_method("is_valid_drop_location") and !current_drop_preview.is_valid_drop_location(current_drop_target, self):
		print_debug("Tried to drop in an invalid location")
		return
	if current_drop_target and current_drop_target.has_method("is_valid_drop_location") and !current_drop_target.is_valid_drop_location(current_drop_target, self):
		print_debug("Tried to drop in an invalid target: ", current_drop_target.name)
		return
	if current_drop_target == null:
		print("Nonintersecting movement drop happening")
		var old_position = global_position
		var new_position = get_global_mouse_position()
		global_position = new_position
	else:
		print("Intersecting movement drop happening")

func perform_connect_drop(current_drop_target, current_drop_preview):
	print("Connection drop happening: ", current_drop_target)

func get_drag_preview(mouse_button):
	if (mouse_button == BUTTON_LEFT and is_movable):
		var preview = self.duplicate()
		preview.set_script(preload("res://scene/entity/BasicDragPreview.gd"))
		preview.previewed_owner = self
		return preview
