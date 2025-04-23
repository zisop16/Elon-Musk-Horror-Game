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
	
## Generate uniform random euler rotation
func generate_random_rotation() -> Vector3:
	## Choose three points u, v, w ∈ [0,1] uniformly at random. A uniform, random quaternion is given by the simple expression:
	## h = ( sqrt(1-u) sin(2πv), sqrt(1-u) cos(2πv), sqrt(u) sin(2πw), sqrt(u) cos(2πw))
	var u := randf()
	var v := randf()
	var w := randf()
	var h := Quaternion(sqrt(1-u) * sin(2*PI*v), sqrt(1-u) * cos(2*PI*v), sqrt(u) * sin(2*PI*w), sqrt(u) * cos(2*PI*w))
	return h.get_euler()

func handle_logging():
	if time() > last_logged + logging_interval:
		last_logged = time()
		for key in logged_variables.keys():
			print("%s: %s" % [key, logged_variables[key]])

func time() -> float:
	return Time.get_ticks_usec() / 10.**6
