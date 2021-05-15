extends Node2D

const DEFAULT_COLOR = Color(0, 0, 0, 0.3)
const BAD_PLACE_COLOR = Color(1, 0, 0, 0.3)

var previewed_owner
var overlapping_areas : Array = []

func is_drag_preview():
	return true

func setup_preview():
	self.modulate = DEFAULT_COLOR

func _process(_delta):
	var valid = !is_valid_drop_location(DragDropController.get_top_drop_candidate(previewed_owner), previewed_owner)
	if valid and self.modulate != BAD_PLACE_COLOR:
		self.modulate = BAD_PLACE_COLOR
	elif !valid and self.modulate != DEFAULT_COLOR:
		self.modulate = DEFAULT_COLOR

func entered_area(area:Area2D):
	if area and area.owner != previewed_owner: # A drag preview doesn't intersect with the original version of itself
		overlapping_areas.append(area.owner)

func exited_area(area:Area2D):
	if area:
		overlapping_areas.erase(area.owner)

func is_valid_drop_location(drop_target, dropped_entity):
	if drop_target == null:
		return false
	return drop_target.has_method("is_valid_drop_source") and drop_target.is_valid_drop_source(dropped_entity)
