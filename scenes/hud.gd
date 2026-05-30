extends CanvasLayer

var left_match_label: Label
var left_round_label: Label
var left_cells_label: Label
var left_progress: ProgressBar
var left_cores_label: Label
var left_rare_label: Label

var right_match_label: Label
var right_round_label: Label
var right_cells_label: Label
var right_progress: ProgressBar
var right_cores_label: Label
var right_rare_label: Label

var round_title: Label
var round_indicators: HBoxContainer
var timer_label: Label

var ai_depth: Label
var ai_speed: Label
var ai_nodes: Label

func create_neon_panel(border_color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#0c0e14") # Deep cybernetic charcoal
	style.border_color = border_color
	style.set_border_width_all(2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	
	# Glow effect using shadows
	style.shadow_color = Color(border_color.r, border_color.g, border_color.b, 0.3)
	style.shadow_size = 12
	style.shadow_offset = Vector2.ZERO
	return style

func _ready() -> void:
	# Main Control container that anchors to screen
	var main_ctrl = Control.new()
	main_ctrl.name = "MainControl"
	main_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_ctrl)
	
	# Left HUD Panel (Red Player)
	var left_panel = PanelContainer.new()
	left_panel.name = "LeftHUD"
	left_panel.position = Vector2(30, 60)
	left_panel.size = Vector2(280, 600)
	left_panel.add_theme_stylebox_override("panel", create_neon_panel(Color("#ff2a7a")))
	main_ctrl.add_child(left_panel)
	
	var left_margin = MarginContainer.new()
	left_margin.add_theme_constant_override("margin_left", 15)
	left_margin.add_theme_constant_override("margin_top", 15)
	left_margin.add_theme_constant_override("margin_right", 15)
	left_margin.add_theme_constant_override("margin_bottom", 15)
	left_panel.add_child(left_margin)
	
	var left_vbox = VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 12)
	left_margin.add_child(left_vbox)
	
	# P1 Header
	var left_header = Label.new()
	left_header.text = "PLAYER 1"
	left_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_header.add_theme_color_override("font_color", Color("#ff2a7a"))
	left_header.add_theme_font_size_override("font_size", 22)
	left_vbox.add_child(left_header)
	
	# Match score accumulated
	left_match_label = Label.new()
	left_match_label.text = "MATCH: 0 pts"
	left_match_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_match_label.add_theme_font_size_override("font_size", 18)
	left_vbox.add_child(left_match_label)
	
	var sep1 = HSeparator.new()
	left_vbox.add_child(sep1)
	
	# Round statistics
	var left_round_box = VBoxContainer.new()
	left_round_box.add_theme_constant_override("separation", 6)
	left_vbox.add_child(left_round_box)
	
	left_round_label = Label.new()
	left_round_label.text = "Round Pts: 0"
	left_round_label.add_theme_font_size_override("font_size", 16)
	left_round_box.add_child(left_round_label)
	
	left_cells_label = Label.new()
	left_cells_label.text = "Captured: 0 Cells"
	left_cells_label.add_theme_font_size_override("font_size", 14)
	left_round_box.add_child(left_cells_label)
	
	left_progress = ProgressBar.new()
	left_progress.max_value = 100.0
	left_progress.value = 0.0
	left_progress.show_percentage = true
	left_progress.custom_minimum_size = Vector2(0, 16)
	
	var sb_fill = StyleBoxFlat.new()
	sb_fill.bg_color = Color("#ff2a7a")
	sb_fill.corner_radius_top_left = 4
	sb_fill.corner_radius_top_right = 4
	sb_fill.corner_radius_bottom_left = 4
	sb_fill.corner_radius_bottom_right = 4
	left_progress.add_theme_stylebox_override("fill", sb_fill)
	left_round_box.add_child(left_progress)
	
	var sep_left_mid = HSeparator.new()
	left_vbox.add_child(sep_left_mid)
	
	# Cores Grid
	var left_grid = GridContainer.new()
	left_grid.columns = 2
	left_grid.add_theme_constant_override("h_separation", 15)
	left_grid.add_theme_constant_override("v_separation", 6)
	left_vbox.add_child(left_grid)
	
	var lbl_cores_t = Label.new()
	lbl_cores_t.text = "Basic Cores:"
	lbl_cores_t.add_theme_font_size_override("font_size", 13)
	left_grid.add_child(lbl_cores_t)
	
	left_cores_label = Label.new()
	left_cores_label.text = "0"
	left_cores_label.add_theme_font_size_override("font_size", 13)
	left_grid.add_child(left_cores_label)
	
	var lbl_rare_t = Label.new()
	lbl_rare_t.text = "Rare Cores:"
	lbl_rare_t.add_theme_font_size_override("font_size", 13)
	left_grid.add_child(lbl_rare_t)
	
	left_rare_label = Label.new()
	left_rare_label.text = "0"
	left_rare_label.add_theme_font_size_override("font_size", 13)
	left_grid.add_child(left_rare_label)
	
	# Expand spacer
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(spacer)
	
	# Controls Info Box
	var ctrl_box = PanelContainer.new()
	var ctrl_style = StyleBoxFlat.new()
	ctrl_style.bg_color = Color("#141722")
	ctrl_style.set_border_width_all(1)
	ctrl_style.border_color = Color("#222736")
	ctrl_style.corner_radius_top_left = 6
	ctrl_style.corner_radius_top_right = 6
	ctrl_style.corner_radius_bottom_left = 6
	ctrl_style.corner_radius_bottom_right = 6
	ctrl_box.add_theme_stylebox_override("panel", ctrl_style)
	left_vbox.add_child(ctrl_box)
	
	var ctrl_margin = MarginContainer.new()
	ctrl_margin.add_theme_constant_override("margin_left", 8)
	ctrl_margin.add_theme_constant_override("margin_top", 8)
	ctrl_margin.add_theme_constant_override("margin_right", 8)
	ctrl_margin.add_theme_constant_override("margin_bottom", 8)
	ctrl_box.add_child(ctrl_margin)
	
	var ctrl_lbl = Label.new()
	ctrl_lbl.text = "CONTROLS\nWASD or Arrow Keys\nChange direction\nwithout 180 flips."
	ctrl_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ctrl_lbl.add_theme_font_size_override("font_size", 12)
	ctrl_lbl.add_theme_color_override("font_color", Color("#a0a5b5"))
	ctrl_margin.add_child(ctrl_lbl)
	
	# Right HUD Panel (Blue AI)
	var right_panel = PanelContainer.new()
	right_panel.name = "RightHUD"
	right_panel.position = Vector2(970, 60)
	right_panel.size = Vector2(280, 600)
	right_panel.add_theme_stylebox_override("panel", create_neon_panel(Color("#00f0ff")))
	main_ctrl.add_child(right_panel)
	
	var right_margin = MarginContainer.new()
	right_margin.add_theme_constant_override("margin_left", 15)
	right_margin.add_theme_constant_override("margin_top", 15)
	right_margin.add_theme_constant_override("margin_right", 15)
	right_margin.add_theme_constant_override("margin_bottom", 15)
	right_panel.add_child(right_margin)
	
	var right_vbox = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 12)
	right_margin.add_child(right_vbox)
	
	# AI Header
	var right_header = Label.new()
	right_header.text = "AI SEARCHER"
	right_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_header.add_theme_color_override("font_color", Color("#00f0ff"))
	right_header.add_theme_font_size_override("font_size", 22)
	right_vbox.add_child(right_header)
	
	# Match score accumulated
	right_match_label = Label.new()
	right_match_label.text = "MATCH: 0 pts"
	right_match_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_match_label.add_theme_font_size_override("font_size", 18)
	right_vbox.add_child(right_match_label)
	
	var sep2 = HSeparator.new()
	right_vbox.add_child(sep2)
	
	# Round stats
	var right_round_box = VBoxContainer.new()
	right_round_box.add_theme_constant_override("separation", 6)
	right_vbox.add_child(right_round_box)
	
	right_round_label = Label.new()
	right_round_label.text = "Round Pts: 0"
	right_round_label.add_theme_font_size_override("font_size", 16)
	right_round_box.add_child(right_round_label)
	
	right_cells_label = Label.new()
	right_cells_label.text = "Captured: 0 Cells"
	right_cells_label.add_theme_font_size_override("font_size", 14)
	right_round_box.add_child(right_cells_label)
	
	right_progress = ProgressBar.new()
	right_progress.max_value = 100.0
	right_progress.value = 0.0
	right_progress.show_percentage = true
	right_progress.custom_minimum_size = Vector2(0, 16)
	
	var sb_fill_blue = StyleBoxFlat.new()
	sb_fill_blue.bg_color = Color("#00f0ff")
	sb_fill_blue.corner_radius_top_left = 4
	sb_fill_blue.corner_radius_top_right = 4
	sb_fill_blue.corner_radius_bottom_left = 4
	sb_fill_blue.corner_radius_bottom_right = 4
	right_progress.add_theme_stylebox_override("fill", sb_fill_blue)
	right_round_box.add_child(right_progress)
	
	var sep_right_mid = HSeparator.new()
	right_vbox.add_child(sep_right_mid)
	
	# Cores Grid
	var right_grid = GridContainer.new()
	right_grid.columns = 2
	right_grid.add_theme_constant_override("h_separation", 15)
	right_grid.add_theme_constant_override("v_separation", 6)
	right_vbox.add_child(right_grid)
	
	var lbl_cores_t2 = Label.new()
	lbl_cores_t2.text = "Basic Cores:"
	lbl_cores_t2.add_theme_font_size_override("font_size", 13)
	right_grid.add_child(lbl_cores_t2)
	
	right_cores_label = Label.new()
	right_cores_label.text = "0"
	right_cores_label.add_theme_font_size_override("font_size", 13)
	right_grid.add_child(right_cores_label)
	
	var lbl_rare_t2 = Label.new()
	lbl_rare_t2.text = "Rare Cores:"
	lbl_rare_t2.add_theme_font_size_override("font_size", 13)
	right_grid.add_child(lbl_rare_t2)
	
	right_rare_label = Label.new()
	right_rare_label.text = "0"
	right_rare_label.add_theme_font_size_override("font_size", 13)
	right_grid.add_child(right_rare_label)
	
	# Expand spacer
	var spacer2 = Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(spacer2)
	
	# AI Telemetry Box
	var ai_box = PanelContainer.new()
	ai_box.add_theme_stylebox_override("panel", ctrl_style)
	right_vbox.add_child(ai_box)
	
	var ai_margin = MarginContainer.new()
	ai_margin.add_theme_constant_override("margin_left", 8)
	ai_margin.add_theme_constant_override("margin_top", 8)
	ai_margin.add_theme_constant_override("margin_right", 8)
	ai_margin.add_theme_constant_override("margin_bottom", 8)
	ai_box.add_child(ai_margin)
	
	var ai_vbox = VBoxContainer.new()
	ai_margin.add_child(ai_vbox)
	
	var ai_title = Label.new()
	ai_title.text = "MINIMAX TELEMETRY"
	ai_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ai_title.add_theme_font_size_override("font_size", 11)
	ai_title.add_theme_color_override("font_color", Color("#00f0ff"))
	ai_vbox.add_child(ai_title)
	
	ai_depth = Label.new()
	ai_depth.text = "Search Depth: 0"
	ai_depth.add_theme_font_size_override("font_size", 11)
	ai_depth.add_theme_color_override("font_color", Color("#a0a5b5"))
	ai_vbox.add_child(ai_depth)
	
	ai_speed = Label.new()
	ai_speed.text = "Speed: 0ms/tick"
	ai_speed.add_theme_font_size_override("font_size", 11)
	ai_speed.add_theme_color_override("font_color", Color("#a0a5b5"))
	ai_vbox.add_child(ai_speed)
	
	ai_nodes = Label.new()
	ai_nodes.text = "Evaluation: Idle"
	ai_nodes.add_theme_font_size_override("font_size", 11)
	ai_nodes.add_theme_color_override("font_color", Color("#a0a5b5"))
	ai_vbox.add_child(ai_nodes)
	
	# Top HUD container
	var top_hud = HBoxContainer.new()
	top_hud.name = "TopHUD"
	top_hud.position = Vector2(340, 15)
	top_hud.size = Vector2(600, 40)
	top_hud.alignment = BoxContainer.ALIGNMENT_CENTER
	main_ctrl.add_child(top_hud)
	
	round_title = Label.new()
	round_title.text = "ROUND 1/5"
	round_title.add_theme_font_size_override("font_size", 18)
	round_title.add_theme_color_override("font_color", Color.WHITE)
	top_hud.add_child(round_title)
	
	var top_space = Control.new()
	top_space.custom_minimum_size = Vector2(15, 0)
	top_hud.add_child(top_space)
	
	# Round Indicators Layout
	round_indicators = HBoxContainer.new()
	round_indicators.alignment = BoxContainer.ALIGNMENT_CENTER
	round_indicators.add_theme_constant_override("separation", 6)
	top_hud.add_child(round_indicators)
	
	for i in range(5):
		var indicator = Label.new()
		indicator.text = "○"
		indicator.add_theme_font_size_override("font_size", 20)
		indicator.add_theme_color_override("font_color", Color("#606575"))
		round_indicators.add_child(indicator)
		
	var top_space2 = Control.new()
	top_space2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hud.add_child(top_space2)
	
	timer_label = Label.new()
	timer_label.text = "00:00"
	timer_label.add_theme_font_size_override("font_size", 18)
	timer_label.add_theme_color_override("font_color", Color.WHITE)
	top_hud.add_child(timer_label)

