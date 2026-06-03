# ai_demo_panel.gd
extends Control

# Preload gameplay coordinator scene to instantiate directly in the center column
var gameplay_scene = preload("res://scenes/gameplay/gameplay.tscn")
var gameplay: Gameplay = null

var tracer: AIDemoTracer = null
var trace_steps: Array = []
var trace_index: int = 0
var game_history: Array = []

var is_playing: bool = false
var step_timer: Timer = null
var demo_overlay: Node2D = null

# Pseudocode structured to exactly 29 lines
const PSEUDOCODE = [
	"func minimax(state, depth, alpha, beta, is_max):",
	"    nodes_evaluated += 1",
	"    if depth == 0 or check_terminal(state):",
	"        return evaluate(state)",
	"    var moves = order_moves(get_legal_moves(state, is_max), state, is_max)",
	"    if is_max: # AI Player's turn (Blue)",
	"        var max_eval = -INF",
	"        for move in moves:",
	"            var child = apply_move(state, move, true)",
	"            var val = minimax(child, depth-1, alpha, beta, false)",
	"            if val > max_eval:",
	"                max_eval = val",
	"                best_move = move",
	"            alpha = max(alpha, val)",
	"            if alpha >= beta:",
	"                break # Pruned!",
	"        return max_eval",
	"    else: # Human/Min Player's turn (Red)",
	"        var min_eval = INF",
	"        for move in moves:",
	"            var child = apply_move(state, move, false)",
	"            var val = minimax(child, depth-1, alpha, beta, true)",
	"            if val < min_eval:",
	"                min_eval = val",
	"                best_move = move",
	"            beta = min(beta, val)",
	"            if alpha >= beta:",
	"                break # Pruned!",
	"        return min_eval"
]

# UI references
var code_rows: Array = []
var code_labels: Array = []
var explanation_label: Label = null

var depth_lbl: Label = null
var nodes_lbl: Label = null
var alpha_lbl: Label = null
var beta_lbl: Label = null
var value_lbl: Label = null

var play_pause_btn: TextureButton = null
var prev_line_btn: TextureButton = null
var next_line_btn: TextureButton = null
var prev_move_btn: TextureButton = null
var next_move_btn: TextureButton = null

var real_time_timer: float = 0.0

func _ready() -> void:
	# Ensure the debugger is always processing so buttons work while gameplay is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Configure root size and deep charcoal background
	custom_minimum_size = Vector2(1280, 720)
	
	var bg = ColorRect.new()
	bg.name = "DemoBackground"
	bg.size = Vector2(1280, 720)
	bg.color = Color("#08090d")
	add_child(bg)
	
	# Instantiate standard gameplay coordinator in the center panel (X=300, Y=60) with 0.85 scale to fit perfectly in viewport
	gameplay = gameplay_scene.instantiate()
	gameplay.name = "Gameplay"
	gameplay.position = Vector2(300, 60)
	gameplay.scale = Vector2(0.85, 0.85)
	add_child(gameplay)
	
	# Intercept and stop the gameplay ticking timers in slow-mo & line stepping modes
	if ConfigManager.active_demo_mode != ConfigManager.DemoMode.REAL_TIME:
		if gameplay.tick_timer != null:
			gameplay.tick_timer.stop()
		if gameplay.round_clock_timer != null:
			gameplay.round_clock_timer.stop()
			
	# Programmatically build Left & Right sidebars, Stepper Controls and Pseudocode rows
	setup_left_sidebar()
	setup_right_sidebar()
	setup_gameplay_overlay()
	
	# Setup slow-motion automatic stepper timer
	step_timer = Timer.new()
	step_timer.name = "StepTimer"
	step_timer.wait_time = 0.35 # smooth default pacing
	step_timer.timeout.connect(_on_step_timer_timeout)
	add_child(step_timer)
	
	# Prime the tracing engine
	tracer = AIDemoTracer.new()
	
	# Begin tracking state
	if ConfigManager.active_demo_mode != ConfigManager.DemoMode.REAL_TIME:
		generate_new_move_trace()
		
		if ConfigManager.active_demo_mode == ConfigManager.DemoMode.SLOW_MOTION:
			# Auto start slow motion
			toggle_play_state(true)
	else:
		# Real-Time mode: gameplay ticks naturally, we just display stats dynamically
		if play_pause_btn != null:
			play_pause_btn.disabled = true
		if prev_line_btn != null:
			prev_line_btn.disabled = true
		if next_line_btn != null:
			next_line_btn.disabled = true
		if prev_move_btn != null:
			prev_move_btn.disabled = true
		if next_move_btn != null:
			next_move_btn.disabled = true
			
		explanation_label.text = "REAL-TIME WATCH MODE ACTIVE\nRunning AI vs AI match at full speed without highlighting pauses."
		explanation_label.add_theme_color_override("font_color", Color("#ffd700"))

