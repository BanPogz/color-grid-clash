class_name Gameplay extends Node2D

@onready var grid_layer: TileMapLayer = $GridLayer
@onready var player_red: BasePlayer = $Player1
@onready var ai_player: BasePlayer = $AIPlayer

var tick_timer: Timer
var round_clock_timer: Timer
var background_layer: TileMapLayer
enum CellType {EMPTY, WALL, RED_TRAIL, BLUE_TRAIL, ENERGY_CORE, RARE_ENERGY_CORE}

# Grid parameters
var tile_size: int = 30
var grid_width: int = 20
var grid_height: int = 20
var grid_matrix: Array = []

# Match rounds & accumulated scoring
var max_rounds: int = 5
var current_round: int = 1
var p1_match_score: int = 0
var p2_match_score: int = 0
var match_total_cores: int = 0
var match_total_cells: int = 0
var current_round_active: bool = true
var round_history: Array = [] # Stores: "RED", "BLUE", or "DRAW"

# Round specific metrics
var p1_basic_cores: int = 0
var p2_basic_cores: int = 0
var p1_rare_cores: int = 0
var p2_rare_cores: int = 0
var p1_captured_cells: int = 0
var p2_captured_cells: int = 0
var round_timer_elapsed: int = 0
var tick_count: int = 0

# Energy core nodes reference
var active_cores: Dictionary = {} # Maps Vector2i -> Node2D

# HUD reference
var hud: CanvasLayer = null

# Spawn tiles
var red_spawn_pos := Vector2i(2, 10)
var blue_spawn_pos := Vector2i(17, 10)

func initialize_matrix():
	grid_matrix.clear()
	for x in range(grid_width):
		var row = []
		for y in range(grid_height):
			row.append(CellType.EMPTY)
		grid_matrix.append(row)

func get_safety_zones() -> Array[Vector2i]:
	var zones: Array[Vector2i] = []
	
	# Add red player spawn safety bubble (3x3 grid around spawn)
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			zones.append(red_spawn_pos + Vector2i(dx, dy))
			
	# Add blue player spawn safety bubble (3x3 grid around spawn)
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			zones.append(blue_spawn_pos + Vector2i(dx, dy))
			
	# Add red player runway (4 tiles ahead, plus their adjacent tiles for steering)
	var red_dir = player_red.current_direction
	var red_side_dir = Vector2i(-red_dir.y, red_dir.x) # perpendicular vector
	for i in range(1, 5):
		var runway_center = red_spawn_pos + red_dir * i
		zones.append(runway_center)
		zones.append(runway_center + red_side_dir)
		zones.append(runway_center - red_side_dir)
		
	# Add blue player runway (4 tiles ahead, plus their adjacent tiles for steering)
	var blue_dir = ai_player.current_direction
	var blue_side_dir = Vector2i(-blue_dir.y, blue_dir.x) # perpendicular vector
	for i in range(1, 5):
		var runway_center = blue_spawn_pos + blue_dir * i
		zones.append(runway_center)
		zones.append(runway_center + blue_side_dir)
		zones.append(runway_center - blue_side_dir)
		
	return zones

func generate_random_walls(density: float) -> void:
	# 1. Calculate exactly how many walls are needed
	var total_cells: int = grid_width * grid_height
	var target_wall_count: int = int(total_cells * density)
	
	var walls_placed: int = 0
	var safety_zones = get_safety_zones()
	
	# 2. Keep looping until we successfully place the exact target number
	while walls_placed < target_wall_count:
		var rand_x: int = randi_range(0, grid_width - 1)
		var rand_y: int = randi_range(0, grid_height - 1)
		var candidate_pos := Vector2i(rand_x, rand_y)
		
		# 3. SAFETY CHECKS: Skip this tile if it violates starting conditions
		if grid_matrix[rand_x][rand_y] == CellType.WALL:
			continue
			
		if candidate_pos in safety_zones:
			continue
			
		# 4. COMMIT THE WALL
		grid_matrix[rand_x][rand_y] = CellType.WALL
		grid_layer.set_cell(candidate_pos, 4, Vector2i(0, 0))
		# Mirror to wall glow layer for violet-purple neon effect
		var wgl = get_meta("wall_glow_layer", null)
		if wgl != null:
			wgl.set_cell(candidate_pos, 4, Vector2i(0, 0))
		walls_placed += 1

