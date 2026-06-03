# AIDemoTracer.gd
extends RefCounted
class_name AIDemoTracer

# Mirrors AIModule.gd CellType and Direction Vectors
enum CellType { EMPTY, WALL, RED_TRAIL, BLUE_TRAIL, ENERGY_CORE, RARE_ENERGY_CORE }
const DIRECTIONS = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]

var grid_width: int = 20
var grid_height: int = 20

var trace_steps: Array = []
var nodes_evaluated: int = 0
var root_depth: int = 2
var final_best_move: Vector2i = Vector2i.RIGHT

# Run depth-limited Minimax tracing and return a linear timeline array of steps
func run_trace(initial_state: Dictionary, max_depth: int = 2) -> Array:
	trace_steps = []
	nodes_evaluated = 0
	root_depth = max_depth
	final_best_move = Vector2i.RIGHT
	
	var state_copy = clone_state(initial_state)
	
	# Red is P1, the MIN player (is_max = false)
	# Alpha = -100000, Beta = 100000
	var _final_val = minimax_trace(state_copy, max_depth, -100000.0, 100000.0, false)
	
	return trace_steps

# Main minimax tracing recursion mapping exactly to the 29-line pseudocode
func minimax_trace(state: Dictionary, depth: int, alpha: float, beta: float, is_max: bool) -> float:
	# Line 1: func minimax(state, depth, alpha, beta, is_max)
	var vars = {}
	record_step(1, state, depth, alpha, beta, is_max, 0.0, vars)
	
	# Line 2: nodes_evaluated += 1
	nodes_evaluated += 1
	record_step(2, state, depth, alpha, beta, is_max, 0.0, vars)
	
	# Line 3: if depth == 0 or check_terminal(state):
	var is_terminal_res = check_terminal(state)
	var terminal_cond = (depth == 0 or is_terminal_res["is_terminal"])
	vars["is_terminal"] = terminal_cond
	record_step(3, state, depth, alpha, beta, is_max, 0.0, vars)
	
	# Line 4: return evaluate(state)
	if terminal_cond:
		var score = evaluate(state)
		record_step(4, state, depth, alpha, beta, is_max, score, vars)
		return score
		
	# Line 5: var moves = order_moves(get_legal_moves(state, is_max), state, is_max)
	var legal_moves = get_legal_moves(state, is_max)
	var ordered_moves = order_moves(legal_moves, state, is_max)
	vars["moves"] = ordered_moves
	record_step(5, state, depth, alpha, beta, is_max, 0.0, vars)
	
	# Line 6: if is_max: # AI Player's turn (Blue)
	record_step(6, state, depth, alpha, beta, is_max, 0.0, vars)
	if is_max:
		# Line 7: var max_eval = -INF
		var max_eval = -1000000.0
		vars["max_eval"] = max_eval
		record_step(7, state, depth, alpha, beta, is_max, 0.0, vars)
		
		# Line 8: for move in moves:
		var best_move = Vector2i.ZERO
		for move in ordered_moves:
			vars["move"] = move
			record_step(8, state, depth, alpha, beta, is_max, 0.0, vars)
			
			# Line 9: var child = apply_move(state, move, true)
			var child = apply_move(state, move, true)
			vars["child"] = child
			record_step(9, state, depth, alpha, beta, is_max, 0.0, vars)
			
			# Line 10: var val = minimax(child, depth-1, alpha, beta, false)
			record_step(10, state, depth, alpha, beta, is_max, 0.0, vars) # pre-call
			var val = minimax_trace(child, depth - 1, alpha, beta, false)
			vars["val"] = val
			record_step(10, state, depth, alpha, beta, is_max, val, vars) # post-call
			
			# Line 11: if val > max_eval:
			var condition = val > max_eval
			vars["val_greater_than_max_eval"] = condition
			record_step(11, state, depth, alpha, beta, is_max, 0.0, vars)
			
			if condition:
				# Line 12: max_eval = val
				max_eval = val
				vars["max_eval"] = max_eval
				record_step(12, state, depth, alpha, beta, is_max, 0.0, vars)
				
				# Line 13: best_move = move
				best_move = move
				vars["best_move"] = best_move
				record_step(13, state, depth, alpha, beta, is_max, 0.0, vars)
				if depth == root_depth:
					final_best_move = best_move
				
			# Line 14: alpha = max(alpha, val)
			alpha = max(alpha, val)
			vars["alpha"] = alpha
			record_step(14, state, depth, alpha, beta, is_max, 0.0, vars)
			
			# Line 15: if alpha >= beta:
			var prune = alpha >= beta
			vars["pruned"] = prune
			record_step(15, state, depth, alpha, beta, is_max, 0.0, vars)
			
			if prune:
				# Line 16: break # Pruned!
				record_step(16, state, depth, alpha, beta, is_max, 0.0, vars)
				break
				
		# Line 17: return max_eval
		record_step(17, state, depth, alpha, beta, is_max, max_eval, vars)
		return max_eval
		
	else: # Human/Min Player's turn (Red)
		# Line 18: else: # Human/Min Player's turn
		record_step(18, state, depth, alpha, beta, is_max, 0.0, vars)
		
		# Line 19: var min_eval = INF
		var min_eval = 1000000.0
		vars["min_eval"] = min_eval
		record_step(19, state, depth, alpha, beta, is_max, 0.0, vars)
		
		# Line 20: for move in moves:
		var best_move = Vector2i.ZERO
		for move in ordered_moves:
			vars["move"] = move
			record_step(20, state, depth, alpha, beta, is_max, 0.0, vars)
			
			# Line 21: var child = apply_move(state, move, false)
			var child = apply_move(state, move, false)
			vars["child"] = child
			record_step(21, state, depth, alpha, beta, is_max, 0.0, vars)
			
			# Line 22: var val = minimax(child, depth-1, alpha, beta, true)
			record_step(22, state, depth, alpha, beta, is_max, 0.0, vars) # pre-call
			var val = minimax_trace(child, depth - 1, alpha, beta, true)
			vars["val"] = val
			record_step(22, state, depth, alpha, beta, is_max, val, vars) # post-call
			
			# Line 23: if val < min_eval:
			var condition = val < min_eval
			vars["val_less_than_min_eval"] = condition
			record_step(23, state, depth, alpha, beta, is_max, 0.0, vars)
			
			if condition:
				# Line 24: min_eval = val
				min_eval = val
				vars["min_eval"] = min_eval
				record_step(24, state, depth, alpha, beta, is_max, 0.0, vars)
				
				# Line 25: best_move = move
				best_move = move
				vars["best_move"] = best_move
				record_step(25, state, depth, alpha, beta, is_max, 0.0, vars)
				if depth == root_depth:
					final_best_move = best_move
				
			# Line 26: beta = min(beta, val)
			beta = min(beta, val)
			vars["beta"] = beta
			record_step(26, state, depth, alpha, beta, is_max, 0.0, vars)
			
			# Line 27: if alpha >= beta:
			var prune = alpha >= beta
			vars["pruned"] = prune
			record_step(27, state, depth, alpha, beta, is_max, 0.0, vars)
			
			if prune:
				# Line 28: break # Pruned!
				record_step(28, state, depth, alpha, beta, is_max, 0.0, vars)
				break
				
		# Line 29: return min_eval
		record_step(29, state, depth, alpha, beta, is_max, min_eval, vars)
		return min_eval