func _process(delta: float) -> void:
	if ConfigManager.active_demo_mode == ConfigManager.DemoMode.REAL_TIME:
		real_time_timer += delta
		if real_time_timer > 0.1:
			real_time_timer = 0.0
			update_real_time_telemetry()

func update_real_time_telemetry() -> void:
	if gameplay == null or not is_instance_valid(gameplay): return
	
	# Query current statistics from active AI Module of P1 Red
	var red_ai = gameplay.player_red.get("ai_module")
	if red_ai != null and is_instance_valid(red_ai):
		depth_lbl.text = "Search Depth: %d" % red_ai.last_depth
		nodes_lbl.text = "Nodes Evaluated: %d" % red_ai.last_nodes_evaluated
	alpha_lbl.text = "Alpha Bound: DYNAMIC"
	beta_lbl.text = "Beta Bound: DYNAMIC"
	value_lbl.text = "Branch Score: DYNAMIC"

func setup_left_sidebar() -> void:
	var sidebar = PanelContainer.new()
	sidebar.name = "LeftSidebar"
	sidebar.position = Vector2(30, 60)
	sidebar.size = Vector2(240, 600)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#0c0e14")
	style.border_color = Color("#ff2a7a") # Glowing P1 Red secondary boundary
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.shadow_color = Color(1.0, 0.16, 0.48, 0.1)
	style.shadow_size = 12
	sidebar.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	sidebar.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "AI VISUAL DEBUGGER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("#ff2a7a"))
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "P1 RED AI SEARCH ENGINE"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color("#606575"))
	subtitle.add_theme_font_size_override("font_size", 10)
	vbox.add_child(subtitle)
	
	vbox.add_child(HSeparator.new())
	
	# Telemetry Data Grid
	var grid = GridContainer.new()
	grid.columns = 1
	grid.add_theme_constant_override("v_separation", 6)
	vbox.add_child(grid)
	
	depth_lbl = Label.new()
	depth_lbl.text = "Search Depth: 0"
	depth_lbl.add_theme_color_override("font_color", Color("#d0d5e5"))
	depth_lbl.add_theme_font_size_override("font_size", 12)
	grid.add_child(depth_lbl)
	
	nodes_lbl = Label.new()
	nodes_lbl.text = "Nodes Evaluated: 0"
	nodes_lbl.add_theme_color_override("font_color", Color("#d0d5e5"))
	nodes_lbl.add_theme_font_size_override("font_size", 12)
	grid.add_child(nodes_lbl)
	
	alpha_lbl = Label.new()
	alpha_lbl.text = "Alpha Bound: -INF"
	alpha_lbl.add_theme_color_override("font_color", Color("#39ff14")) # Neon green
	alpha_lbl.add_theme_font_size_override("font_size", 12)
	grid.add_child(alpha_lbl)
	
	beta_lbl = Label.new()
	beta_lbl.text = "Beta Bound: INF"
	beta_lbl.add_theme_color_override("font_color", Color("#00f0ff")) # Neon cyan
	beta_lbl.add_theme_font_size_override("font_size", 12)
	grid.add_child(beta_lbl)
	
	value_lbl = Label.new()
	value_lbl.text = "Branch Score: 0.0"
	value_lbl.add_theme_color_override("font_color", Color("#ffd700")) # Neon gold
	value_lbl.add_theme_font_size_override("font_size", 12)
	grid.add_child(value_lbl)
	
	vbox.add_child(HSeparator.new())
	
	# Stepper Button Deck using res://assets/ assets with circular glowing neon backlights
	var deck = HBoxContainer.new()
	deck.alignment = BoxContainer.ALIGNMENT_CENTER
	deck.add_theme_constant_override("separation", 8)
	vbox.add_child(deck)
	
	var r_prev_move = [null]
	var p_prev_move = create_stepper_btn("res://assets/goto_prevmove.png", _on_prev_move_pressed, "Prev Game Tick or Move", r_prev_move)
	prev_move_btn = r_prev_move[0]
	deck.add_child(p_prev_move)
	
	var r_prev_line = [null]
	var p_prev_line = create_stepper_btn("res://assets/goto_prevline.png", _on_prev_line_pressed, "Step Back One Code Line", r_prev_line)
	prev_line_btn = r_prev_line[0]
	deck.add_child(p_prev_line)
	
	var r_play = [null]
	var p_play = create_stepper_btn("res://assets/play.png", _on_play_pause_pressed, "Play or Pause Slow Motion", r_play)
	play_pause_btn = r_play[0]
	deck.add_child(p_play)
	
	var r_next_line = [null]
	var p_next_line = create_stepper_btn("res://assets/goto_nextline.png", _on_next_line_pressed, "Step Forward One Code Line", r_next_line)
	next_line_btn = r_next_line[0]
	deck.add_child(p_next_line)
	
	var r_next_move = [null]
	var p_next_move = create_stepper_btn("res://assets/goto_nextmove.png", _on_next_move_pressed, "Skip or Execute Final Move", r_next_move)
	next_move_btn = r_next_move[0]
	deck.add_child(p_next_move)
	
	vbox.add_child(HSeparator.new())
	
	# Explanation Walkthrough Box
	var exp_title = Label.new()
	exp_title.text = "EXECUTION LOG & MATH"
	exp_title.add_theme_color_override("font_color", Color("#a0a5b5"))
	exp_title.add_theme_font_size_override("font_size", 11)
	vbox.add_child(exp_title)
	
	var exp_panel = PanelContainer.new()
	exp_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color("#07090d")
	p_style.border_color = Color("#1d222e")
	p_style.set_border_width_all(1)
	p_style.set_corner_radius_all(6)
	exp_panel.add_theme_stylebox_override("panel", p_style)
	
	var exp_margin = MarginContainer.new()
	exp_margin.add_theme_constant_override("margin_left", 10)
	exp_margin.add_theme_constant_override("margin_right", 10)
	exp_margin.add_theme_constant_override("margin_top", 10)
	exp_margin.add_theme_constant_override("margin_bottom", 10)
	exp_panel.add_child(exp_margin)
	
	explanation_label = Label.new()
	explanation_label.text = "Initializing traces..."
	explanation_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	explanation_label.add_theme_color_override("font_color", Color("#a0a5b5"))
	explanation_label.add_theme_font_size_override("font_size", 11)
	exp_margin.add_child(explanation_label)
	
	vbox.add_child(exp_panel)
	
	# Return to Main Menu
	var back_btn = Button.new()
	back_btn.text = "RETURN TO MENU"
	back_btn.custom_minimum_size = Vector2(0, 35)
	
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color("#12141c")
	btn_normal.border_color = Color("#222736")
	btn_normal.set_border_width_all(1)
	btn_normal.set_corner_radius_all(6)
	
	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color("#1a1e2a")
	btn_hover.border_color = Color("#ff2a7a")
	btn_hover.set_border_width_all(1)
	btn_hover.set_corner_radius_all(6)
	
	back_btn.add_theme_stylebox_override("normal", btn_normal)
	back_btn.add_theme_stylebox_override("hover", btn_hover)
	back_btn.add_theme_stylebox_override("pressed", btn_hover)
	back_btn.add_theme_stylebox_override("focus", btn_hover)
	back_btn.add_theme_color_override("font_color", Color("#a0a5b5"))
	back_btn.add_theme_color_override("font_hover_color", Color.WHITE)
	back_btn.add_theme_font_size_override("font_size", 12)
	
	back_btn.pressed.connect(_on_back_pressed)
	vbox.add_child(back_btn)
	
	add_child(sidebar)

