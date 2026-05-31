extends CanvasLayer

signal play_again_requested
signal main_menu_requested

var countdown_overlay: Control
var countdown_label: Label
var countdown_round_label: Label

var post_round_overlay: Control
var post_game_overlay: Control

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

func setup_countdown_overlay() -> void:
	countdown_overlay = Control.new()
	countdown_overlay.name = "CountdownOverlay"
	countdown_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	countdown_overlay.visible = false
	add_child(countdown_overlay)
	
	# Fullscreen dark glass overlay
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.04, 0.06, 0.8) # 80% opacity dark blue-gray
	countdown_overlay.add_child(bg)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	countdown_overlay.add_child(vbox)
	
	countdown_round_label = Label.new()
	countdown_round_label.text = "ROUND 1"
	countdown_round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_round_label.add_theme_color_override("font_color", Color("#00f0ff")) # Neon cyan
	countdown_round_label.add_theme_font_size_override("font_size", 36)
	vbox.add_child(countdown_round_label)
	
	var prep_lbl = Label.new()
	prep_lbl.text = "GET READY..."
	prep_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prep_lbl.add_theme_color_override("font_color", Color("#a0a5b5"))
	prep_lbl.add_theme_font_size_override("font_size", 18)
	vbox.add_child(prep_lbl)
	
	countdown_label = Label.new()
	countdown_label.text = "3"
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.add_theme_color_override("font_color", Color("#ff2a7a")) # Neon pink
	countdown_label.add_theme_font_size_override("font_size", 84)
	countdown_label.pivot_offset = Vector2(100, 100) # Ensure scaling anchors to center
	vbox.add_child(countdown_label)

func start_round_countdown(round_num: int, callback: Callable) -> void:
	if countdown_overlay == null:
		setup_countdown_overlay()
		
	countdown_round_label.text = "ROUND %d" % round_num
	countdown_label.text = "3"
	countdown_label.add_theme_color_override("font_color", Color("#ff2a7a"))
	countdown_overlay.visible = true
	
	# Pulse "3"
	var tween = create_tween()
	countdown_label.scale = Vector2.ONE
	tween.tween_property(countdown_label, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(countdown_label, "scale", Vector2(1.0, 1.0), 0.4)
	
	await get_tree().create_timer(1.0).timeout
	countdown_label.text = "2"
	var tween2 = create_tween()
	countdown_label.scale = Vector2.ONE
	tween2.tween_property(countdown_label, "scale", Vector2(1.3, 1.3), 0.1)
	tween2.tween_property(countdown_label, "scale", Vector2(1.0, 1.0), 0.4)
	
	await get_tree().create_timer(1.0).timeout
	countdown_label.text = "1"
	var tween3 = create_tween()
	countdown_label.scale = Vector2.ONE
	tween3.tween_property(countdown_label, "scale", Vector2(1.3, 1.3), 0.1)
	tween3.tween_property(countdown_label, "scale", Vector2(1.0, 1.0), 0.4)
	
	await get_tree().create_timer(1.0).timeout
	countdown_label.text = "GO!"
	countdown_label.add_theme_color_override("font_color", Color("#00f0ff"))
	var tween4 = create_tween()
	countdown_label.scale = Vector2.ONE
	tween4.tween_property(countdown_label, "scale", Vector2(1.8, 1.8), 0.1)
	tween4.tween_property(countdown_label, "scale", Vector2(1.0, 1.0), 0.4)
	
	await get_tree().create_timer(0.8).timeout
	countdown_overlay.visible = false
	callback.call()

func setup_post_round_overlay() -> void:
	post_round_overlay = Control.new()
	post_round_overlay.name = "PostRoundOverlay"
	post_round_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	post_round_overlay.visible = false
	add_child(post_round_overlay)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.04, 0.06, 0.85)
	post_round_overlay.add_child(bg)

