extends Node
class_name Ticker

signal onTick

# Called when the node enters the scene tree for the first time.
func _ready():
	SimMgr.connect('onTick', self, '_tick')

func _tick(delta:int):
	for i in delta:
		emit_signal("onTick")
