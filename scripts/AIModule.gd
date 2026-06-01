extends Node
class_name AIModule

# Constants mapping directly to your Gameplay configuration
enum CellType { EMPTY, WALL, RED_TRAIL, BLUE_TRAIL, ENERGY_CORE, RARE_ENERGY_CORE }

const WIN_SCORE = 100000.0
const LOSS_SCORE = -100000.0
const TIMEOUT_SIGNAL = -999999.0

# Define cardinal movement vectors
const DIRECTIONS = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]

var grid_width: int = 20
var grid_height: int = 20

var last_depth: int = 0
var last_nodes_evaluated: int = 0
var nodes_count_in_search: int = 0

# Main AI Entry Routine (Called by the Coordinator on the AI's Tick)
func get_best_move(current_state: Dictionary, time_limit_ms: float, is_maximizing_player: bool = true) -> Vector2i:
	nodes_count_in_search = 0
	var legal_moves = get_legal_moves(current_state, is_maximizing_player)
	if legal_moves.is_empty():
		last_depth = 1
		last_nodes_evaluated = 0
		return Vector2i.RIGHT # Trapped anyway, default backup
		
	var best_move: Vector2i = legal_moves[0] # Fallback
	var start_time: float = Time.get_ticks_msec()
	var depth: int = 1
	
	while (Time.get_ticks_msec() - start_time) < time_limit_ms:
		# Deep-copy the state data structure so simulation branches don't overwrite the original board
		var state_copy = clone_state(current_state)
		
		var result = alpha_beta_search(state_copy, depth, -INF, INF, is_maximizing_player, start_time, time_limit_ms)
		
		# If the search completed fully without a timeout signal, commit the found path
		if result["score"] != TIMEOUT_SIGNAL:
			best_move = result["move"]
			depth += 1
		else:
			break # Stop search immediately if budget blown
			
	last_depth = depth - 1
	last_nodes_evaluated = nodes_count_in_search
	return best_move

# Alpha-Beta Minimax Core
func alpha_beta_search(state: Dictionary, depth: int, alpha: float, beta: float, is_max: bool, start_time: float, time_limit: float) -> Dictionary:
	nodes_count_in_search += 1
	# 1. Real-time budget tracking
	if (Time.get_ticks_msec() - start_time) >= time_limit:
		return {"move": Vector2i.ZERO, "score": TIMEOUT_SIGNAL}
		
	# 2. Base Cases: Depth cutoff or Terminal state check
	var terminal_status = check_terminal(state)
	if depth == 0 or terminal_status["is_terminal"]:
		return {"move": Vector2i.ZERO, "score": evaluate(state, terminal_status)}
		
	var legal_moves = get_legal_moves(state, is_max)
	
	# 3. Trapped Condition Handling
	if legal_moves.is_empty():
		return {"move": Vector2i.ZERO, "score": LOSS_SCORE if is_max else WIN_SCORE}
		
	# 4. Move Ordering to maximize Pruning efficiency
	legal_moves = order_moves(legal_moves, state, is_max)
	var best_move: Vector2i = legal_moves[0]
	
	if is_max: # AI's turn (MAX / Blue)
		var max_eval = -INF
		for move in legal_moves:
			var child_state = apply_move(state, move, true)
			var result = alpha_beta_search(child_state, depth - 1, alpha, beta, false, start_time, time_limit)
			
			if result["score"] == TIMEOUT_SIGNAL: 
				return result
				
			if result["score"] > max_eval:
				max_eval = result["score"]
				best_move = move
				
			alpha = max(alpha, result["score"])
			if alpha >= beta:
				break # Prune branch
		return {"move": best_move, "score": max_eval}
		
	else: # Human's turn (MIN / Red)
		var min_eval = INF
		for move in legal_moves:
			var child_state = apply_move(state, move, false)
			var result = alpha_beta_search(child_state, depth - 1, alpha, beta, true, start_time, time_limit)
			
			if result["score"] == TIMEOUT_SIGNAL: 
				return result
				
			if result["score"] < min_eval:
				min_eval = result["score"]
				best_move = move
				
			beta = min(beta, result["score"])
			if alpha >= beta:
				break # Prune branch
		return {"move": best_move, "score": min_eval}

# Mathematical Evaluation Function
func evaluate(state: Dictionary, terminal_status: Dictionary) -> float:
	# Fixes the heuristic tracking issue by assigning massive values to true victory states
	if terminal_status["is_terminal"]:
		if terminal_status["winner"] == "BLUE": return WIN_SCORE
		if terminal_status["winner"] == "RED": return LOSS_SCORE
		return 0.0 # Draw
		
	var blue_trail: int = state["blue_trail_count"]
	var red_trail: int = state["red_trail_count"]
	
	var blue_reach: int = bfs_reachable(state, state["blue_pos"])
	var red_reach: int = bfs_reachable(state, state["red_pos"])
	
	var blue_bonus: float = state.get("blue_bonus", 0.0)
	var red_bonus: float = state.get("red_bonus", 0.0)
	
	# Group Weights: w1 = 1.0, w2 = 2.0, plus core bonuses
	return 1.0 * (blue_trail - red_trail) + 2.0 * (blue_reach - red_reach) + (blue_bonus - red_bonus)

