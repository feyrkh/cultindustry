extends Node

const MIN_DRAG_MOVE_PIXELS = 2
const MIN_DRAG_MOVE_PIXELS_SQUARED = MIN_DRAG_MOVE_PIXELS * MIN_DRAG_MOVE_PIXELS

var potential_drag_node : Node2D = null
var current : Node2D = null
var current_preview : Node2D = null
var current_button = null
var current_drop_target : Node2D = null
var drag_start_position : Vector2 = Vector2()

var drag_candidates : Array = []
var drop_candidates : Array = []

export(String) var drag_group : String = "draggable"
export(String) var drop_group : String = "droppable"


func register_draggable(draggableArea, draggableOwner):
	draggableArea.connect("mouse_entered",self,"mouse_entered_drag",[draggableOwner])
	draggableArea.connect("mouse_exited",self,"mouse_exited_drag",[draggableOwner])
	draggableArea.connect("input_event",self,"input_event_drag",[draggableOwner])

func register_drop_target(droppableArea, droppableOwner):
	droppableArea.connect("mouse_entered",self,"mouse_entered_drop",[droppableOwner])
	droppableArea.connect("mouse_exited",self,"mouse_exited_drop",[droppableOwner])
	droppableArea.connect("input_event",self,"input_event_drop",[droppableOwner])

func get_top_drop_candidate(drop_source):
	for drop_candidate in drop_candidates:
		if drop_candidate.has_method("is_valid_drop_source") and drop_candidate.is_valid_drop_source(drop_source):
			return drop_candidate
	return null
	
func _process(_delta):
	# If we have a preview, move it to the current mouse position
	if current_preview:
		current_preview.global_position = current.get_global_mouse_position()

	# If we haven't actually started a drag yet, see if the mouse has moved far enough away during the drag yet to start
	elif potential_drag_node and !current:
		var moved_amt = potential_drag_node.get_global_mouse_position() - drag_start_position
		print("Moved during drag by: ", moved_amt)
		if moved_amt.length_squared() >= MIN_DRAG_MOVE_PIXELS_SQUARED:
			start_drag()

func start_drag():
	print_debug("Starting drag for ", potential_drag_node)
	current = potential_drag_node
	if current.has_method("can_start_drag"):
		if !current.can_start_drag(current_button):
			cancel_drag()
			return
	if current.has_method("on_start_drag"):
		current.on_start_drag(current_button)
	if current.has_method("get_drag_preview"):
		current_preview = current.get_drag_preview(current_button)
	if !current_preview:
		current_preview = current.duplicate(0)
		current_preview.modulate = Color(1, 1, 1, 0.3)
	current.raise()
	get_tree().root.add_child(current_preview)
	if current_preview.has_method("setup_preview"):
		current_preview.setup_preview()
	if current_preview.previewed_owner == null:
		current_preview.previewed_owner = current

func cancel_drag():
	current_button = null
	current = null
	potential_drag_node = null
	if current_preview:
		current_preview.queue_free()
		current_preview = null
	

#func _process(delta):
#	if current is Node2D:
#		current.global_position = current.get_global_mouse_position() - drag_offset

func mouse_entered_drag(which):
	if which.has_method('is_drag_preview'): 
		return
	drag_candidates.append(which)
	drag_candidates.sort_custom(self, "depth_sort")
	print_debug("entered draggable")

func mouse_exited_drag(which):
	drag_candidates.erase(which)
	print_debug("exited draggable")

func mouse_entered_drop(which):
	drop_candidates.append(which)
	recalculate_drop_target()
	print_debug("entered droppable")

func mouse_exited_drop(which):
	drop_candidates.erase(which)
	recalculate_drop_target()
	print_debug("exited droppable")

func recalculate_drop_target():
	drop_candidates.sort_custom(self, "depth_sort")
	current_drop_target = drop_candidates.back()
	
func input_event_drag(viewport: Node, event: InputEvent, shape_idx: int, which:Node2D):
	if !(event is InputEventMouseButton):
		return
		
	# If we're not dragging and this is a mouse-down, check to see if we should start dragging
	if !current and !potential_drag_node and event.is_pressed() and !drag_candidates.empty():
		print_debug("Possibly starting drag for ", event.button_index)
		current_button = event.button_index
		potential_drag_node = drag_candidates.back()
		drag_start_position = potential_drag_node.get_global_mouse_position()

func is_valid_drag_button(button_index) -> bool:
	return (button_index == BUTTON_LEFT or button_index == BUTTON_RIGHT)

func _unhandled_input(event):
	if event is InputEventMouseButton and is_valid_drag_button(event.button_index):
		# If this is a mouse-up, check to see if we should drop
		if !event.is_pressed() and event.button_index == current_button:
			#print("Released currently held button")
			# If we had actually started a drag:
			if current:
				#print_debug("Starting drop for button_index=", event.button_index, " and current=", current)
				if current.has_method("on_mouse_drop"):
					current.on_mouse_drop(current_button, current_drop_target, current_preview)
				else:
					printerr('Draggable does not have on_mouse_drop: ', current)
			elif potential_drag_node:
				print_debug("Cancelling drop before it got too far for button_index=", event.button_index, " and current=", current)
			# Regardless of what we did with dropping, we let up on the button we had held so we have to clear our state
			cancel_drag()
			get_tree().set_input_as_handled()

func depth_sort(a,b):
	return b.get_index()>a.get_index()
