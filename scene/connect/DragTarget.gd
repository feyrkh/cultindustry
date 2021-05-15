extends Area2D
class_name DragTarget

var overlapping_areas : Array = []

func _ready():
	DragDropController.register_draggable(self, owner)
