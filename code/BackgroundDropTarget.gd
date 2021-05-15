extends MarginContainer

func can_drop_data(_position:Vector2, data:Dictionary):
	var result = false
	var otherEntity : Entity = data['entity']
	if data['cmd'] == 'move':
		if otherEntity.has_method('checkValidMovePosition'):
			result = otherEntity.checkValidMovePosition()
	otherEntity.previewDisplayValid(result)
	return result


func drop_data(position, data):
	var otherEntity : Entity = data['entity']
	print_debug("grabPosition: ", data['grabPosition'])
	if data['cmd'] == 'move':
		if data['entity']:
			otherEntity.performMove(data['entity'], self.rect_position + position - (data['grabPosition'] * otherEntity.rect_scale.x))