func show_round_results(round_num: int, winner_type: String, winner_text: String, p1_round_pts: int, ai_round_pts: int, p1_cells: int, ai_cells: int, p1_basic: int, p1_rare: int, ai_basic: int, ai_rare: int, callback: Callable) -> void:
	if post_round_overlay == null:
		setup_post_round_overlay()
		
	# Clear children of overlay except BG
	for child in post_round_overlay.get_children():
		if child != post_round_overlay.get_child(0):
			child.queue_free()
			
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	post_round_overlay.add_child(vbox)
	
	var title = Label.new()
	title.text = "ROUND %d COMPLETE" % round_num
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("#a0a5b5"))
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	var announcement = Label.new()
	announcement.text = winner_text.to_upper()
	announcement.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var color = Color("#ffaa00") # gold for DRAW
	if winner_type == "RED":
		color = Color("#ff2a7a")
	elif winner_type == "BLUE":
		color = Color("#00f0ff")
	announcement.add_theme_color_override("font_color", color)
	announcement.add_theme_font_size_override("font_size", 32)
	vbox.add_child(announcement)
	
	# Score Breakdown Panel
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#0c0e14")
	panel_style.border_color = Color("#222736")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", panel_style)
	vbox.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 25)
	margin.add_theme_constant_override("margin_right", 25)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	panel.add_child(margin)
	
	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 40)
	grid.add_theme_constant_override("v_separation", 10)
	margin.add_child(grid)
	
	# Headers
	grid.add_child(Control.new())
	
	var h_p1 = Label.new()
	h_p1.text = "PLAYER 1"
	h_p1.add_theme_color_override("font_color", Color("#ff2a7a"))
	h_p1.add_theme_font_size_override("font_size", 14)
	grid.add_child(h_p1)
	
	var h_ai = Label.new()
	h_ai.text = "BLUE AI"
	h_ai.add_theme_color_override("font_color", Color("#00f0ff"))
	h_ai.add_theme_font_size_override("font_size", 14)
	grid.add_child(h_ai)
	
	# Rows
	add_breakdown_row(grid, "Captured Cells:", "%d (+%d)" % [p1_cells, p1_cells], "%d (+%d)" % [ai_cells, ai_cells])
	add_breakdown_row(grid, "Basic Cores:", "%d (+%d)" % [p1_basic, p1_basic * 5], "%d (+%d)" % [ai_basic, ai_basic * 5])
	add_breakdown_row(grid, "Rare Cores:", "%d (+%d)" % [p1_rare, p1_rare * 10], "%d (+%d)" % [ai_rare, ai_rare * 10])
	
	var p1_bonus = 50 if winner_type == "RED" else (25 if winner_type == "DRAW" else 0)
	var ai_bonus = 50 if winner_type == "BLUE" else (25 if winner_type == "DRAW" else 0)
	add_breakdown_row(grid, "Round Bonus:", "+%d" % p1_bonus, "+%d" % ai_bonus)
	add_breakdown_row(grid, "Round Total:", "%d pts" % p1_round_pts, "%d pts" % ai_round_pts, true)
	
	var next_lbl = Label.new()
	next_lbl.text = "PREPARING NEXT ROUND..."
	next_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	next_lbl.add_theme_color_override("font_color", Color("#606575"))
	next_lbl.add_theme_font_size_override("font_size", 14)
	vbox.add_child(next_lbl)
	
	post_round_overlay.visible = true
	
	# Wait for 3 seconds, then callback
	await get_tree().create_timer(3.0).timeout
	post_round_overlay.visible = false
	callback.call()

func add_breakdown_row(grid: GridContainer, label_text: String, p1_text: String, ai_text: String, bold: bool = false) -> void:
	var lbl = Label.new()
	lbl.text = label_text
	lbl.add_theme_color_override("font_color", Color("#a0a5b5") if not bold else Color.WHITE)
	lbl.add_theme_font_size_override("font_size", 13 if not bold else 14)
	grid.add_child(lbl)
	
	var p1 = Label.new()
	p1.text = p1_text
	p1.add_theme_color_override("font_color", Color("#ff2a7a") if bold else Color.WHITE)
	p1.add_theme_font_size_override("font_size", 13 if not bold else 14)
	grid.add_child(p1)
	
	var ai = Label.new()
	ai.text = ai_text
	ai.add_theme_color_override("font_color", Color("#00f0ff") if bold else Color.WHITE)
	ai.add_theme_font_size_override("font_size", 13 if not bold else 14)
	grid.add_child(ai)