# Helper to convert grid coordinates to screen pixel positions centered inside the tiles
func tile_to_pixel(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos * tile_size) + Vector2(tile_size / 2.0, tile_size / 2.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_matrix()
	setup_cybernetic_grid_layout()
	
	# Search parent/sibling hierarchy for HUD CanvasLayer node
	hud = get_parent().get_node_or_null("HUD")
	
	# 1. Randomize spawn positions within safe zones (Red: left quadrant, Blue: right quadrant)
	red_spawn_pos = Vector2i(randi_range(2, 7), randi_range(2, 17))
	blue_spawn_pos = Vector2i(randi_range(12, 17), randi_range(2, 17))
	
	# 2. Randomize initial directions (preventing facing immediate outer boundary wall)
	player_red.current_direction = [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT].pick_random()
	ai_player.current_direction = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT].pick_random()
	
	# Correctly position players logically and visually to their spawn tiles
	player_red.grid_position = red_spawn_pos
	player_red.position = tile_to_pixel(red_spawn_pos)
	
	ai_player.grid_position = blue_spawn_pos
	ai_player.position = tile_to_pixel(blue_spawn_pos)
	
	# Paint the spawn trail tiles visually
	grid_layer.set_cell(red_spawn_pos, 2, Vector2i(0, 0))
	grid_layer.set_cell(blue_spawn_pos, 3, Vector2i(0, 0))
	
	# Rotate arrow heads to match initial direction
	update_head_rotation(player_red, player_red.current_direction)
	update_head_rotation(ai_player, ai_player.current_direction)
	
	generate_random_walls(ConfigManager.get_wall_density()) # configured static walls
	
	# Spawn energy cores
	spawn_initial_cores()
	
	# Search parent/sibling hierarchy for HUD CanvasLayer node and connect signals
	hud = get_parent().get_node_or_null("HUD")
	if hud != null:
		hud.play_again_requested.connect(restart_match)
		hud.main_menu_requested.connect(go_to_main_menu)
		hud.resume_requested.connect(toggle_pause)
		hud.restart_requested.connect(func():
			toggle_pause()
			restart_match()
		)
		
	max_rounds = ConfigManager.max_rounds
	
	if ConfigManager.timer_mode == ConfigManager.TimerMode.INFINITE:
		round_timer_elapsed = 0
	else:
		round_timer_elapsed = ConfigManager.round_time_limit
		
	# Update HUD live at the start (deferred so HUD's _ready() finishes building labels first)
	call_deferred("update_hud")
	
	# Configure the Timer programmatically
	tick_timer = Timer.new()
	tick_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS # Decouple from monitor refresh rate & VSync
	tick_timer.wait_time = ConfigManager.tick_speed # Configured tick speed
	add_child(tick_timer)
	tick_timer.timeout.connect(_on_tick_timer_timeout)
	
	round_clock_timer = Timer.new()
	round_clock_timer.wait_time = 1.0
	add_child(round_clock_timer)
	round_clock_timer.timeout.connect(_on_round_clock_timer_timeout)
	
	if hud != null:
		hud.start_round_countdown(current_round, func(): 
			tick_timer.start()
			round_clock_timer.start()
		)
	else:
		tick_timer.start()
		round_clock_timer.start()
		
	# Play retro background music
	var mp = get_node_or_null("/root/MusicPlayer")
	if mp != null:
		mp.play_music()


func _on_round_clock_timer_timeout() -> void:
	if current_round_active:
		if ConfigManager.timer_mode == ConfigManager.TimerMode.INFINITE:
			round_timer_elapsed += 1
			if hud != null:
				hud.update_timer(round_timer_elapsed)
		else:
			# LIMITED Countdown Timer Mode
			if round_timer_elapsed > 0:
				round_timer_elapsed -= 1
				if hud != null:
					hud.update_timer(round_timer_elapsed)
				if round_timer_elapsed == 0:
					# TIME EXPIRED! End the round in a DRAW!
					handle_round_over("DRAW", "TIME EXPIRED! IT'S A DRAW!")