func create_stepper_btn(icon_path: String, callback: Callable, tooltip: String, out_btn_ref: Array) -> PanelContainer:
	var container = PanelContainer.new()
	
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color.TRANSPARENT
	style_normal.set_border_width_all(0)
	style_normal.set_corner_radius_all(16) # Circular (32x32 size has 16px radius)
	container.add_theme_stylebox_override("panel", style_normal)
	
	var btn = TextureButton.new()
	var tex = load(icon_path)
	btn.texture_normal = tex
	btn.tooltip_text = tooltip
	btn.custom_minimum_size = Vector2(32, 32)
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn.pressed.connect(callback)
	
	# Enable focus for keyboard & controller navigation support
	btn.focus_mode = Control.FOCUS_ALL
	
	container.add_child(btn)
	out_btn_ref[0] = btn
	
	# Active glowing neon cyan backlight stylebox
	var style_active = StyleBoxFlat.new()
	style_active.bg_color = Color("#1a1e2a")
	style_active.border_color = Color("#00f0ff") # Neon cyan backlight
	style_active.set_border_width_all(1)
	style_active.set_corner_radius_all(16)
	style_active.shadow_color = Color(0, 0.94, 1.0, 0.25)
	style_active.shadow_size = 6
	
	# Connect focus & hover signals to dynamically toggle backlight
	btn.focus_entered.connect(func(): container.add_theme_stylebox_override("panel", style_active))
	btn.focus_exited.connect(func(): container.add_theme_stylebox_override("panel", style_normal))
	btn.mouse_entered.connect(func(): container.add_theme_stylebox_override("panel", style_active))
	btn.mouse_exited.connect(func(): if not btn.has_focus(): container.add_theme_stylebox_override("panel", style_normal))
	
	return container

