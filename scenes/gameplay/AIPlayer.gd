# AIPlayer.gd
extends BasePlayer

var ai_module: AIModule = null
var input_queue: Array[Vector2i] = []

func _ready() -> void:
	if ConfigManager.blue_is_ai:
		# Create and add the AIModule node programmatically
		ai_module = AIModule.new()
		add_child(ai_module)

# Captures keyboard and controller inputs for Player 2 in Human mode
func _unhandled_input(event: InputEvent) -> void:
	if not ConfigManager.blue_is_ai:
		if event.is_action_pressed("p2_moveUp"):
			add_to_queue(Vector2i.UP)
		elif event.is_action_pressed("p2_moveDown"):
			add_to_queue(Vector2i.DOWN)
		elif event.is_action_pressed("p2_moveLeft"):
			add_to_queue(Vector2i.LEFT)
		elif event.is_action_pressed("p2_moveRight"):
			add_to_queue(Vector2i.RIGHT)

func add_to_queue(dir: Vector2i) -> void:
	# Capped at a buffer size of 2 to hold rapid double taps for smooth cornering
	if input_queue.size() >= 2:
		return
		
	# Determine what the direction will be when this input is executed
	var reference_dir = current_direction
	if not input_queue.is_empty():
		reference_dir = input_queue[-1]
		
	# Avoid turning 180 degrees backward into yourself
	if dir != -reference_dir:
		input_queue.append(dir)
		# Immediately rotate the head visual on keypress — eliminates perceived input
		# delay on slow tick speeds. The actual movement still happens on the next tick.
		preview_head_rotation(dir)

func preview_head_rotation(dir: Vector2i) -> void:
	var head = get_node_or_null("NeonHeadArrow")
	if head != null:
		head.rotation = Vector2(dir).angle()

func get_and_consume_direction() -> Vector2i:
	if not input_queue.is_empty():
		current_direction = input_queue.pop_front()
	return current_direction

func clear_queue() -> void:
	input_queue.clear()

# This gets called by the main gameplay coordinator right before a game tick.
# It returns the decided direction Vector2i back to the gameplay script.
func think_and_decide(game_state_data: Dictionary) -> Vector2i:
	if ai_module != null:
		# Dynamically scale time budget to 20% of tick duration, capped at 15ms to prevent main thread lag
		var time_budget = min(15.0, ConfigManager.tick_speed * 1000.0 * 0.20)
		var best_move: Vector2i = ai_module.get_best_move(game_state_data, time_budget, true)
		current_direction = best_move
		return best_move
	return current_direction
