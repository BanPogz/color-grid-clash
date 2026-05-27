# AISnake.gd
extends BasePlayer

# This gets called by the main gameplay coordinator right before a game tick
func think_and_decide(game_state_data) -> void:
	# Crystal's Minimax & Van's BFS loops run here
	var best_move = Minimax.calculate_best_move(game_state_data, player_id) 
	current_direction = best_move
