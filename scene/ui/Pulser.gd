extends Node

export(bool) var enabled = false
export(float) var periodSeconds = 0.5
export(Color) var pulseColor = Color(2.5, 2.5, 2.5)
export(Color) var startColor = Color.white
var counter:float = 0
var timer = null

func _ready():
	connect("tree_exiting", self, "stop")

func _process(delta):
	if !enabled:
		set_process(false)
	counter += delta
	get_parent().modulate = lerp(startColor, pulseColor, 1-abs(sin(counter/periodSeconds)))
	if timer:
		timer -= delta
		if timer < 0: 
			stop()
			queue_free()

func start(pulseTime = null):
	if pulseTime and timer:
		timer = max(pulseTime, timer)
	else: 
		timer = pulseTime
	if enabled: 
		return
	counter = 0
	set_process(true)
	enabled = true

func stop():
	counter = 0
	get_parent().modulate = Color.white
	set_process(false)
	enabled = false
