extends Node2D
class_name Entity

signal on_drag_move # triggered whenever the entity is moved via dragging

export(bool) var is_movable = true
export(bool) var is_connection_source = true
export(bool) var is_connection_target = false

func _ready():
	if is_movable:
		DragDropController.register_draggable($DragTarget, self)
	if is_connection_target:
		DragDropController.register_drop_target($DragTarget, self)

### Gotta override this in a subclass if you want an entity to be a drop target
func is_valid_drop_source(drop_source) -> bool:
	return true

func can_start_drag(mouse_button) -> bool:
	if mouse_button == BUTTON_LEFT and is_movable: 
		return true
	elif mouse_button == BUTTON_RIGHT and is_connection_source:
		return true
	else:
		return false

func on_mouse_drop(current_button, current_drop_target, current_drop_preview):
	if is_movable and current_button == BUTTON_LEFT:
		perform_movement_drop(current_drop_target, current_drop_preview)
	elif is_connection_source and current_button == BUTTON_RIGHT and current_drop_target:
		perform_connect_drop(current_drop_target, current_drop_preview)

func perform_movement_drop(current_drop_target, current_drop_preview):
	if current_drop_preview and current_drop_preview.has_method("is_valid_drop_location") and !current_drop_preview.is_valid_drop_location(current_drop_target, self):
		# dropping into an invalid location, as determined by the drop preview
		print_debug("Tried to drop in an invalid location")
	elif current_drop_target and current_drop_target.has_method("is_valid_drop_location") and !current_drop_target.is_valid_drop_location(current_drop_target, self):
		# dropping into an invalid location, as determined by the drop target
		print_debug("Tried to drop in an invalid target: ", current_drop_target.name)
	elif current_drop_target == null: 
		# Dropping into a blank space instead of on top of a target
		print("Nonintersecting movement drop happening")
		move_to_mouse()
	else: 
		# Dropping on top of a target
		print("Intersecting movement drop happening")
		if current_drop_target == self:
			# dropping on top of yourself, just move a little bit
			move_to_mouse()

func move_to_mouse():
	var new_position = get_global_mouse_position()
	global_position = new_position
	emit_signal("on_drag_move")

func perform_connect_drop(current_drop_target, current_drop_preview):
	print("Connection drop happening; target=", current_drop_target, "; preview=", current_drop_preview)

func get_drag_preview(mouse_button):
	if mouse_button == BUTTON_LEFT and is_movable:
		var preview = self.duplicate()
		preview.set_script(preload("res://scene/entity/BasicDragPreview.gd"))
		preview.previewed_owner = self
		return preview
	if mouse_button == BUTTON_RIGHT and is_connection_source:
		var preview = preload("res://scene/entity/ConnectDragPreview.tscn").instance()
		preview.previewed_owner = self
		return preview