func setup_right_sidebar() -> void:
	var sidebar = PanelContainer.new()
	sidebar.name = "RightSidebar"
	sidebar.position = Vector2(840, 60)
	sidebar.size = Vector2(410, 600)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#0c0e14")
	style.border_color = Color("#00f0ff") # Neon cyan secondary border
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.shadow_color = Color(0.0, 0.94, 1.0, 0.1)
	style.shadow_size = 12
	sidebar.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	sidebar.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "ALGORITHM PSEUDOCODE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("#00f0ff"))
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "ALPHA-BETA MINIMAX SEARCH"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color("#606575"))
	subtitle.add_theme_font_size_override("font_size", 10)
	vbox.add_child(subtitle)
	
	vbox.add_child(HSeparator.new())
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)
	
	var code_list = VBoxContainer.new()
	code_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	code_list.add_theme_constant_override("separation", 1)
	scroll.add_child(code_list)
	
	code_rows.clear()
	code_labels.clear()
	
	# Instantiate 29 pseudocode line labels with specific layouts (shrunk font size & separation to fit 100% on screen)
	for i in range(PSEUDOCODE.size()):
		var line_container = PanelContainer.new()
		var p_style = StyleBoxFlat.new()
		p_style.bg_color = Color.TRANSPARENT
		p_style.set_content_margin_all(1)
		line_container.add_theme_stylebox_override("panel", p_style)
		
		var hbox = HBoxContainer.new()
		line_container.add_child(hbox)
		
		var num_lbl = Label.new()
		num_lbl.text = "%02d " % (i + 1)
		num_lbl.add_theme_color_override("font_color", Color("#00f0ff")) # Cyan numbers
		num_lbl.add_theme_font_size_override("font_size", 9)
		hbox.add_child(num_lbl)
		
		var code_lbl = Label.new()
		code_lbl.text = PSEUDOCODE[i]
		code_lbl.add_theme_color_override("font_color", Color("#a0a5b5"))
		code_lbl.add_theme_font_size_override("font_size", 9)
		hbox.add_child(code_lbl)
		
		code_list.add_child(line_container)
		code_rows.append(line_container)
		code_labels.append(code_lbl)
		
	add_child(sidebar)