func _on_tick_timer_timeout() -> void:
	# Ticks & timer tracking
	tick_count += 1
			
	# 1. Get intended movements
	var red_dir = player_red.current_direction
	
	# Pass game state data structure directly to the AI routines
	var current_state_data = {
		"matrix": grid_matrix.duplicate(true),
		"red_pos": player_red.grid_position,
		"blue_pos": ai_player.grid_position,
		"red_trail_count": player_red.body_segments.size() + 1,
		"blue_trail_count": ai_player.body_segments.size() + 1
	}
	
	var think_time_ms_red = 0.0
	if ConfigManager.red_is_ai and player_red.has_method("think_and_decide"):
		var start_think_time = Time.get_ticks_msec()
		red_dir = player_red.think_and_decide(current_state_data)
		think_time_ms_red = float(Time.get_ticks_msec() - start_think_time)
	else:
		red_dir = player_red.get_and_consume_direction()
	
	var blue_dir = ai_player.current_direction
	var think_time_ms_blue = 0.0
	if ConfigManager.blue_is_ai and ai_player.has_method("think_and_decide"):
		var start_think_time = Time.get_ticks_msec()
		blue_dir = ai_player.think_and_decide(current_state_data)
		think_time_ms_blue = float(Time.get_ticks_msec() - start_think_time)
	else:
		blue_dir = ai_player.get_and_consume_direction()
	
	# Update Minimax telemetry stats on HUD
	if hud != null:
		if ConfigManager.red_is_ai and player_red.get("ai_module") != null:
			hud.update_red_ai_telemetry(player_red.ai_module.last_depth, think_time_ms_red, player_red.ai_module.last_nodes_evaluated)
		if ConfigManager.blue_is_ai and ai_player.get("ai_module") != null:
			hud.update_blue_ai_telemetry(ai_player.ai_module.last_depth, think_time_ms_blue, ai_player.ai_module.last_nodes_evaluated)
	
	# 2. Compute candidate positions
	var next_red = player_red.grid_position + red_dir
	var next_blue = ai_player.grid_position + blue_dir
	
	# Handle energy core consumption before collision check
	# Check Red player eating core
	if next_red in active_cores:
		var is_rare = grid_matrix[next_red.x][next_red.y] == CellType.RARE_ENERGY_CORE
		eat_energy_core(next_red, "RED", is_rare)
		
	# Check Blue player eating core
	if next_blue in active_cores:
		var is_rare = grid_matrix[next_blue.x][next_blue.y] == CellType.RARE_ENERGY_CORE
		eat_energy_core(next_blue, "BLUE", is_rare)
		
	# 3. Check for terminal/crash states simultaneously
	var red_crashed = check_collision(next_red)
	var blue_crashed = check_collision(next_blue)
	
	# Head-to-head collision crash
	if next_red == next_blue:
		red_crashed = true
		blue_crashed = true
		
	if red_crashed or blue_crashed:
		var round_outcome = ""
		var winner_text = ""
		if red_crashed and blue_crashed:
			round_outcome = "DRAW"
			winner_text = "Round %d DRAW - Both players crashed!" % current_round
		elif red_crashed:
			round_outcome = "BLUE"
			var blue_name = "AI 2" if ConfigManager.blue_is_ai else "Player 2"
			winner_text = "Round %d %s wins the round!" % [current_round, blue_name]
		else:
			round_outcome = "RED"
			var red_name = "AI 1" if ConfigManager.red_is_ai else "Player 1"
			winner_text = "Round %d %s wins the round!" % [current_round, red_name]
			
		handle_round_over(round_outcome, winner_text)
		return
	
	# 4. Commit moves to logical data grid matrix and record histories
	update_logical_matrix(player_red, next_red, "RED")
	update_logical_matrix(ai_player, next_blue, "BLUE")
	
	# 5. Move actual game nodes visually with smooth tween interpolation
	player_red.grid_position = next_red
	update_head_rotation(player_red, red_dir)  # Snap rotation immediately
	smooth_move_player(player_red, next_red)
	
	ai_player.grid_position = next_blue
	update_head_rotation(ai_player, blue_dir)  # Snap rotation immediately
	smooth_move_player(ai_player, next_blue)
	
	# Run enclosure flood algorithm
	if ConfigManager.flood_fill_enabled:
		check_and_apply_enclosure_flood()
	
	# Update HUD scores & percentages continually
	update_hud()

func smooth_move_player(player: BasePlayer, new_grid_pos: Vector2i) -> void:
	# Tween the visual position smoothly to the new tile — purely cosmetic,
	# game logic (grid_position) is already updated before this is called.
	var target_px = tile_to_pixel(new_grid_pos)
	var tween_dur = ConfigManager.tick_speed * 0.88
	
	var tw = player.create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_QUART)
	tw.tween_property(player, "position", target_px, tween_dur)


