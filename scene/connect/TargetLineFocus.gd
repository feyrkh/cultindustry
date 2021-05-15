extends TextureRect
class_name TargetLineFocus

const rotate_speed = 10
const DEFAULT_ALPHA = 0.4
const HIGHLIGHT_ALPHA = 0.8
const OFFSET_RADIANS = deg2rad(12)

var sourceToken # the token this is originates from
var radialOffset # when idle, how many radians to offset your position to accomodate other foci
var targetToken setget set_target_token # the token this is focused on, if any
var idleVector:Vector2
var rotateCounter = 0
var targetLine
var offsetSlot = 0
var lineLayer # where to create connecting lines

var dupe
var dupeLine

func cleanup():
	targetLine = null
	targetToken = null

func _ready():
	idleVector = Vector2(sourceToken.radius+rect_size.x/2, 0)
	modulate = sourceToken.color
	modulate.a = 0.3
	$Pulser.startColor = modulate

func is_target_line_focus(): return true

func _process(delta):
	if dupe:
		self.visible = false
		dupe.rect_global_position = get_global_mouse_position() - rect_size/2
		dupeLine.points[1] = get_global_mouse_position()
		dupeLine.default_color = self.modulate
		dupe.modulate = self.modulate
	elif !visible:
		visible = true
		if dupeLine: dupeLine.queue_free()
	if !sourceToken.pauseTargets:
		rotateCounter += delta
	if targetLine:
		self.rect_position = targetLine.points[targetLine.points.size()-1]-rect_size/2
	elif !targetToken:
		var rot = lerp(0, 2*PI, fmod(rotateCounter, rotate_speed)/rotate_speed) + radialOffset
		self.rect_position = idleVector.rotated(rot) + sourceToken.rect_position - rect_size/2

func set_target_token(newTarget):
	if dupeLine: 
		dupeLine.queue_free()
	self.visible = true
	if !newTarget or !newTarget.has_method('is_token'):
		clear_target()
		targetToken = null
	elif newTarget == sourceToken:
		return # targeting yourself?!
	elif newTarget == targetToken:
		return # targeting the same person again
	else:
		clear_target()
		targetToken = null
		var nextOffsetSlot = sourceToken.get_next_offset_slot(newTarget)
		targetToken = newTarget
		self.offsetSlot = nextOffsetSlot
		targetLine = load("res://combat/TargetLine.tscn").instance()
		targetLine.targetLineFocus = self
		targetLine.sourceToken = sourceToken
		targetLine.targetToken = newTarget
		targetLine.default_color = sourceToken.color
		#targetLine.offsetRadians = OFFSET_RADIANS * ((sourceToken.get_targets_on(newTarget).size() - 1) * 2)
		targetLine.offsetRadians = OFFSET_RADIANS * nextOffsetSlot
		lineLayer.add_child(targetLine)

func clear_target():
	if targetLine:
		targetLine.cleanup()
		Event.emit_signal("updateTargetLines")

func get_drag_data(pos):
#	var icon = TextureRect.new()
#	icon.texture = load('res://img/combat/combat_token.png')
	var icon = Control.new()
	dupe = duplicate(0)
	dupe.rect_position = Vector2.ZERO
	#dupe.rect_position = dupe.get_global_rect().position - get_global_mouse_position()
	dupe.modulate.a = 0.3
	icon.add_child(dupe) #load('res://combat/TokenPreview.tscn').instance()
	set_drag_preview(icon)
	dupeLine = Line2D.new()
	dupeLine.default_color = self.modulate
	dupeLine.width = 2
	dupeLine.points = [rect_position + rect_size/2, 0]
	lineLayer.add_child(dupeLine)
	sourceToken.pauseTargets = false
	return self

func can_drop_data(pos, data): 
	if (data.has_method('is_token') and !data.dead) or data.has_method('is_target_line_focus'):
		return true
	return false

func drop_data(pos, data):
	if data.has_method('is_token'):
		data.rect_position = pos + self.rect_position
		Event.emit_signal("update_target_lines")
	elif data.has_method('is_target_line_focus'):
		data.targetToken = self.targetToken

func _on_TargetLineFocus_mouse_entered():
	modulate.a = HIGHLIGHT_ALPHA
	if targetToken == null:
		sourceToken.pauseTargets = true

func _on_TargetLineFocus_mouse_exited():
	modulate.a = DEFAULT_ALPHA
	if targetToken == null:
		sourceToken.pauseTargets = false


