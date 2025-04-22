extends Node

var logging = true
var player: Player
var item_tooltip: ItemTooltip
var item_interface: ItemInterface
var terrain: Terrain3D
var watched_tv := false

var logged_variables = {}
var alpha = 10
func update_log(var_name: String, value):
	if not (logged_variables.has(var_name)):
		logged_variables[var_name] = value
		return
	if typeof(logged_variables[var_name]) != typeof(value):
		logged_variables[var_name] = value
		return
	if typeof(value) == typeof(1.):
		var current_weight = alpha * get_process_delta_time()
		logged_variables[var_name] = logged_variables[var_name] * (1-current_weight) + current_weight * value
		return
	logged_variables[var_name] = value

var last_logged = 0
var logging_interval = .5
func _process(_delta):
	if logging:
		handle_logging()
	

func handle_logging():
	if time() > last_logged + logging_interval:
		last_logged = time()
		for key in logged_variables.keys():
			print("%s: %s" % [key, logged_variables[key]])

func time() -> float:
	return Time.get_ticks_usec() / 10.**6
