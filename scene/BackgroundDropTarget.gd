extends MarginContainer


func can_drop_data(_position:Vector2, data:Dictionary):
	var result =true
	var otherEntity : Entity = data['entity']
	if data['cmd'] == 'move':
		if result:
			otherEntity.previewDisplayValid()
		else:
			otherEntity.previewDisplayInvalid()
	return result


func drop_data(position, data):
	var otherEntity : Entity = data['entity']
	if data['cmd'] == 'move':
		if data['entity']:
			otherEntity.performMove(data['entity'], self.rect_position + position - data['grabPosition'])
