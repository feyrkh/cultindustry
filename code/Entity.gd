extends TextureRect
class_name Entity

const Ticker = preload("res://scene/Ticker.tscn")

export var draggable : bool 
export var connectable : bool
export var tickable : bool setget setTickable

var preview : Control # drag/drop preview
var ticker : Ticker # ticker node, if any

func setTickable(val) -> void:
	if val and !tickable:
		tickable = true
		ticker = Ticker.instance()
		add_child(ticker)
		ticker.connect('onTick', self, 'onTick')
	elif !val and tickable:
		if ticker: ticker.queue_free()
		ticker = null

func onTick():
	pass

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		preview = null

func get_drag_data(_position:Vector2):
	if draggable and Input.is_action_pressed('mouseDrag'):
		preview = Control.new()
		var duplicate = self.duplicate(0)
		duplicate.set_begin(-_position)
		preview.add_child(duplicate)
		preview.modulate.a *= 0.3
		preview.set_begin(-_position)
		set_drag_preview(preview)
		return moveEntityData(_position)
	elif connectable and Input.is_action_pressed('mouseConnect'):
		return connectEntityData()

func can_drop_data(_position:Vector2, _data:Dictionary):
	var result = false
	var otherEntity : Entity = _data['entity']
	if _data['cmd'] == 'move':
		if _data['entity'] == self:
			result = checkValidMovePosition()
		if result == false and otherEntity.preview != null:
			otherEntity.previewDisplayInvalid()
		else:
			otherEntity.previewDisplayValid()
	return result
	
func previewDisplayValid():
	if preview != null:
		preview.modulate.g = 1
		preview.modulate.b = 1

func previewDisplayInvalid():
	if preview != null:
		preview.modulate.g = 0
		preview.modulate.b = 0

func checkValidMovePosition():
	return true

func drop_data(position, data):
	if data['cmd'] == 'move':
		if data['entity'] == self: # Moving slightly, but still overlapping self
			performMove(data['entity'], self.rect_position + position - data['grabPosition'])

func performMove(otherEntity:Entity, position):
	otherEntity.rect_position = position

func moveEntityData(grabPosition:Vector2):
	return {'entity':self, 'cmd':'move', 'grabPosition': grabPosition}

func connectEntityData():
	var type = getConnectSourceType()
	if type: return {'entity':self, 'cmd':'connect', 'type':type}

func getConnectSourceType():
	return null
