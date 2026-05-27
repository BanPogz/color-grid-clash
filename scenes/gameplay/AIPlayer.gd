# AIPlayer.gd
extends BasePlayer

var ai_module: AIModule

func _ready() -> void:
	# Create and add the AIModule node programmatically
	ai_module = AIModule.new()
	add_child(ai_module)

# This gets called by the main gameplay coordinator right before a game tick.
# It returns the decided direction Vector2i back to the gameplay script.
func think_and_decide(game_state_data: Dictionary) -> Vector2i:
	# Pass the current state and a safe time limit of 150 milliseconds
	var best_move: Vector2i = ai_module.get_best_move(game_state_data, 150.0)
	current_direction = best_move
	return best_move