func check_collision(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.x >= grid_width or pos.y < 0 or pos.y >= grid_height:
		return true
	var type = grid_matrix[pos.x][pos.y]
	# Stepping on empty cells or energy cores is safe!
	if type == CellType.WALL or type == CellType.RED_TRAIL or type == CellType.BLUE_TRAIL:
		return true
	return false

func update_logical_matrix(player: BasePlayer, new_pos: Vector2i, type: String) -> void:
	# Turn old position into trailing obstacle data
	var old_pos = player.grid_position
	grid_matrix[old_pos.x][old_pos.y] = CellType.RED_TRAIL if type == "RED" else CellType.BLUE_TRAIL
	player.body_segments.append(old_pos)
	
	# Render the trail tile visually at the old position
	var source_id = 2 if type == "RED" else 3
	grid_layer.set_cell(old_pos, source_id, Vector2i(0, 0))

func spawn_initial_cores() -> void:
	var basic_count = ConfigManager.get_basic_cores_count()
	var rare_count = ConfigManager.get_rare_cores_count()
	for i in range(basic_count):
		spawn_energy_core(false)
	for i in range(rare_count):
		spawn_energy_core(true)

func spawn_energy_core(is_rare: bool) -> void:
	var attempts = 0
	while attempts < 100:
		var rx = randi_range(1, grid_width - 2)
		var ry = randi_range(1, grid_height - 2)
		var pos = Vector2i(rx, ry)
		
		# Validate that cell is empty, not safety zones, and not player heads
		if grid_matrix[rx][ry] == CellType.EMPTY and pos != player_red.grid_position and pos != ai_player.grid_position:
			var safety_zones = get_safety_zones()
			if pos in safety_zones:
				attempts += 1
				continue
				
			# Commit to grid matrix
			grid_matrix[rx][ry] = CellType.ENERGY_CORE if not is_rare else CellType.RARE_ENERGY_CORE
			
			# Spawn animated visual core node
			var core_node = Node2D.new()
			core_node.position = tile_to_pixel(pos)
			
			var core_visual = Panel.new()
			core_visual.custom_minimum_size = Vector2(12, 12)
			core_visual.size = Vector2(12, 12)
			core_visual.position = Vector2(-6, -6)
			core_visual.pivot_offset = Vector2(6, 6)
			
			var style = StyleBoxFlat.new()
			var glow_color = Color("#ffd700") if is_rare else Color("#39ff14")
			style.bg_color = glow_color
			style.set_corner_radius_all(6) # Circular pulsing core!
			style.shadow_color = Color(glow_color.r, glow_color.g, glow_color.b, 0.8)
			style.shadow_size = 8
			
			core_visual.add_theme_stylebox_override("panel", style)
			core_node.add_child(core_visual)
			add_child(core_node)
			
			# Pulse animation
			var tween = core_node.create_tween().set_loops()
			tween.tween_property(core_visual, "scale", Vector2(1.3, 1.3), 0.4).set_trans(Tween.TRANS_SINE)
			tween.tween_property(core_visual, "scale", Vector2(0.7, 0.7), 0.4).set_trans(Tween.TRANS_SINE)
			
			active_cores[pos] = core_node
			break
			
		attempts += 1

func eat_energy_core(pos: Vector2i, player_type: String, is_rare: bool) -> void:
	# 1. Clear visual representation
	if active_cores.has(pos):
		var node = active_cores[pos]
		if is_instance_valid(node):
			node.queue_free()
		active_cores.erase(pos)
		
	# 2. Reset grid matrix cell
	grid_matrix[pos.x][pos.y] = CellType.EMPTY
	
	# 3. Credit points based on core type
	if player_type == "RED":
		if is_rare:
			p1_rare_cores += 1
		else:
			p1_basic_cores += 1
	else:
		if is_rare:
			p2_rare_cores += 1
		else:
			p2_basic_cores += 1
			
	# 4. Immediately spawn a replacement core
	spawn_energy_core(randf() < 0.25) # 25% chance of spawning as rare
	
	# 5. Update HUD stats
	update_hud()

func recount_captured_cells() -> void:
	var red_count = 0
	var blue_count = 0
	for x in range(grid_width):
		for y in range(grid_height):
			var val = grid_matrix[x][y]
			if val == CellType.RED_TRAIL:
				red_count += 1
			elif val == CellType.BLUE_TRAIL:
				blue_count += 1
	p1_captured_cells = red_count
	p2_captured_cells = blue_count

func update_hud() -> void:
	recount_captured_cells()
	
	# Round points: cells (1 pt each) + cores
	var left_round_pts = p1_captured_cells + p1_basic_cores * 5 + p1_rare_cores * 10
	var right_round_pts = p2_captured_cells + p2_basic_cores * 5 + p2_rare_cores * 10
	
	# Match points: past rounds total + current round
	var left_match_total = p1_match_score
	var right_match_total = p2_match_score
	if current_round_active:
		left_match_total += left_round_pts
		right_match_total += right_round_pts
	
	if hud != null:
		hud.update_scores(left_match_total, left_round_pts, right_match_total, right_round_pts)
		
		var total_cells = grid_width * grid_height
		var left_pct = (float(p1_captured_cells) / total_cells) * 100.0
		var right_pct = (float(p2_captured_cells) / total_cells) * 100.0
		hud.update_cells(p1_captured_cells, left_pct, p2_captured_cells, right_pct)
		hud.update_cores(p1_basic_cores, p1_rare_cores, p2_basic_cores, p2_rare_cores)
		hud.update_round(current_round, max_rounds, round_history)

func handle_round_over(outcome: String, round_message: String) -> void:
	tick_timer.stop()
	round_clock_timer.stop()
	
	var p1_won = outcome == "RED"
	var p2_won = outcome == "BLUE"
	var is_draw = outcome == "DRAW"
	
	# Play win/loss/draw sound effects
	var mp = get_node_or_null("/root/MusicPlayer")
	if mp != null:
		if is_draw:
			mp.play_sfx("round_draw")
		else:
			# Determine if the human player won or lost
			var human_won = false
			var human_lost = false
			
			if not ConfigManager.red_is_ai and ConfigManager.blue_is_ai:
				# Solo vs AI (Red is human)
				if outcome == "RED":
					human_won = true
				else:
					human_lost = true
			elif ConfigManager.red_is_ai and not ConfigManager.blue_is_ai:
				# Red is AI, Blue is human
				if outcome == "BLUE":
					human_won = true
				else:
					human_lost = true
			elif not ConfigManager.red_is_ai and not ConfigManager.blue_is_ai:
				# PvP (Both are human - someone definitely wins)
				human_won = true
			else:
				# AI vs AI Watch Mode
				human_won = true # default to win SFX for watch satisfaction!
				
			if human_won:
				mp.play_sfx("round_win")
			elif human_lost:
				mp.play_sfx("round_loss")
				
	round_history.append(outcome)

	
	# Finalize round scores including round win bonus
	var r1_base = p1_captured_cells + p1_basic_cores * 5 + p1_rare_cores * 10
	var r2_base = p2_captured_cells + p2_basic_cores * 5 + p2_rare_cores * 10
	
	var r1_bonus = 50 if p1_won else (25 if is_draw else 0)
	var r2_bonus = 50 if p2_won else (25 if is_draw else 0)
	
	# Accumulate to permanent match scores
	p1_match_score += (r1_base + r1_bonus)
	p2_match_score += (r2_base + r2_bonus)
	
	# Accumulate match statistics
	match_total_cores += p1_basic_cores + p1_rare_cores + p2_basic_cores + p2_rare_cores
	match_total_cells += p1_captured_cells + p2_captured_cells
	
	current_round_active = false
	update_hud()
	
	# Play post-round results display & then transition
	if hud != null:
		hud.show_round_results(
			current_round,
			outcome,
			round_message,
			r1_base + r1_bonus,
			r2_base + r2_bonus,
			p1_captured_cells,
			p2_captured_cells,
			p1_basic_cores,
			p1_rare_cores,
			p2_basic_cores,
			p2_rare_cores,
			func():
				if current_round < max_rounds:
					start_next_round()
				else:
					var grand_winner = ""
					var grand_message = ""
					var p1_name = "AI 1" if ConfigManager.red_is_ai else "PLAYER 1"
					var p2_name = "AI 2" if ConfigManager.blue_is_ai else "PLAYER 2"
					if p1_match_score > p2_match_score:
						grand_winner = "RED"
						grand_message = "%s WINS THE MATCH!" % p1_name
					elif p2_match_score > p1_match_score:
						grand_winner = "BLUE"
						grand_message = "%s WINS THE MATCH!" % p2_name
					else:
						grand_winner = "DRAW"
						grand_message = "IT'S A GRAND DRAW!"
						
					# Save persistent database statistics
					StatsManager.record_game_result(
						p1_match_score,
						p2_match_score,
						grand_winner,
						match_total_cores,
						match_total_cells
					)
					
					# Stop normal background music when playing match ending fanfares!
					var mp_local = get_node_or_null("/root/MusicPlayer")
					if mp_local != null:
						mp_local.stop_music()
						if grand_winner == "DRAW":
							mp_local.play_sfx("match_draw")
						else:
							var human_grand_won = false
							var human_grand_lost = false
							
							if not ConfigManager.red_is_ai and ConfigManager.blue_is_ai:
								if grand_winner == "RED": human_grand_won = true
								else: human_grand_lost = true
							elif ConfigManager.red_is_ai and not ConfigManager.blue_is_ai:
								if grand_winner == "BLUE": human_grand_won = true
								else: human_grand_lost = true
							elif not ConfigManager.red_is_ai and not ConfigManager.blue_is_ai:
								human_grand_won = true
							else:
								human_grand_won = true # watch mode default
								
							if human_grand_won:
								mp_local.play_sfx("match_win")
							elif human_grand_lost:
								mp_local.play_sfx("match_loss")
								
					hud.show_match_results(grand_winner, grand_message, p1_match_score, p2_match_score)

		)
	else:
		# Fallback if HUD is null
		await get_tree().create_timer(2.0).timeout
		if current_round < max_rounds:
			start_next_round()

func start_next_round() -> void:
	if tick_timer != null:
		tick_timer.stop()
	if round_clock_timer != null:
		round_clock_timer.stop()
		
	current_round += 1
	
	# 1. Clear active energy cores
	for pos in active_cores.keys():
		var node = active_cores[pos]
		if is_instance_valid(node):
			node.queue_free()
	active_cores.clear()
	
	# Reset logical matrix
	initialize_matrix()
	
	# Reset visual layers: paint background grid and clear active trails/walls on grid_layer
	var wgl_reset = get_meta("wall_glow_layer", null)
	for x in range(grid_width):
		for y in range(grid_height):
			if background_layer != null:
				background_layer.set_cell(Vector2i(x, y), 1, Vector2i(0, 0))
			grid_layer.set_cell(Vector2i(x, y), -1)
			if wgl_reset != null:
				wgl_reset.set_cell(Vector2i(x, y), -1)
			
	# 2. Reset round counters
	p1_basic_cores = 0
	p2_basic_cores = 0
	p1_rare_cores = 0
	p2_rare_cores = 0
	p1_captured_cells = 0
	p2_captured_cells = 0
	
	if ConfigManager.timer_mode == ConfigManager.TimerMode.INFINITE:
		round_timer_elapsed = 0
	else:
		round_timer_elapsed = ConfigManager.round_time_limit
		
	tick_count = 0
	
	player_red.body_segments.clear()
	ai_player.body_segments.clear()
	
	if player_red.has_method("clear_queue"):
		player_red.clear_queue()
	if ai_player.has_method("clear_queue"):
		ai_player.clear_queue()
	
	# 3. Re-randomize spawns
	red_spawn_pos = Vector2i(randi_range(2, 7), randi_range(2, 17))
	blue_spawn_pos = Vector2i(randi_range(12, 17), randi_range(2, 17))
	
	player_red.current_direction = [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT].pick_random()
	ai_player.current_direction = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT].pick_random()
	
	player_red.grid_position = red_spawn_pos
	player_red.position = tile_to_pixel(red_spawn_pos)
	ai_player.grid_position = blue_spawn_pos
	ai_player.position = tile_to_pixel(blue_spawn_pos)
	
	# Re-paint spawn trail tiles
	grid_layer.set_cell(red_spawn_pos, 2, Vector2i(0, 0))
	grid_layer.set_cell(blue_spawn_pos, 3, Vector2i(0, 0))
	
	# Update arrow head rotations for new round spawn
	update_head_rotation(player_red, player_red.current_direction)
	update_head_rotation(ai_player, ai_player.current_direction)
	
	# Regenerate static walls
	generate_random_walls(ConfigManager.get_wall_density())
	
	# Spawn energy cores
	spawn_initial_cores()
	
	# Update HUD
	current_round_active = true
	update_hud()
	
	if hud != null:
		hud.update_timer(round_timer_elapsed)
	
	# Start round ticking with preparations countdown
	if hud != null:
		hud.start_round_countdown(current_round, func(): 
			tick_timer.start()
			round_clock_timer.start()
		)
	else:
		tick_timer.start()
		round_clock_timer.start()