# Helper to record structural step details into trace_steps array
func record_step(line_num: int, state: Dictionary, depth: int, alpha: float, beta: float, is_max: bool, val: float, vars: Dictionary) -> void:
	var red_reach = bfs_reachable(state, state["red_pos"])
	var blue_reach = bfs_reachable(state, state["blue_pos"])
	
	var explanation = get_line_explanation(line_num, depth, is_max, vars)
	
	var step = {
		"line_num": line_num,
		"depth": depth,
		"alpha": alpha,
		"beta": beta,
		"is_max": is_max,
		"val": val,
		"matrix": clone_matrix(state["matrix"]),
		"red_pos": state["red_pos"],
		"blue_pos": state["blue_pos"],
		"red_trail_count": state["red_trail_count"],
		"blue_trail_count": state["blue_trail_count"],
		"red_reach_count": red_reach["count"],
		"red_reach_cells": red_reach["cells"],
		"blue_reach_count": blue_reach["count"],
		"blue_reach_cells": blue_reach["cells"],
		"nodes_evaluated": nodes_evaluated,
		"vars": vars.duplicate(true),
		"explanation": explanation
	}
	trace_steps.append(step)

# Plain English explanations for each line in the pseudocode to assist educational walkthroughs
func get_line_explanation(line_num: int, depth: int, is_max: bool, vars: Dictionary) -> String:
	match line_num:
		1:
			return "Entering minimax search tree at depth %d. Turn: %s" % [depth, "MAX (Blue)" if is_max else "MIN (Red)"]
		2:
			return "Evaluating state. Nodes evaluated: %d." % nodes_evaluated
		3:
			return "Checking if depth is 0 or if a player crashed."
		4:
			return "Cutoff depth reached. Position score: %.1f." % (vars.get("val", 0.0) if vars.has("val") else 0.0)
		5:
			var moves_str = ""
			if vars.has("moves"):
				moves_str = str(vars["moves"])
			return "Generating and sorting valid directions: %s." % moves_str
		6:
			return "Checking if it is Blue's turn."
		7:
			return "Blue AI turn: Initializing search value to -INF."
		8:
			var m = vars.get("move", Vector2i.ZERO)
			return "Simulating direction %s for Blue." % get_direction_name(m)
		9:
			return "Simulating board state after Blue moves."
		10:
			if vars.has("val"):
				return "Recursive search returned a score of %.1f." % vars["val"]
			return "Searching for Red's best response."
		11:
			return "Comparing branch value %.1f with previous best %.1f." % [vars.get("val", 0.0), vars.get("max_eval", -1000000.0)]
		12:
			return "Updating best value for Blue to %.1f." % vars.get("max_eval", 0.0)
		13:
			return "Updating local best move to %s." % get_direction_name(vars.get("best_move", Vector2i.ZERO))
		14:
			return "Updating alpha to %.1f." % vars.get("alpha", 0.0)
		15:
			return "Comparing alpha with beta to check for pruning."
		16:
			return "Alpha >= Beta: Pruning this branch."
		17:
			return "Blue search complete. Returning score: %.1f." % vars.get("max_eval", 0.0)
		18:
			return "Red Player turn logic activated."
		19:
			return "Red Player turn: Initializing search value to +INF."
		20:
			var m = vars.get("move", Vector2i.ZERO)
			return "Simulating direction %s for Red." % get_direction_name(m)
		21:
			return "Simulating board state after Red moves."
		22:
			if vars.has("val"):
				return "Recursive search returned a score of %.1f." % vars["val"]
			return "Searching for Blue's best response."
		23:
			return "Comparing branch value %.1f with previous best %.1f." % [vars.get("val", 0.0), vars.get("min_eval", 1000000.0)]
		24:
			return "Updating best value for Red to %.1f." % vars.get("min_eval", 0.0)
		25:
			return "Updating local best move to %s." % get_direction_name(vars.get("best_move", Vector2i.ZERO))
		26:
			return "Updating beta to %.1f." % vars.get("beta", 0.0)
		27:
			return "Comparing alpha with beta to check for pruning."
		28:
			return "Alpha >= Beta: Pruning this branch."
		29:
			return "Red search complete. Returning score: %.1f." % vars.get("min_eval", 0.0)
		_:
			return "Executing minimax routine..."