func setup_gameplay_overlay() -> void:
	demo_overlay = Node2D.new()
	demo_overlay.name = "DemoOverlay"
	# Overlay aligns exactly over grid (X=300, Y=60)
	demo_overlay.position = Vector2(300, 60)
	demo_overlay.scale = Vector2(0.85, 0.85) # scale coordinates
	demo_overlay.draw.connect(_on_overlay_draw)
	add_child(demo_overlay)

func _on_overlay_draw() -> void:
	if ConfigManager.active_demo_mode == ConfigManager.DemoMode.REAL_TIME: return
	if trace_steps.is_empty() or trace_index >= trace_steps.size(): return
	
	var step = trace_steps[trace_index]
	
	# 1. Draw Breadth-First Search reachable space grids (with higher opacity and visible outlines so they stand out vibrantly over background grid lines)
	# P1 (Red) spatial reachability colors semi-transparent pink
	if step.has("red_reach_cells"):
		for cell in step.red_reach_cells:
			var rect = Rect2(cell.x * 30, cell.y * 30, 30, 30)
			demo_overlay.draw_rect(rect, Color("#ff2a7a", 0.28), true) # Increased fill opacity
			demo_overlay.draw_rect(rect, Color("#ff2a7a", 0.65), false, 1.5) # Increased outline opacity and thickness
			
	# P2 (Blue) spatial reachability colors semi-transparent cyan
	if step.has("blue_reach_cells"):
		for cell in step.blue_reach_cells:
			var rect = Rect2(cell.x * 30, cell.y * 30, 30, 30)
			demo_overlay.draw_rect(rect, Color("#00f0ff", 0.28), true) # Increased fill opacity
			demo_overlay.draw_rect(rect, Color("#00f0ff", 0.65), false, 1.5) # Increased outline opacity and thickness
			
	# 2. Draw Simulated move overlays
	if step.vars.has("move"):
		# Check if the active execution branch is simulating Blue AI (is_max) or Red (is_min)
		var is_max_line = step.line_num in [8, 9, 10, 11, 12, 13, 14, 15, 16]
		var target_pos = step.blue_pos if is_max_line else step.red_pos
		
		# Draw golden paths around the active simulated head cell
		var gold_rect = Rect2(target_pos.x * 30, target_pos.y * 30, 30, 30)
		demo_overlay.draw_rect(gold_rect, Color("#ffd700", 0.35), true)
		demo_overlay.draw_rect(gold_rect, Color("#ffd700", 0.9), false, 2.0)

func generate_new_move_trace() -> void:
	if gameplay == null or not is_instance_valid(gameplay): return
	
	var current_state = {
		"matrix": gameplay.grid_matrix.duplicate(true),
		"red_pos": gameplay.player_red.grid_position,
		"blue_pos": gameplay.ai_player.grid_position,
		"red_trail_count": gameplay.player_red.body_segments.size() + 1,
		"blue_trail_count": gameplay.ai_player.body_segments.size() + 1
	}
	
	# Execute search with trace capture
	trace_steps = tracer.run_trace(current_state, 2)
	trace_index = 0
	show_step(0)

