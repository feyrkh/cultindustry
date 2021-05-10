extends Node

signal onTick(delta)

const IntervalRate = preload('res://lib/IntervalRate.gd')

var tickTimer = IntervalRate.new(10, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	tickTimer.accumulate(delta)
	while tickTimer.actionTriggered():
		emit_signal("onTick", 1)
