# AIPlayer.gd
extends BasePlayer

var ai_module: AIModule = null

func _ready() -> void:
	if ConfigManager.blue_is_ai:
		# Create and add the AIModule node programmatically
		ai_module = AIModule.new()
		add_child(ai_module)

# Captures keyboard and controller inputs for Player 2 in Human mode
func _unhandled_input(event: InputEvent) -> void:
	if not ConfigManager.blue_is_ai:
		if event.is_action_pressed("p2_moveUp") and current_direction != Vector2i.DOWN:
			current_direction = Vector2i.UP
		elif event.is_action_pressed("p2_moveDown") and current_direction != Vector2i.UP:
			current_direction = Vector2i.DOWN
		elif event.is_action_pressed("p2_moveLeft") and current_direction != Vector2i.RIGHT:
			current_direction = Vector2i.LEFT
		elif event.is_action_pressed("p2_moveRight") and current_direction != Vector2i.LEFT:
			current_direction = Vector2i.RIGHT

# This gets called by the main gameplay coordinator right before a game tick.
# It returns the decided direction Vector2i back to the gameplay script.
func think_and_decide(game_state_data: Dictionary) -> Vector2i:
	if ai_module != null:
		# Pass the current state and a safe time limit of 150 milliseconds
		var best_move: Vector2i = ai_module.get_best_move(game_state_data, 150.0, true)
		current_direction = best_move
		return best_move
	return current_direction