func show_step(index: int) -> void:
	if trace_steps.is_empty(): return
	
	trace_index = clampi(index, 0, trace_steps.size() - 1)
	var step = trace_steps[trace_index]
	
	# Update Sidebar Data Grid Labels
	depth_lbl.text = "Search Depth: %d" % step.depth
	nodes_lbl.text = "Nodes Evaluated: %d" % step.nodes_evaluated
	alpha_lbl.text = "Alpha Bound: %.1f" % step.alpha
	beta_lbl.text = "Beta Bound: %.1f" % step.beta
	
	# Format score display neatly
	if step.line_num in [4, 10, 12, 17, 22, 24, 29]:
		value_lbl.text = "Branch Score: %.1f" % step.val
	else:
		value_lbl.text = "Branch Score: PENDING"
		
	explanation_label.text = step.explanation
	
	# Draw active glowing cyan background highlights on the Right Sidebar Pseudocode
	for i in range(code_rows.size()):
		var row = code_rows[i]
		var label = code_labels[i]
		
		# Reset all to default styles
		var normal_style = StyleBoxFlat.new()
		normal_style.bg_color = Color.TRANSPARENT
		normal_style.set_content_margin_all(2)
		row.add_theme_stylebox_override("panel", normal_style)
		label.add_theme_color_override("font_color", Color("#a0a5b5"))
		
	var active_line = step.line_num
	if active_line > 0 and active_line <= code_rows.size():
		var row = code_rows[active_line - 1]
		var label = code_labels[active_line - 1]
		
		var active_style = StyleBoxFlat.new()
		active_style.bg_color = Color("#14202e") # Neon cyber-blue backdrop
		active_style.border_color = Color("#00f0ff") # Neon cyan outline
		active_style.set_border_width_all(1)
		active_style.set_corner_radius_all(4)
		active_style.set_content_margin_all(2)
		active_style.shadow_color = Color(0, 0.94, 1.0, 0.15)
		active_style.shadow_size = 4
		
		row.add_theme_stylebox_override("panel", active_style)
		label.add_theme_color_override("font_color", Color.WHITE)
		
	# Redraw BFS Grid Overlays
	demo_overlay.queue_redraw()

func toggle_play_state(play: bool) -> void:
	is_playing = play
	if is_playing:
		play_pause_btn.texture_normal = load("res://assets/pause.png")
		step_timer.start()
	else:
		play_pause_btn.texture_normal = load("res://assets/play.png")
		step_timer.stop()

func save_game_state_to_history() -> void:
	# Records a complete visual & logical backup of the gameplay matrix, players and scores
	var cores_backup = {}
	for pos in gameplay.active_cores:
		var is_rare = gameplay.grid_matrix[pos.x][pos.y] == gameplay.CellType.RARE_ENERGY_CORE
		cores_backup[pos] = is_rare
		
	var frame = {
		"matrix": gameplay.grid_matrix.duplicate(true),
		"red_grid_position": gameplay.player_red.grid_position,
		"red_body_segments": gameplay.player_red.body_segments.duplicate(),
		"red_current_direction": gameplay.player_red.current_direction,
		"blue_grid_position": gameplay.ai_player.grid_position,
		"blue_body_segments": gameplay.ai_player.body_segments.duplicate(),
		"blue_current_direction": gameplay.ai_player.current_direction,
		"cores": cores_backup,
		"p1_basic_cores": gameplay.p1_basic_cores,
		"p2_basic_cores": gameplay.p2_basic_cores,
		"p1_rare_cores": gameplay.p1_rare_cores,
		"p2_rare_cores": gameplay.p2_rare_cores,
		"p1_captured_cells": gameplay.p1_captured_cells,
		"p2_captured_cells": gameplay.p2_captured_cells,
		"round_timer_elapsed": gameplay.round_timer_elapsed,
		"tick_count": gameplay.tick_count,
		"current_round": gameplay.current_round,
		"p1_match_score": gameplay.p1_match_score,
		"p2_match_score": gameplay.p2_match_score,
		"current_round_active": gameplay.current_round_active,
		"round_history": gameplay.round_history.duplicate()
	}
	game_history.append(frame)