# Breadth-First Search (BFS) for Flood-Fill Spatial Analysis
func bfs_reachable(state: Dictionary, head_pos: Vector2i) -> int:
	var matrix = state["matrix"]
	var visited = {} # Dictionary utilized as a high-performance hash set
	var queue: Array[Vector2i] = []
	
	# Prime the queue with valid adjacent steps
	for dir in DIRECTIONS:
		var neighbor = head_pos + dir
		if is_empty_cell(matrix, neighbor):
			queue.append(neighbor)
			
	while not queue.is_empty():
		var cell = queue.pop_front()
		if not visited.has(cell):
			visited[cell] = true
			for dir in DIRECTIONS:
				var neighbor = cell + dir
				if is_empty_cell(matrix, neighbor) and not visited.has(neighbor):
					queue.append(neighbor)
					
	return visited.size()

# Move Ordering Optimization Layer
func order_moves(moves: Array, state: Dictionary, is_max: bool) -> Array:
	var scored_moves = []
	for move in moves:
		var child = apply_move(state, move, is_max)
		var current_head = child["blue_pos"] if is_max else child["red_pos"]
		var space_score = bfs_reachable(child, current_head)
		scored_moves.append({"move": move, "score": space_score})
		
	# Sort array using an inline custom lambda configuration
	if is_max:
		scored_moves.sort_custom(func(a, b): return a["score"] > b["score"]) # Descending
	else:
		scored_moves.sort_custom(func(a, b): return a["score"] < b["score"]) # Ascending
		
	var sorted_moves = []
	for item in scored_moves:
		sorted_moves.append(item["move"])
	return sorted_moves

# --- Simulation & Game Utility Helpers ---

func get_legal_moves(state: Dictionary, is_max: bool) -> Array:
	var legal = []
	var head = state["blue_pos"] if is_max else state["red_pos"]
	for dir in DIRECTIONS:
		var target = head + dir
		if is_empty_cell(state["matrix"], target):
			legal.append(dir)
	return legal

func is_empty_cell(matrix: Array, pos: Vector2i) -> bool:
	if pos.x < 0 or pos.x >= grid_width or pos.y < 0 or pos.y >= grid_height:
		return false
	var type = matrix[pos.x][pos.y]
	return type == CellType.EMPTY or type == CellType.ENERGY_CORE or type == CellType.RARE_ENERGY_CORE

func apply_move(state: Dictionary, move: Vector2i, is_max: bool) -> Dictionary:
	var next_state = clone_state(state)
	if is_max:
		next_state["matrix"][state["blue_pos"].x][state["blue_pos"].y] = CellType.BLUE_TRAIL
		next_state["blue_pos"] += move
		next_state["blue_trail_count"] += 1
		
		# Check if Blue is stepping onto an energy core
		var target_type = next_state["matrix"][next_state["blue_pos"].x][next_state["blue_pos"].y]
		if target_type == CellType.ENERGY_CORE:
			next_state["blue_bonus"] += 15.0
			next_state["matrix"][next_state["blue_pos"].x][next_state["blue_pos"].y] = CellType.EMPTY # consume standard core in simulation
		elif target_type == CellType.RARE_ENERGY_CORE:
			next_state["blue_bonus"] += 30.0
			next_state["matrix"][next_state["blue_pos"].x][next_state["blue_pos"].y] = CellType.EMPTY # consume rare core in simulation
	else:
		next_state["matrix"][state["red_pos"].x][state["red_pos"].y] = CellType.RED_TRAIL
		next_state["red_pos"] += move
		next_state["red_trail_count"] += 1
		
		# Check if Red is stepping onto an energy core
		var target_type = next_state["matrix"][next_state["red_pos"].x][next_state["red_pos"].y]
		if target_type == CellType.ENERGY_CORE:
			next_state["red_bonus"] += 15.0
			next_state["matrix"][next_state["red_pos"].x][next_state["red_pos"].y] = CellType.EMPTY # consume standard core in simulation
		elif target_type == CellType.RARE_ENERGY_CORE:
			next_state["red_bonus"] += 30.0
			next_state["matrix"][next_state["red_pos"].x][next_state["red_pos"].y] = CellType.EMPTY # consume rare core in simulation
	return next_state

func check_terminal(state: Dictionary) -> Dictionary:
	var matrix = state["matrix"]
	var r_pos = state["red_pos"]
	var b_pos = state["blue_pos"]
	
	# Check if either head has stepped into an out-of-bounds or non-empty/unsafe block
	var red_crashed = not is_empty_cell(matrix, r_pos)
	var blue_crashed = not is_empty_cell(matrix, b_pos)
	
	if red_crashed and blue_crashed: return {"is_terminal": true, "winner": "DRAW"}
	if red_crashed: return {"is_terminal": true, "winner": "BLUE"}
	if blue_crashed: return {"is_terminal": true, "winner": "RED"}
	return {"is_terminal": false, "winner": ""}

func clone_state(state: Dictionary) -> Dictionary:
	var cloned_matrix = []
	for x in range(grid_width):
		cloned_matrix.append(state["matrix"][x].duplicate())
	return {
		"matrix": cloned_matrix,
		"red_pos": state["red_pos"],
		"blue_pos": state["blue_pos"],
		"red_trail_count": state["red_trail_count"],
		"blue_trail_count": state["blue_trail_count"],
		"red_bonus": state.get("red_bonus", 0.0),
		"blue_bonus": state.get("blue_bonus", 0.0)
	}