func get_direction_name(dir: Vector2i) -> String:
	if dir == Vector2i.UP: return "UP"
	if dir == Vector2i.DOWN: return "DOWN"
	if dir == Vector2i.LEFT: return "LEFT"
	if dir == Vector2i.RIGHT: return "RIGHT"
	return "STATIONARY"

# BFS Reachable calculations mirroring AIModule
func bfs_reachable(state: Dictionary, head_pos: Vector2i) -> Dictionary:
	var matrix = state["matrix"]
	var visited = {}
	var queue: Array = []
	
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
					
	return {"count": visited.size(), "cells": visited.keys()}

func evaluate(state: Dictionary) -> float:
	var terminal_status = check_terminal(state)
	if terminal_status["is_terminal"]:
		if terminal_status["winner"] == "BLUE": return 100000.0
		if terminal_status["winner"] == "RED": return -100000.0
		return 0.0 # Draw
		
	var blue_trail: int = state["blue_trail_count"]
	var red_trail: int = state["red_trail_count"]
	
	var blue_reach_res = bfs_reachable(state, state["blue_pos"])
	var red_reach_res = bfs_reachable(state, state["red_pos"])
	
	var blue_bonus: float = state.get("blue_bonus", 0.0)
	var red_bonus: float = state.get("red_bonus", 0.0)
	
	# Evaluator formula matches AIModule.gd
	return 1.0 * (blue_trail - red_trail) + 2.0 * (blue_reach_res["count"] - red_reach_res["count"]) + (blue_bonus - red_bonus)