func restore_game_state(frame: Dictionary) -> void:
	# 1. Clear current cores physically
	for pos in gameplay.active_cores:
		var node = gameplay.active_cores[pos]
		if is_instance_valid(node):
			node.queue_free()
	gameplay.active_cores.clear()
	
	# 2. Restore logical matrix
	gameplay.grid_matrix = frame.matrix.duplicate(true)
	
	# Re-spawn core nodes in exact spatial coordinates
	for pos in frame.cores:
		var is_rare = frame.cores[pos]
		spawn_core_at(pos, is_rare)
		
	# 3. Restore players position
	gameplay.player_red.grid_position = frame.red_grid_position
	gameplay.player_red.position = gameplay.tile_to_pixel(frame.red_grid_position)
	gameplay.player_red.body_segments = frame.red_body_segments.duplicate()
	gameplay.player_red.current_direction = frame.red_current_direction
	
	gameplay.ai_player.grid_position = frame.blue_grid_position
	gameplay.ai_player.position = gameplay.tile_to_pixel(frame.blue_grid_position)
	gameplay.ai_player.body_segments = frame.blue_body_segments.duplicate()
	gameplay.ai_player.current_direction = frame.blue_current_direction
	
	# 4. Restore round details
	gameplay.p1_basic_cores = frame.p1_basic_cores
	gameplay.p2_basic_cores = frame.p2_basic_cores
	gameplay.p1_rare_cores = frame.p1_rare_cores
	gameplay.p2_rare_cores = frame.p2_rare_cores
	gameplay.p1_captured_cells = frame.p1_captured_cells
	gameplay.p2_captured_cells = frame.p2_captured_cells
	gameplay.round_timer_elapsed = frame.round_timer_elapsed
	gameplay.tick_count = frame.tick_count
	gameplay.current_round = frame.current_round
	gameplay.p1_match_score = frame.p1_match_score
	gameplay.p2_match_score = frame.p2_match_score
	gameplay.current_round_active = frame.current_round_active
	gameplay.round_history = frame.round_history.duplicate()
	
	# 5. Redraw the TileMap grid visuals
	redraw_grid_layer_visuals()

