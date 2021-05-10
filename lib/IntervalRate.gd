extends Object

var _interval:float setget setInterval
var _actionsPerInterval:float setget setActionsPerInterval, getActionsPerInterval
var _intervalsPerAction:float setget setIntervalsPerAction, getIntervalsPerAction
var _actionsPerTimeUnit:float
var _timeUnitsPerAction:float
var _accum:float

func _init(actions:float, interval:float):
	_accum = 0
	_interval = interval
	setActionsPerInterval(actions)

func accumulate(delta:float) -> void:
	_accum += delta

func actionTriggered() -> bool:
	if _accum > _timeUnitsPerAction:
		_accum -= _timeUnitsPerAction
		return true
	return false

func setInterval(interval:float) -> void:
	_interval = interval
	_actionsPerTimeUnit = _actionsPerInterval/_interval
	_timeUnitsPerAction = 1.0/_actionsPerTimeUnit

func setActionsPerInterval(api:float) -> void:
	_actionsPerInterval = api
	_intervalsPerAction = 1.0/api
	_actionsPerTimeUnit = api/_interval
	_timeUnitsPerAction = 1.0/_actionsPerTimeUnit

func setIntervalsPerAction(ipa) -> void:
	_intervalsPerAction = ipa
	_actionsPerInterval = 1.0/ipa
	_actionsPerTimeUnit = _actionsPerInterval/_interval
	_timeUnitsPerAction = 1.0/_actionsPerTimeUnit

func getActionsPerInterval() -> float:
	return _actionsPerInterval

func getIntervalsPerAction() -> float:
	return _intervalsPerAction

func getActionsPerTimeUnit() -> float:
	return _actionsPerTimeUnit

func getTimeUnitsPerInterval() -> float:
	return _interval