func setup_post_game_overlay() -> void:
	post_game_overlay = Control.new()
	post_game_overlay.name = "PostGameOverlay"
	post_game_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	post_game_overlay.visible = false
	add_child(post_game_overlay)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.04, 0.06, 0.9)
	post_game_overlay.add_child(bg)

func show_match_results(winner_type: String, winner_text: String, p1_total: int, ai_total: int) -> void:
	if post_game_overlay == null:
		setup_post_game_overlay()
		
	# Clear children of overlay except BG
	for child in post_game_overlay.get_children():
		if child != post_game_overlay.get_child(0):
			child.queue_free()
			
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 25)
	post_game_overlay.add_child(vbox)
	
	var title = Label.new()
	title.text = "MATCH COMPLETE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("#a0a5b5"))
	title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(title)
	
	var champion = Label.new()
	champion.text = winner_text.to_upper()
	champion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var color = Color("#ffaa00") # gold for draw
	if winner_type == "RED":
		color = Color("#ff2a7a")
	elif winner_type == "BLUE":
		color = Color("#00f0ff")
	champion.add_theme_color_override("font_color", color)
	champion.add_theme_font_size_override("font_size", 36)
	vbox.add_child(champion)
	
	# Score display panel
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#0c0e14")
	panel_style.border_color = color
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(10)
	panel_style.shadow_color = Color(color.r, color.g, color.b, 0.2)
	panel_style.shadow_size = 12
	panel.add_theme_stylebox_override("panel", panel_style)
	vbox.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 35)
	margin.add_theme_constant_override("margin_right", 35)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)
	
	var scores = Label.new()
	scores.text = "PLAYER 1: %d pts   |   BLUE AI: %d pts" % [p1_total, ai_total]
	scores.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scores.add_theme_font_size_override("font_size", 20)
	scores.add_theme_color_override("font_color", Color.WHITE)
	margin.add_child(scores)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)
	
	# Action buttons
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 30)
	vbox.add_child(hbox)
	
	var again_btn = Button.new()
	again_btn.text = "PLAY AGAIN"
	again_btn.custom_minimum_size = Vector2(180, 45)
	again_btn.pressed.connect(func():
		post_game_overlay.visible = false
		play_again_requested.emit()
	)
	hbox.add_child(again_btn)
	
	var menu_btn = Button.new()
	menu_btn.text = "MAIN MENU"
	menu_btn.custom_minimum_size = Vector2(180, 45)
	menu_btn.pressed.connect(func():
		post_game_overlay.visible = false
		main_menu_requested.emit()
	)
	hbox.add_child(menu_btn)
	
	# Style buttons
	var style_again = StyleBoxFlat.new()
	style_again.bg_color = Color("#0c0e14")
	style_again.border_color = Color("#ff2a7a")
	style_again.set_border_width_all(1)
	style_again.set_corner_radius_all(6)
	
	var style_menu = StyleBoxFlat.new()
	style_menu.bg_color = Color("#0c0e14")
	style_menu.border_color = Color("#00f0ff")
	style_menu.set_border_width_all(1)
	style_menu.set_corner_radius_all(6)
	
	again_btn.add_theme_stylebox_override("normal", style_again)
	again_btn.add_theme_color_override("font_color", Color("#ff2a7a"))
	
	menu_btn.add_theme_stylebox_override("normal", style_menu)
	menu_btn.add_theme_color_override("font_color", Color("#00f0ff"))
	
	post_game_overlay.visible = true