func spawn_core_at(pos: Vector2i, is_rare: bool) -> Node2D:
	gameplay.grid_matrix[pos.x][pos.y] = gameplay.CellType.ENERGY_CORE if not is_rare else gameplay.CellType.RARE_ENERGY_CORE
	
	var core_node = Node2D.new()
	core_node.position = gameplay.tile_to_pixel(pos)
	
	var core_visual = Panel.new()
	core_visual.custom_minimum_size = Vector2(12, 12)
	core_visual.size = Vector2(12, 12)
	core_visual.position = Vector2(-6, -6)
	core_visual.pivot_offset = Vector2(6, 6)
	
	var style = StyleBoxFlat.new()
	var glow_color = Color("#ffd700") if is_rare else Color("#39ff14")
	style.bg_color = glow_color
	style.set_corner_radius_all(6)
	style.shadow_color = Color(glow_color.r, glow_color.g, glow_color.b, 0.8)
	style.shadow_size = 8
	
	core_visual.add_theme_stylebox_override("panel", style)
	core_node.add_child(core_visual)
	gameplay.add_child(core_node)
	
	var tween = core_node.create_tween().set_loops()
	tween.tween_property(core_visual, "scale", Vector2(1.3, 1.3), 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(core_visual, "scale", Vector2(0.7, 0.7), 0.4).set_trans(Tween.TRANS_SINE)
	
	gameplay.active_cores[pos] = core_node
	return core_node

func redraw_grid_layer_visuals() -> void:
	if gameplay == null or gameplay.grid_layer == null: return
	
	# Repaint entire TileMapLayer visually matching restored logical cells
	for x in range(gameplay.grid_width):
		for y in range(gameplay.grid_height):
			var type = gameplay.grid_matrix[x][y]
			var pos = Vector2i(x, y)
			
			match type:
				gameplay.CellType.EMPTY:
					gameplay.grid_layer.set_cell(pos, -1)
				gameplay.CellType.WALL:
					gameplay.grid_layer.set_cell(pos, 4, Vector2i(0, 0))
				gameplay.CellType.RED_TRAIL:
					gameplay.grid_layer.set_cell(pos, 2, Vector2i(0, 0))
				gameplay.CellType.BLUE_TRAIL:
					gameplay.grid_layer.set_cell(pos, 3, Vector2i(0, 0))
				_:
					gameplay.grid_layer.set_cell(pos, -1)

func advance_to_next_move() -> void:
	if gameplay == null or not is_instance_valid(gameplay): return
	
	# Stop auto-play while executing move transition
	var was_playing = is_playing
	toggle_play_state(false)
	
	# 1. Commit Red's decided direction from tracing results
	gameplay.player_red.current_direction = tracer.final_best_move
	
	# 2. Query P2 Blue AI automatically using its separate search
	var state_for_blue = {
		"matrix": gameplay.grid_matrix.duplicate(true),
		"red_pos": gameplay.player_red.grid_position,
		"blue_pos": gameplay.ai_player.grid_position,
		"red_trail_count": gameplay.player_red.body_segments.size() + 1,
		"blue_trail_count": gameplay.ai_player.body_segments.size() + 1
	}
	var blue_dir = gameplay.ai_player.think_and_decide(state_for_blue)
	gameplay.ai_player.current_direction = blue_dir
	
	# 3. Store visual history backup for backtracking
	save_game_state_to_history()
	
	# 4. Trigger exactly one logical tick cycle manually inside gameplay.gd
	gameplay._on_tick_timer_timeout()
	
	# Check if match/round completed
	if not gameplay.current_round_active:
		explanation_label.text = "ROUND FINISHED!\nUse 'Prev Game Tick' button to backtrack or return to menu."
		explanation_label.add_theme_color_override("font_color", Color("#ff2a7a"))
		return
		
	# 5. Generate a new minimax search trace for the next move
	generate_new_move_trace()
	
	# Resume auto play if active
	if was_playing:
		toggle_play_state(true)

# Stepper button callbacks

func _on_step_timer_timeout() -> void:
	if trace_index < trace_steps.size() - 1:
		trace_index += 1
		show_step(trace_index)
	else:
		# End of minimax search timeline reached! Advance to the next game tick!
		advance_to_next_move()

func _on_prev_line_pressed() -> void:
	toggle_play_state(false)
	if trace_index > 0:
		trace_index -= 1
		show_step(trace_index)

func _on_next_line_pressed() -> void:
	toggle_play_state(false)
	if trace_index < trace_steps.size() - 1:
		trace_index += 1
		show_step(trace_index)
	else:
		# Search trace finished, execute move
		advance_to_next_move()

func _on_play_pause_pressed() -> void:
	toggle_play_state(not is_playing)

func _on_prev_move_pressed() -> void:
	toggle_play_state(false)
	if not game_history.is_empty():
		var last_frame = game_history.pop_back()
		restore_game_state(last_frame)
		generate_new_move_trace()
	else:
		explanation_label.text = "No prior move timeline recorded to backtrack."

func _on_next_move_pressed() -> void:
	toggle_play_state(false)
	advance_to_next_move()

func _on_back_pressed() -> void:
	toggle_play_state(false)
	ConfigManager.is_in_demo = false
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