func check_and_apply_enclosure_flood() -> void:
	var red_flooded_cells: Array[Vector2i] = []
	var blue_flooded_cells: Array[Vector2i] = []

	# 1. Scan Red's enclosures
	var red_reachable = get_reachable_cells(player_red.grid_position, CellType.RED_TRAIL)
	var red_candidates = get_unreachable_free_cells(red_reachable)
	for cell in red_candidates:
		if cell != player_red.grid_position and cell != ai_player.grid_position:
			if touches_trail(cell, CellType.RED_TRAIL):
				red_flooded_cells.append(cell)

	# 2. Scan Blue's enclosures
	var blue_reachable = get_reachable_cells(ai_player.grid_position, CellType.BLUE_TRAIL)
	var blue_candidates = get_unreachable_free_cells(blue_reachable)
	for cell in blue_candidates:
		if cell != player_red.grid_position and cell != ai_player.grid_position:
			if touches_trail(cell, CellType.BLUE_TRAIL):
				blue_flooded_cells.append(cell)

	# Apply floods
	var flooded_any = false
	if not red_flooded_cells.is_empty():
		apply_flood(red_flooded_cells, "RED")
		flooded_any = true
	if not blue_flooded_cells.is_empty():
		apply_flood(blue_flooded_cells, "BLUE")
		flooded_any = true

	if flooded_any:
		update_hud()