func order_moves(moves: Array, state: Dictionary, is_max: bool) -> Array:
	var scored_moves = []
	for move in moves:
		var child = apply_move(state, move, is_max)
		var current_head = child["blue_pos"] if is_max else child["red_pos"]
		var space_score = bfs_reachable(child, current_head)["count"]
		scored_moves.append({"move": move, "score": space_score})
		
	if is_max:
		scored_moves.sort_custom(func(a, b): return a["score"] > b["score"]) # Descending
	else:
		scored_moves.sort_custom(func(a, b): return a["score"] < b["score"]) # Ascending
		
	var sorted_moves = []
	for item in scored_moves:
		sorted_moves.append(item["move"])
	return sorted_moves

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
		
		var target_type = next_state["matrix"][next_state["blue_pos"].x][next_state["blue_pos"].y]
		if target_type == CellType.ENERGY_CORE:
			next_state["blue_bonus"] += 15.0
			next_state["matrix"][next_state["blue_pos"].x][next_state["blue_pos"].y] = CellType.EMPTY
		elif target_type == CellType.RARE_ENERGY_CORE:
			next_state["blue_bonus"] += 30.0
			next_state["matrix"][next_state["blue_pos"].x][next_state["blue_pos"].y] = CellType.EMPTY
	else:
		next_state["matrix"][state["red_pos"].x][state["red_pos"].y] = CellType.RED_TRAIL
		next_state["red_pos"] += move
		next_state["red_trail_count"] += 1
		
		var target_type = next_state["matrix"][next_state["red_pos"].x][next_state["red_pos"].y]
		if target_type == CellType.ENERGY_CORE:
			next_state["red_bonus"] += 15.0
			next_state["matrix"][next_state["red_pos"].x][next_state["red_pos"].y] = CellType.EMPTY
		elif target_type == CellType.RARE_ENERGY_CORE:
			next_state["red_bonus"] += 30.0
			next_state["matrix"][next_state["red_pos"].x][next_state["red_pos"].y] = CellType.EMPTY
	return next_state

func check_terminal(state: Dictionary) -> Dictionary:
	var matrix = state["matrix"]
	var r_pos = state["red_pos"]
	var b_pos = state["blue_pos"]
	
	var red_crashed = not is_empty_cell(matrix, r_pos)
	var blue_crashed = not is_empty_cell(matrix, b_pos)
	
	if red_crashed and blue_crashed: return {"is_terminal": true, "winner": "DRAW"}
	if red_crashed: return {"is_terminal": true, "winner": "BLUE"}
	if blue_crashed: return {"is_terminal": true, "winner": "RED"}
	return {"is_terminal": false, "winner": ""}

func clone_matrix(matrix: Array) -> Array:
	var cloned_matrix = []
	for x in range(grid_width):
		cloned_matrix.append(matrix[x].duplicate())
	return cloned_matrix

func clone_state(state: Dictionary) -> Dictionary:
	return {
		"matrix": clone_matrix(state["matrix"]),
		"red_pos": state["red_pos"],
		"blue_pos": state["blue_pos"],
		"red_trail_count": state["red_trail_count"],
		"blue_trail_count": state["blue_trail_count"],
		"red_bonus": state.get("red_bonus", 0.0),
		"blue_bonus": state.get("blue_bonus", 0.0)
	}