func update_scores(left_match: int, left_round: int, right_match: int, right_round: int) -> void:
	left_match_label.text = "MATCH: %d pts" % left_match
	left_round_label.text = "Round Pts: %d" % left_round
	right_match_label.text = "MATCH: %d pts" % right_match
	right_round_label.text = "Round Pts: %d" % right_round

func update_cells(left_cells: int, left_pct: float, right_cells: int, right_pct: float) -> void:
	left_cells_label.text = "Captured: %d Cells" % left_cells
	left_progress.value = left_pct
	
	right_cells_label.text = "Captured: %d Cells" % right_cells
	right_progress.value = right_pct

func update_cores(left_basic: int, left_rare: int, right_basic: int, right_rare: int) -> void:
	left_cores_label.text = str(left_basic)
	left_rare_label.text = str(left_rare)
	right_cores_label.text = str(right_basic)
	right_rare_label.text = str(right_rare)

func update_round(current_round: int, max_rounds: int, round_history: Array) -> void:
	round_title.text = "ROUND %d/%d" % [current_round, max_rounds]
	
	var children = round_indicators.get_children()
	for i in range(children.size()):
		if i < round_history.size():
			var outcome = round_history[i]
			if outcome == "RED":
				children[i].text = "●"
				children[i].add_theme_color_override("font_color", Color("#ff2a7a"))
			elif outcome == "BLUE":
				children[i].text = "●"
				children[i].add_theme_color_override("font_color", Color("#00f0ff"))
			elif outcome == "DRAW":
				children[i].text = "◌"
				children[i].add_theme_color_override("font_color", Color("#ffaa00"))
		else:
			children[i].text = "○"
			children[i].add_theme_color_override("font_color", Color("#606575"))

func update_timer(secs: int) -> void:
	var mins = secs / 60
	var rem_secs = secs % 60
	timer_label.text = "%02d:%02d" % [mins, rem_secs]

func update_ai_telemetry(depth: int, time_ms: float, nodes: int) -> void:
	ai_depth.text = "Search Depth: %d" % depth
	ai_speed.text = "Speed: %.1f ms" % time_ms
	ai_nodes.text = "Nodes: %d" % nodes