func get_reachable_cells(start_pos: Vector2i, blocking_trail_type: int) -> Dictionary:
	var reachable = {}
	var queue = [start_pos]
	reachable[start_pos] = true
	
	while queue.size() > 0:
		var curr = queue.pop_front()
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var neighbor = curr + dir
			if neighbor.x < 0 or neighbor.x >= grid_width or neighbor.y < 0 or neighbor.y >= grid_height:
				continue
			if reachable.has(neighbor):
				continue
				
			var type = grid_matrix[neighbor.x][neighbor.y]
			# The search can traverse anything EXCEPT the player's own trail and permanent walls.
			if type != blocking_trail_type and type != CellType.WALL:
				reachable[neighbor] = true
				queue.append(neighbor)
				
	return reachable

func get_unreachable_free_cells(reachable: Dictionary) -> Array[Vector2i]:
	var unreachable: Array[Vector2i] = []
	for x in range(grid_width):
		for y in range(grid_height):
			var pos = Vector2i(x, y)
			var type = grid_matrix[x][y]
			var is_free = type == CellType.EMPTY or type == CellType.ENERGY_CORE or type == CellType.RARE_ENERGY_CORE
			if is_free and not reachable.has(pos):
				unreachable.append(pos)
	return unreachable

func touches_trail(pos: Vector2i, trail_type: int) -> bool:
	for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var neighbor = pos + dir
		if neighbor.x >= 0 and neighbor.x < grid_width and neighbor.y >= 0 and neighbor.y < grid_height:
			if grid_matrix[neighbor.x][neighbor.y] == trail_type:
				return true
	return false

func apply_flood(cells: Array[Vector2i], player_type: String) -> void:
	var trail_type = CellType.RED_TRAIL if player_type == "RED" else CellType.BLUE_TRAIL
	var source_id = 2 if player_type == "RED" else 3
	var player = player_red if player_type == "RED" else ai_player
	
	var cores_eaten = 0
	var rare_cores_eaten = 0
	
	# First pass: remove cores and update matrix + tilemap
	for cell in cells:
		var type = grid_matrix[cell.x][cell.y]
		if type == CellType.ENERGY_CORE or type == CellType.RARE_ENERGY_CORE:
			var is_rare = type == CellType.RARE_ENERGY_CORE
			if is_rare:
				rare_cores_eaten += 1
			else:
				cores_eaten += 1
				
			if active_cores.has(cell):
				var node = active_cores[cell]
				if is_instance_valid(node):
					node.queue_free()
				active_cores.erase(cell)
				
		grid_matrix[cell.x][cell.y] = trail_type
		grid_layer.set_cell(cell, source_id, Vector2i(0, 0))
		player.body_segments.append(cell)
		
	# Second pass: credit core points & spawn replacements
	if player_type == "RED":
		p1_basic_cores += cores_eaten
		p1_rare_cores += rare_cores_eaten
	else:
		p2_basic_cores += cores_eaten
		p2_rare_cores += rare_cores_eaten
		
	for i in range(cores_eaten + rare_cores_eaten):
		spawn_energy_core(randf() < 0.25)

func restart_match() -> void:
	current_round = 0
	p1_match_score = 0
	p2_match_score = 0
	match_total_cores = 0
	match_total_cells = 0
	round_history.clear()
	current_round_active = true
	start_next_round()

func go_to_main_menu() -> void:
	# Transition back to menu background music
	var mp = get_node_or_null("/root/MusicPlayer")
	if mp != null:
		mp.play_menu_music()
		
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

var is_paused: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		toggle_pause()

func toggle_pause() -> void:
	if hud != null:
		# Ignore pause if round breakdown, countdown, or post-game overlays are open
		var round_visible = hud.post_round_overlay != null and hud.post_round_overlay.visible
		var game_visible = hud.post_game_overlay != null and hud.post_game_overlay.visible
		var count_visible = hud.countdown_overlay != null and hud.countdown_overlay.visible
		if round_visible or game_visible or count_visible:
			return
			
	is_paused = not is_paused
	get_tree().paused = is_paused
	
	if hud != null:
		if is_paused:
			hud.show_pause_menu()
		else:
			hud.hide_pause_menu()
			
	# Update music playback state on pause/unpause
	var mp = get_node_or_null("/root/MusicPlayer")
	if mp != null:
		if is_paused:
			mp.pause_music()
		else:
			mp.resume_music()


func setup_cybernetic_grid_layout() -> void:
	# 1. Deep void background — true black so neon trails glow hard
	var bg_rect = $ColorRect
	if bg_rect != null:
		bg_rect.color = Color("#030508") # True void — deepest possible base
		
	# 2. Background grid line layer — faint cyan-teal so empty cells read as a cool arena floor
	background_layer = TileMapLayer.new()
	background_layer.name = "BackgroundGridLayer"
	background_layer.tile_set = grid_layer.tile_set
	background_layer.self_modulate = Color(0.04, 0.18, 0.26, 0.65) # Cold cyan-teal grid lines
	add_child(background_layer)
	move_child(background_layer, grid_layer.get_index())
	for x in range(grid_width):
		for y in range(grid_height):
			background_layer.set_cell(Vector2i(x, y), 1, Vector2i(0, 0))
	
	# Keep grid_layer unmodulated so trails and walls are 100% vibrant
	grid_layer.self_modulate = Color.WHITE
	
	# 3. Dedicated wall layer — rendered with a sinister violet-purple glow
	# Walls are painted here from generate_random_walls, so we override modulate.
	# We tint the whole grid_layer for trails, but we paint a separate visual wall layer.
	# Actually: walls are source_id=4 on grid_layer, trails are 2/3 — so we use a separate overlay layer.
	var wall_layer = TileMapLayer.new()
	wall_layer.name = "WallGlowLayer"
	wall_layer.tile_set = grid_layer.tile_set
	wall_layer.self_modulate = Color(0.78, 0.35, 1.0, 0.85) # Violet-purple neon danger glow
	wall_layer.z_index = -1  # Behind trails but above background
	add_child(wall_layer)
	move_child(wall_layer, grid_layer.get_index())
	# Store reference for generate_random_walls to mirror wall tiles onto
	set_meta("wall_glow_layer", wall_layer)
	
	# 4. Premium split-color neon frame: pink on left+top, cyan on right+bottom
	# Pink frame (top-left layers)
	var frame_pink = Panel.new()
	frame_pink.name = "FramePink"
	frame_pink.size = Vector2(600, 600)
	frame_pink.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fs_pink = StyleBoxFlat.new()
	fs_pink.draw_center = false
	fs_pink.border_color = Color("#ff2a7a")
	fs_pink.border_width_left = 2
	fs_pink.border_width_top = 2
	fs_pink.border_width_right = 0
	fs_pink.border_width_bottom = 0
	fs_pink.shadow_color = Color(1.0, 0.16, 0.48, 0.4)
	fs_pink.shadow_size = 12
	fs_pink.shadow_offset = Vector2(-2, -2)
	frame_pink.add_theme_stylebox_override("panel", fs_pink)
	add_child(frame_pink)
	# Cyan frame (bottom-right layers)
	var frame_cyan = Panel.new()
	frame_cyan.name = "FrameCyan"
	frame_cyan.size = Vector2(600, 600)
	frame_cyan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fs_cyan = StyleBoxFlat.new()
	fs_cyan.draw_center = false
	fs_cyan.border_color = Color("#00f0ff")
	fs_cyan.border_width_left = 0
	fs_cyan.border_width_top = 0
	fs_cyan.border_width_right = 2
	fs_cyan.border_width_bottom = 2
	fs_cyan.shadow_color = Color(0.0, 0.94, 1.0, 0.4)
	fs_cyan.shadow_size = 12
	fs_cyan.shadow_offset = Vector2(2, 2)
	frame_cyan.add_theme_stylebox_override("panel", fs_cyan)
	add_child(frame_cyan)
	
	# 5. Corner bracket decorations (sci-fi targeting reticle look)
	var corners = [
		{"pos": Vector2(0, 0), "rot": 0.0},
		{"pos": Vector2(600, 0), "rot": PI / 2.0},
		{"pos": Vector2(600, 600), "rot": PI},
		{"pos": Vector2(0, 600), "rot": -PI / 2.0}
	]
	for c in corners:
		var bracket = CornerBracket.new()
		bracket.position = c["pos"]
		bracket.rotation = c["rot"]
		add_child(bracket)
	
	# 6. Setup player heads
	setup_neon_player_heads()

# Sci-fi corner bracket decoration drawn at each corner of the arena
class CornerBracket extends Node2D:
	func _draw() -> void:
		var c1 = Color("#ff2a7a")  # Pink side
		var c2 = Color("#00f0ff")  # Cyan side
		var len_px = 18.0
		var thick = 2.5
		# Horizontal arm
		draw_line(Vector2(0, 0), Vector2(len_px, 0), c1, thick)
		# Vertical arm
		draw_line(Vector2(0, 0), Vector2(0, len_px), c2, thick)
		# Small corner dot
		draw_circle(Vector2.ZERO, 2.5, Color.WHITE * 0.9)

# Custom 2D Node to draw a glowing neon circular head with directional eyes
class PlayerHeadCircle extends Node2D:
	var head_color: Color
	var glow_color: Color
	
	func _init(p_head_color: Color, p_glow_color: Color):
		head_color = p_head_color
		glow_color = p_glow_color
		
	func _draw() -> void:
		# 1. Draw glowing outer shadow rings
		for i in range(3):
			var radius = 10.0 + (3 - i) * 3.0
			var alpha = 0.15 + i * 0.12
			draw_circle(Vector2.ZERO, radius, Color(glow_color.r, glow_color.g, glow_color.b, alpha))
			
		# 2. Draw the solid neon head circle
		draw_circle(Vector2.ZERO, 10.0, head_color)
		
		# 3. Draw a white inner core highlighting edge
		draw_circle(Vector2.ZERO, 8.0, Color.WHITE * 0.25)
		
		# 4. Draw eyes looking in the direction of movement (always facing right at 0 rotation)
		var eye_color = Color.WHITE
		var pupil_color = Color.BLACK
		
		var eye_r = 2.8
		var pupil_r = 1.3
		
		# Place eyes at top-right and bottom-right relative to facing direction
		var eye1_pos = Vector2(3.5, -3.2)
		var eye2_pos = Vector2(3.5, 3.2)
		
		# Eyeballs
		draw_circle(eye1_pos, eye_r, eye_color)
		draw_circle(eye2_pos, eye_r, eye_color)
		
		# Pupils shifted forward to look alive
		var pupil_shift = Vector2(0.8, 0.0)
		draw_circle(eye1_pos + pupil_shift, pupil_r, pupil_color)
		draw_circle(eye2_pos + pupil_shift, pupil_r, pupil_color)

func setup_neon_player_heads() -> void:
	# Customize Player 1 (Red)
	var red_sprite = player_red.get_node_or_null("Area2D/Sprite2D")
	if red_sprite != null:
		red_sprite.visible = false
		
		# Remove old head node if it exists
		var old = player_red.get_node_or_null("NeonHeadArrow")
		if old != null:
			old.queue_free()
			
		var neon_head = PlayerHeadCircle.new(Color("#ff2a7a"), Color(1.0, 0.16, 0.48))
		neon_head.name = "NeonHeadArrow"
		player_red.add_child(neon_head)
		# Breathing scale pulse — makes the head feel alive
		var pulse_red = neon_head.create_tween().set_loops()
		pulse_red.tween_property(neon_head, "scale", Vector2(1.08, 1.08), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		pulse_red.tween_property(neon_head, "scale", Vector2(0.93, 0.93), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Customize Player 2 (Blue AI)
	var blue_sprite = ai_player.get_node_or_null("Area2D/Sprite2D")
	if blue_sprite != null:
		blue_sprite.visible = false
		
		# Remove old head node if it exists
		var old = ai_player.get_node_or_null("NeonHeadArrow")
		if old != null:
			old.queue_free()
			
		var neon_head = PlayerHeadCircle.new(Color("#00f0ff"), Color(0.0, 0.94, 1.0))
		neon_head.name = "NeonHeadArrow"
		ai_player.add_child(neon_head)
		# Breathing scale pulse — offset phase from red head
		var pulse_blue = neon_head.create_tween().set_loops()
		pulse_blue.tween_property(neon_head, "scale", Vector2(0.93, 0.93), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		pulse_blue.tween_property(neon_head, "scale", Vector2(1.08, 1.08), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func update_head_rotation(player: BasePlayer, direction: Vector2i) -> void:
	var head = player.get_node_or_null("NeonHeadArrow")
	if head != null:
		# Convert Vector2i direction into a rotation angle in radians
		head.rotation = Vector2(direction).angle()
