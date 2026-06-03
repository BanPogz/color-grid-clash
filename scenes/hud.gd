extends CanvasLayer

signal play_again_requested
signal main_menu_requested
signal resume_requested
signal restart_requested

var countdown_overlay: Control
var countdown_label: Label
var countdown_round_label: Label

var post_round_overlay: Control
var post_game_overlay: Control
var pause_overlay: Control

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

var red_depth_label: Label
var red_speed_label: Label
var red_nodes_label: Label

var blue_depth_label: Label
var blue_speed_label: Label
var blue_nodes_label: Label

var waiting_for_continue: bool = false
var continue_callback: Callable

func create_neon_panel(border_color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#07090ebd") # Deep cybernetic glassmorphism (74% opacity)
	style.border_color = border_color
	style.set_border_width_all(1) # Sleek thin cyber-border
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	
	# Refined glow effect using shadows
	style.shadow_color = Color(border_color.r, border_color.g, border_color.b, 0.15)
	style.shadow_size = 16
	style.shadow_offset = Vector2.ZERO
	return style

func create_inner_panel(player_id: int) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#0a0c12bf") # Dark glass inner card (75% opacity)
	var player_color = Color("#ff2a7a") if player_id == 1 else Color("#00f0ff")
	style.border_color = Color(player_color.r, player_color.g, player_color.b, 0.25)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style

func create_controls_box(player_id: int) -> PanelContainer:
	var ctrl_box = PanelContainer.new()
	ctrl_box.add_theme_stylebox_override("panel", create_inner_panel(player_id))
	
	var ctrl_margin = MarginContainer.new()
	ctrl_margin.add_theme_constant_override("margin_left", 8)
	ctrl_margin.add_theme_constant_override("margin_top", 8)
	ctrl_margin.add_theme_constant_override("margin_right", 8)
	ctrl_margin.add_theme_constant_override("margin_bottom", 8)
	ctrl_box.add_child(ctrl_margin)
	
	var ctrl_vbox = VBoxContainer.new()
	ctrl_vbox.add_theme_constant_override("separation", 4)
	ctrl_margin.add_child(ctrl_vbox)
	
	var ctrl_title = Label.new()
	ctrl_title.text = "CONTROLS"
	ctrl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ctrl_title.add_theme_font_size_override("font_size", 12)
	ctrl_title.add_theme_color_override("font_color", Color("#ff2a7a") if player_id == 1 else Color("#00f0ff"))
	ctrl_vbox.add_child(ctrl_title)
	
	var ctrl_lbl = Label.new()
	var is_pvp = (not ConfigManager.red_is_ai) and (not ConfigManager.blue_is_ai)
	if player_id == 1:
		if is_pvp:
			ctrl_lbl.text = "WASD Keys\nChange direction\nwithout 180 flips."
		else:
			ctrl_lbl.text = "Arrow Keys or WASD\nChange direction\nwithout 180 flips."
	else:
		ctrl_lbl.text = "Arrow Keys\nChange direction\nwithout 180 flips."
		
	ctrl_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ctrl_lbl.add_theme_font_size_override("font_size", 13)
	ctrl_lbl.add_theme_color_override("font_color", Color("#a0a5b5"))
	ctrl_vbox.add_child(ctrl_lbl)
	return ctrl_box

func create_telemetry_box(player_id: int) -> PanelContainer:
	var ai_box = PanelContainer.new()
	ai_box.add_theme_stylebox_override("panel", create_inner_panel(player_id))
	
	var ai_margin = MarginContainer.new()
	ai_margin.add_theme_constant_override("margin_left", 8)
	ai_margin.add_theme_constant_override("margin_top", 8)
	ai_margin.add_theme_constant_override("margin_right", 8)
	ai_margin.add_theme_constant_override("margin_bottom", 8)
	ai_box.add_child(ai_margin)
	
	var ai_vbox = VBoxContainer.new()
	ai_vbox.add_theme_constant_override("separation", 4)
	ai_margin.add_child(ai_vbox)
	
	var ai_title = Label.new()
	ai_title.text = "MINIMAX TELEMETRY"
	ai_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ai_title.add_theme_font_size_override("font_size", 12)
	ai_title.add_theme_color_override("font_color", Color("#ff2a7a") if player_id == 1 else Color("#00f0ff"))
	ai_vbox.add_child(ai_title)
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 2)
	ai_vbox.add_child(grid)
	
	var d_title = Label.new()
	d_title.text = "Search Depth:"
	d_title.add_theme_font_size_override("font_size", 13)
	d_title.add_theme_color_override("font_color", Color("#a0a5b5"))
	d_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(d_title)
	
	var d_lbl = Label.new()
	d_lbl.text = "0"
	d_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	d_lbl.add_theme_font_size_override("font_size", 13)
	d_lbl.add_theme_color_override("font_color", Color.WHITE)
	grid.add_child(d_lbl)
	
	var s_title = Label.new()
	s_title.text = "Tick Speed:"
	s_title.add_theme_font_size_override("font_size", 13)
	s_title.add_theme_color_override("font_color", Color("#a0a5b5"))
	s_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(s_title)
	
	var s_lbl = Label.new()
	s_lbl.text = "0.0 ms"
	s_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	s_lbl.add_theme_font_size_override("font_size", 13)
	s_lbl.add_theme_color_override("font_color", Color.WHITE)
	grid.add_child(s_lbl)
	
	var n_title = Label.new()
	n_title.text = "Evaluation:"
	n_title.add_theme_font_size_override("font_size", 13)
	n_title.add_theme_color_override("font_color", Color("#a0a5b5"))
	n_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(n_title)
	
	var n_lbl = Label.new()
	n_lbl.text = "Idle"
	n_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	n_lbl.add_theme_font_size_override("font_size", 13)
	n_lbl.add_theme_color_override("font_color", Color.WHITE)
	grid.add_child(n_lbl)
	
	if player_id == 1:
		red_depth_label = d_lbl
		red_speed_label = s_lbl
		red_nodes_label = n_lbl
	else:
		blue_depth_label = d_lbl
		blue_speed_label = s_lbl
		blue_nodes_label = n_lbl
		
	return ai_box

func _ready() -> void:
	# Enable UI input handling even when Node tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Load tech/modern HUD font
	var hud_theme = Theme.new()
	var theme_font = preload("res://assets/fonts/ChakraPetch-Regular.ttf")
	hud_theme.default_font = theme_font
	
	# Main Control container that anchors to screen
	var main_ctrl = Control.new()
	main_ctrl.name = "MainControl"
	main_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_ctrl.theme = hud_theme
	add_child(main_ctrl)
	
	# Gameplay Pause Button in the top-left of the screen (custom drawn, borderless)
	var pause_btn = GameplayPauseButton.new(self)
	pause_btn.name = "GameplayPauseButton"
	pause_btn.position = Vector2(15, 10)
	main_ctrl.add_child(pause_btn)
	
	# Left HUD Panel (Red Player)
	var left_panel = PanelContainer.new()
	left_panel.name = "LeftHUD"
	left_panel.position = Vector2(30, 60)
	left_panel.size = Vector2(280, 600)
	left_panel.add_theme_stylebox_override("panel", create_neon_panel(Color("#ff2a7a")))
	main_ctrl.add_child(left_panel)
	
	var left_margin = MarginContainer.new()
	left_margin.add_theme_constant_override("margin_left", 20)
	left_margin.add_theme_constant_override("margin_top", 20)
	left_margin.add_theme_constant_override("margin_right", 20)
	left_margin.add_theme_constant_override("margin_bottom", 20)
	left_panel.add_child(left_margin)
	
	var left_vbox = VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 12)
	left_margin.add_child(left_vbox)
	
	# P1 Header
	var left_header = Label.new()
	if ConfigManager.red_is_ai:
		left_header.text = "AI 1"
	else:
		left_header.text = "PLAYER 1"
	left_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_header.add_theme_color_override("font_color", Color("#ff2a7a"))
	left_header.add_theme_font_size_override("font_size", 22)
	left_vbox.add_child(left_header)
	
	# Match score accumulated
	left_match_label = Label.new()
	left_match_label.text = "MATCH: 0 pts"
	left_match_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_match_label.add_theme_font_size_override("font_size", 16)
	left_match_label.add_theme_color_override("font_color", Color("#a0a5b5"))
	left_vbox.add_child(left_match_label)
	
	var sep1 = ColorRect.new()
	sep1.custom_minimum_size = Vector2(0, 1)
	sep1.color = Color("#222736")
	left_vbox.add_child(sep1)
	
	# Round statistics
	var left_round_box = VBoxContainer.new()
	left_round_box.add_theme_constant_override("separation", 6)
	left_vbox.add_child(left_round_box)
	
	var left_round_title = Label.new()
	left_round_title.text = "ROUND STATUS"
	left_round_title.add_theme_font_size_override("font_size", 12)
	left_round_title.add_theme_color_override("font_color", Color("#8a90a6"))
	left_round_box.add_child(left_round_title)
	
	var left_stats_grid = GridContainer.new()
	left_stats_grid.columns = 2
	left_stats_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_stats_grid.add_theme_constant_override("h_separation", 10)
	left_stats_grid.add_theme_constant_override("v_separation", 4)
	left_round_box.add_child(left_stats_grid)
	
	var left_pts_title = Label.new()
	left_pts_title.text = "Round Pts:"
	left_pts_title.add_theme_font_size_override("font_size", 14)
	left_pts_title.add_theme_color_override("font_color", Color("#a0a5b5"))
	left_pts_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_stats_grid.add_child(left_pts_title)
	
	left_round_label = Label.new()
	left_round_label.text = "0"
	left_round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	left_round_label.add_theme_font_size_override("font_size", 14)
	left_round_label.add_theme_color_override("font_color", Color.WHITE)
	left_stats_grid.add_child(left_round_label)
	
	var left_cap_title = Label.new()
	left_cap_title.text = "Captured:"
	left_cap_title.add_theme_font_size_override("font_size", 14)
	left_cap_title.add_theme_color_override("font_color", Color("#a0a5b5"))
	left_cap_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_stats_grid.add_child(left_cap_title)
	
	left_cells_label = Label.new()
	left_cells_label.text = "0 Cells"
	left_cells_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	left_cells_label.add_theme_font_size_override("font_size", 14)
	left_cells_label.add_theme_color_override("font_color", Color.WHITE)
	left_stats_grid.add_child(left_cells_label)
	
	left_progress = ProgressBar.new()
	left_progress.max_value = 100.0
	left_progress.value = 0.0
	left_progress.show_percentage = true
	left_progress.custom_minimum_size = Vector2(0, 14)
	left_progress.add_theme_font_size_override("font_size", 11)
	
	var sb_bg = StyleBoxFlat.new()
	sb_bg.bg_color = Color("#07090d")
	sb_bg.set_border_width_all(1)
	sb_bg.border_color = Color("#1c2030")
	sb_bg.set_corner_radius_all(3)
	left_progress.add_theme_stylebox_override("background", sb_bg)
	
	var sb_fill = StyleBoxFlat.new()
	sb_fill.bg_color = Color("#ff2a7a")
	sb_fill.set_corner_radius_all(3)
	left_progress.add_theme_stylebox_override("fill", sb_fill)
	left_round_box.add_child(left_progress)
	
	var sep_left_mid = ColorRect.new()
	sep_left_mid.custom_minimum_size = Vector2(0, 1)
	sep_left_mid.color = Color("#222736")
	left_vbox.add_child(sep_left_mid)
	
	# Cores Harvested
	var left_cores_box = VBoxContainer.new()
	left_cores_box.add_theme_constant_override("separation", 6)
	left_vbox.add_child(left_cores_box)
	
	var left_cores_title = Label.new()
	left_cores_title.text = "CORES HARVESTED"
	left_cores_title.add_theme_font_size_override("font_size", 12)
	left_cores_title.add_theme_color_override("font_color", Color("#8a90a6"))
	left_cores_box.add_child(left_cores_title)
	
	var left_grid = GridContainer.new()
	left_grid.columns = 2
	left_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_grid.add_theme_constant_override("h_separation", 10)
	left_grid.add_theme_constant_override("v_separation", 4)
	left_cores_box.add_child(left_grid)
	
	var lbl_cores_t = Label.new()
	lbl_cores_t.text = "⬡ Basic Cores:"
	lbl_cores_t.add_theme_font_size_override("font_size", 14)
	lbl_cores_t.add_theme_color_override("font_color", Color("#39ff14"))
	lbl_cores_t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_grid.add_child(lbl_cores_t)
	
	left_cores_label = Label.new()
	left_cores_label.text = "0"
	left_cores_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	left_cores_label.add_theme_font_size_override("font_size", 14)
	left_cores_label.add_theme_color_override("font_color", Color("#39ff14"))
	left_grid.add_child(left_cores_label)
	
	var lbl_rare_t = Label.new()
	lbl_rare_t.text = "✦ Rare Cores:"
	lbl_rare_t.add_theme_font_size_override("font_size", 14)
	lbl_rare_t.add_theme_color_override("font_color", Color("#ffd700"))
	lbl_rare_t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_grid.add_child(lbl_rare_t)
	
	left_rare_label = Label.new()
	left_rare_label.text = "0"
	left_rare_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	left_rare_label.add_theme_font_size_override("font_size", 14)
	left_rare_label.add_theme_color_override("font_color", Color("#ffd700"))
	left_grid.add_child(left_rare_label)
	
	# Expand spacer
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(spacer)
	
	# Dynamic Controls / Telemetry Box for P1
	if ConfigManager.red_is_ai:
		left_vbox.add_child(create_telemetry_box(1))
	else:
		left_vbox.add_child(create_controls_box(1))
	
	# Right HUD Panel (Blue Player / AI)
	var right_panel = PanelContainer.new()
	right_panel.name = "RightHUD"
	right_panel.position = Vector2(970, 60)
	right_panel.size = Vector2(280, 600)
	right_panel.add_theme_stylebox_override("panel", create_neon_panel(Color("#00f0ff")))
	main_ctrl.add_child(right_panel)
	
	var right_margin = MarginContainer.new()
	right_margin.add_theme_constant_override("margin_left", 20)
	right_margin.add_theme_constant_override("margin_top", 20)
	right_margin.add_theme_constant_override("margin_right", 20)
	right_margin.add_theme_constant_override("margin_bottom", 20)
	right_panel.add_child(right_margin)
	
	var right_vbox = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 12)
	right_margin.add_child(right_vbox)
	
	# Header Label
	var right_header = Label.new()
	if ConfigManager.blue_is_ai:
		right_header.text = "AI 2"
	else:
		right_header.text = "PLAYER 2"
	right_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_header.add_theme_color_override("font_color", Color("#00f0ff"))
	right_header.add_theme_font_size_override("font_size", 22)
	right_vbox.add_child(right_header)
	
	# Match score accumulated
	right_match_label = Label.new()
	right_match_label.text = "MATCH: 0 pts"
	right_match_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_match_label.add_theme_font_size_override("font_size", 16)
	right_match_label.add_theme_color_override("font_color", Color("#a0a5b5"))
	right_vbox.add_child(right_match_label)
	
	var sep2 = ColorRect.new()
	sep2.custom_minimum_size = Vector2(0, 1)
	sep2.color = Color("#222736")
	right_vbox.add_child(sep2)
	
	# Round stats
	var right_round_box = VBoxContainer.new()
	right_round_box.add_theme_constant_override("separation", 6)
	right_vbox.add_child(right_round_box)
	
	var right_round_title = Label.new()
	right_round_title.text = "ROUND STATUS"
	right_round_title.add_theme_font_size_override("font_size", 12)
	right_round_title.add_theme_color_override("font_color", Color("#8a90a6"))
	right_round_box.add_child(right_round_title)
	
	var right_stats_grid = GridContainer.new()
	right_stats_grid.columns = 2
	right_stats_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_stats_grid.add_theme_constant_override("h_separation", 10)
	right_stats_grid.add_theme_constant_override("v_separation", 4)
	right_round_box.add_child(right_stats_grid)
	
	var right_pts_title = Label.new()
	right_pts_title.text = "Round Pts:"
	right_pts_title.add_theme_font_size_override("font_size", 14)
	right_pts_title.add_theme_color_override("font_color", Color("#a0a5b5"))
	right_pts_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_stats_grid.add_child(right_pts_title)
	
	right_round_label = Label.new()
	right_round_label.text = "0"
	right_round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right_round_label.add_theme_font_size_override("font_size", 14)
	right_round_label.add_theme_color_override("font_color", Color.WHITE)
	right_stats_grid.add_child(right_round_label)
	
	var right_cap_title = Label.new()
	right_cap_title.text = "Captured:"
	right_cap_title.add_theme_font_size_override("font_size", 14)
	right_cap_title.add_theme_color_override("font_color", Color("#a0a5b5"))
	right_cap_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_stats_grid.add_child(right_cap_title)
	
	right_cells_label = Label.new()
	right_cells_label.text = "0 Cells"
	right_cells_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right_cells_label.add_theme_font_size_override("font_size", 14)
	right_cells_label.add_theme_color_override("font_color", Color.WHITE)
	right_stats_grid.add_child(right_cells_label)
	
	right_progress = ProgressBar.new()
	right_progress.max_value = 100.0
	right_progress.value = 0.0
	right_progress.show_percentage = true
	right_progress.custom_minimum_size = Vector2(0, 14)
	right_progress.add_theme_font_size_override("font_size", 11)
	
	var sb_bg_blue = StyleBoxFlat.new()
	sb_bg_blue.bg_color = Color("#07090d")
	sb_bg_blue.set_border_width_all(1)
	sb_bg_blue.border_color = Color("#1c2030")
	sb_bg_blue.set_corner_radius_all(3)
	right_progress.add_theme_stylebox_override("background", sb_bg_blue)
	
	var sb_fill_blue = StyleBoxFlat.new()
	sb_fill_blue.bg_color = Color("#00f0ff")
	sb_fill_blue.set_corner_radius_all(3)
	right_progress.add_theme_stylebox_override("fill", sb_fill_blue)
	right_round_box.add_child(right_progress)
	
	var sep_right_mid = ColorRect.new()
	sep_right_mid.custom_minimum_size = Vector2(0, 1)
	sep_right_mid.color = Color("#222736")
	right_vbox.add_child(sep_right_mid)
	
	# Cores Harvested
	var right_cores_box = VBoxContainer.new()
	right_cores_box.add_theme_constant_override("separation", 6)
	right_vbox.add_child(right_cores_box)
	
	var right_cores_title = Label.new()
	right_cores_title.text = "CORES HARVESTED"
	right_cores_title.add_theme_font_size_override("font_size", 12)
	right_cores_title.add_theme_color_override("font_color", Color("#8a90a6"))
	right_cores_box.add_child(right_cores_title)
	
	var right_grid = GridContainer.new()
	right_grid.columns = 2
	right_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_grid.add_theme_constant_override("h_separation", 10)
	right_grid.add_theme_constant_override("v_separation", 4)
	right_cores_box.add_child(right_grid)
	
	var lbl_cores_t2 = Label.new()
	lbl_cores_t2.text = "⬡ Basic Cores:"
	lbl_cores_t2.add_theme_font_size_override("font_size", 14)
	lbl_cores_t2.add_theme_color_override("font_color", Color("#39ff14"))
	lbl_cores_t2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_grid.add_child(lbl_cores_t2)
	
	right_cores_label = Label.new()
	right_cores_label.text = "0"
	right_cores_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right_cores_label.add_theme_font_size_override("font_size", 14)
	right_cores_label.add_theme_color_override("font_color", Color("#39ff14"))
	right_grid.add_child(right_cores_label)
	
	var lbl_rare_t2 = Label.new()
	lbl_rare_t2.text = "✦ Rare Cores:"
	lbl_rare_t2.add_theme_font_size_override("font_size", 14)
	lbl_rare_t2.add_theme_color_override("font_color", Color("#ffd700"))
	lbl_rare_t2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_grid.add_child(lbl_rare_t2)
	
	right_rare_label = Label.new()
	right_rare_label.text = "0"
	right_rare_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right_rare_label.add_theme_font_size_override("font_size", 14)
	right_rare_label.add_theme_color_override("font_color", Color("#ffd700"))
	right_grid.add_child(right_rare_label)
	
	# Expand spacer
	var spacer2 = Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(spacer2)
	
	# Dynamic Controls / Telemetry Box for P2
	if ConfigManager.blue_is_ai:
		right_vbox.add_child(create_telemetry_box(2))
	else:
		right_vbox.add_child(create_controls_box(2))
	
	# Top HUD container - wrapped in a gorgeous floating capsule
	var top_capsule = PanelContainer.new()
	top_capsule.name = "TopHUDCapsule"
	top_capsule.position = Vector2(410, 10)
	top_capsule.size = Vector2(460, 40)
	
	var tc_style = StyleBoxFlat.new()
	tc_style.bg_color = Color("#07090ebd") # 74% opacity deep dark blue-gray
	tc_style.border_color = Color("#222736")
	tc_style.set_border_width_all(1)
	tc_style.corner_radius_top_left = 18
	tc_style.corner_radius_top_right = 18
	tc_style.corner_radius_bottom_left = 18
	tc_style.corner_radius_bottom_right = 18
	tc_style.shadow_color = Color(0, 0, 0, 0.4)
	tc_style.shadow_size = 8
	top_capsule.add_theme_stylebox_override("panel", tc_style)
	main_ctrl.add_child(top_capsule)
	
	var top_margin = MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left", 16)
	top_margin.add_theme_constant_override("margin_right", 16)
	top_margin.add_theme_constant_override("margin_top", 0)
	top_margin.add_theme_constant_override("margin_bottom", 0)
	top_capsule.add_child(top_margin)
	
	var top_hud = HBoxContainer.new()
	top_hud.name = "TopHUD"
	top_hud.alignment = BoxContainer.ALIGNMENT_CENTER
	top_margin.add_child(top_hud)
	
	round_title = Label.new()
	round_title.text = "ROUND 1 of 5"
	round_title.add_theme_font_size_override("font_size", 14)
	round_title.add_theme_color_override("font_color", Color.WHITE)
	top_hud.add_child(round_title)
	
	# Sleek vertical divider
	var v_sep1 = ColorRect.new()
	v_sep1.custom_minimum_size = Vector2(1, 14)
	v_sep1.color = Color("#222736")
	v_sep1.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var space_v1 = Control.new()
	space_v1.custom_minimum_size = Vector2(10, 0)
	top_hud.add_child(space_v1)
	top_hud.add_child(v_sep1)
	var space_v2 = Control.new()
	space_v2.custom_minimum_size = Vector2(10, 0)
	top_hud.add_child(space_v2)
	
	# Round Indicators Layout
	round_indicators = HBoxContainer.new()
	round_indicators.alignment = BoxContainer.ALIGNMENT_CENTER
	round_indicators.add_theme_constant_override("separation", 6)
	top_hud.add_child(round_indicators)
	
	for i in range(ConfigManager.max_rounds):
		var indicator = Label.new()
		indicator.text = "○"
		indicator.add_theme_font_size_override("font_size", 14)
		indicator.add_theme_color_override("font_color", Color("#606575"))
		round_indicators.add_child(indicator)
		
	# Sleek vertical divider
	var v_sep2 = ColorRect.new()
	v_sep2.custom_minimum_size = Vector2(1, 14)
	v_sep2.color = Color("#222736")
	v_sep2.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var space_v3 = Control.new()
	space_v3.custom_minimum_size = Vector2(10, 0)
	top_hud.add_child(space_v3)
	top_hud.add_child(v_sep2)
	var space_v4 = Control.new()
	space_v4.custom_minimum_size = Vector2(10, 0)
	top_hud.add_child(space_v4)
	
	timer_label = Label.new()
	timer_label.text = "00:00"
	timer_label.add_theme_font_size_override("font_size", 18)
	timer_label.add_theme_color_override("font_color", Color("#00f0ff")) # Glowing cyber-cyan
	timer_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	top_hud.add_child(timer_label)

func update_scores(left_match: int, left_round: int, right_match: int, right_round: int) -> void:
	left_match_label.text = "MATCH: %d pts" % left_match
	left_round_label.text = str(left_round)
	right_match_label.text = "MATCH: %d pts" % right_match
	right_round_label.text = str(right_round)

func update_cells(left_cells: int, left_pct: float, right_cells: int, right_pct: float) -> void:
	left_cells_label.text = "%d Cells" % left_cells
	left_progress.value = left_pct
	
	right_cells_label.text = "%d Cells" % right_cells
	right_progress.value = right_pct

func update_cores(left_basic: int, left_rare: int, right_basic: int, right_rare: int) -> void:
	left_cores_label.text = str(left_basic)
	left_rare_label.text = str(left_rare)
	right_cores_label.text = str(right_basic)
	right_rare_label.text = str(right_rare)

func update_round(current_round: int, max_rounds: int, round_history: Array) -> void:
	round_title.text = "ROUND %d of %d" % [current_round, max_rounds]
	
	if round_indicators.get_child_count() != max_rounds:
		for child in round_indicators.get_children():
			child.queue_free()
		for i in range(max_rounds):
			var indicator = Label.new()
			indicator.text = "○"
			indicator.add_theme_font_size_override("font_size", 14)
			indicator.add_theme_color_override("font_color", Color("#606575"))
			round_indicators.add_child(indicator)
	
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

func update_red_ai_telemetry(depth: int, time_ms: float, nodes: int) -> void:
	if red_depth_label != null:
		red_depth_label.text = "%d" % depth
	if red_speed_label != null:
		red_speed_label.text = "%.1f ms" % time_ms
	if red_nodes_label != null:
		red_nodes_label.text = str(nodes) if nodes > 0 else "Idle"

func update_blue_ai_telemetry(depth: int, time_ms: float, nodes: int) -> void:
	if blue_depth_label != null:
		blue_depth_label.text = "%d" % depth
	if blue_speed_label != null:
		blue_speed_label.text = "%.1f ms" % time_ms
	if blue_nodes_label != null:
		blue_nodes_label.text = str(nodes) if nodes > 0 else "Idle"

# For backward compatibility
func update_ai_telemetry(depth: int, time_ms: float, nodes: int) -> void:
	update_blue_ai_telemetry(depth, time_ms, nodes)

func setup_countdown_overlay() -> void:
	countdown_overlay = Control.new()
	countdown_overlay.name = "CountdownOverlay"
	countdown_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	countdown_overlay.visible = false
	
	# Set theme
	var hud_theme = Theme.new()
	hud_theme.default_font = preload("res://assets/fonts/ChakraPetch-Regular.ttf")
	countdown_overlay.theme = hud_theme
	
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
	countdown_label.pivot_offset = Vector2.ZERO # Calculated dynamically before tweens
	vbox.add_child(countdown_label)

func start_round_countdown(round_num: int, callback: Callable) -> void:
	if countdown_overlay == null:
		setup_countdown_overlay()
		
	# Ensure all other overlays are hidden
	if post_round_overlay != null:
		post_round_overlay.visible = false
	if post_game_overlay != null:
		post_game_overlay.visible = false
	if pause_overlay != null:
		pause_overlay.visible = false
		
	countdown_round_label.text = "ROUND %d" % round_num
	countdown_overlay.visible = true
	
	var p_btn = get_node_or_null("MainControl/GameplayPauseButton")
	if p_btn != null:
		p_btn.visible = true
	
	# Wait for layout pass so size is computed
	await get_tree().process_frame
	
	# Play "3" (1.0 second)
	countdown_label.text = "3"
	countdown_label.pivot_offset = countdown_label.size / 2.0
	countdown_label.add_theme_color_override("font_color", Color("#ff2a7a"))
	countdown_label.modulate.a = 0.0
	countdown_label.scale = Vector2(1.5, 1.5)
	var mp = get_node_or_null("/root/MusicPlayer")
	if mp != null:
		mp.play_sfx("countdown_beep")
	var tween1 = create_tween()
	tween1.set_parallel(true)
	tween1.tween_property(countdown_label, "modulate:a", 1.0, 0.2)
	tween1.tween_property(countdown_label, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween1.set_parallel(false)
	tween1.tween_interval(0.4)
	tween1.tween_property(countdown_label, "modulate:a", 0.0, 0.3)
	await get_tree().create_timer(1.0).timeout
	
	# Play "2" (1.0 second)
	countdown_label.text = "2"
	countdown_label.pivot_offset = countdown_label.size / 2.0
	countdown_label.add_theme_color_override("font_color", Color("#ff2a7a"))
	countdown_label.modulate.a = 0.0
	countdown_label.scale = Vector2(1.5, 1.5)
	if mp != null:
		mp.play_sfx("countdown_beep")
	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.tween_property(countdown_label, "modulate:a", 1.0, 0.2)
	tween2.tween_property(countdown_label, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween2.set_parallel(false)
	tween2.tween_interval(0.4)
	tween2.tween_property(countdown_label, "modulate:a", 0.0, 0.3)
	await get_tree().create_timer(1.0).timeout
	
	# Play "1" (1.0 second)
	countdown_label.text = "1"
	countdown_label.pivot_offset = countdown_label.size / 2.0
	countdown_label.add_theme_color_override("font_color", Color("#ff2a7a"))
	countdown_label.modulate.a = 0.0
	countdown_label.scale = Vector2(1.5, 1.5)
	if mp != null:
		mp.play_sfx("countdown_beep")
	var tween3 = create_tween()
	tween3.set_parallel(true)
	tween3.tween_property(countdown_label, "modulate:a", 1.0, 0.2)
	tween3.tween_property(countdown_label, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween3.set_parallel(false)
	tween3.tween_interval(0.4)
	tween3.tween_property(countdown_label, "modulate:a", 0.0, 0.3)
	await get_tree().create_timer(1.0).timeout
	
	# Play "GO!" (0.8 second)
	countdown_label.text = "GO!"
	countdown_label.pivot_offset = countdown_label.size / 2.0
	countdown_label.add_theme_color_override("font_color", Color("#00f0ff"))
	countdown_label.modulate.a = 0.0
	countdown_label.scale = Vector2(1.5, 1.5)
	if mp != null:
		mp.play_sfx("countdown_go")
	var tween4 = create_tween()
	tween4.set_parallel(true)
	tween4.tween_property(countdown_label, "modulate:a", 1.0, 0.15)
	tween4.tween_property(countdown_label, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT)
	tween4.set_parallel(false)
	tween4.tween_interval(0.3)
	tween4.tween_property(countdown_label, "modulate:a", 0.0, 0.3)
	await get_tree().create_timer(0.8).timeout
	
	countdown_overlay.visible = false
	# Reset label modulation back to fully opaque
	countdown_label.modulate.a = 1.0
	callback.call()

func setup_post_round_overlay() -> void:
	post_round_overlay = Control.new()
	post_round_overlay.name = "PostRoundOverlay"
	post_round_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	post_round_overlay.visible = false
	
	# Set theme
	var hud_theme = Theme.new()
	hud_theme.default_font = preload("res://assets/fonts/ChakraPetch-Regular.ttf")
	post_round_overlay.theme = hud_theme
	
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
	# Animate the winner text fading in for drama
	announcement.modulate.a = 0.0
	var a_tween = create_tween()
	a_tween.tween_property(announcement, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT)
	
	# Score Breakdown Panel
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#0c0e14")
	
	# Determine winner-themed glow colors
	var panel_color = Color("#ffaa00") # Gold for Draw
	if winner_type == "RED":
		panel_color = Color("#ff2a7a") # Neon Pink
	elif winner_type == "BLUE":
		panel_color = Color("#00f0ff") # Neon Cyan
		
	panel_style.border_color = panel_color
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(10)
	panel_style.shadow_color = Color(panel_color.r, panel_color.g, panel_color.b, 0.25)
	panel_style.shadow_size = 12
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
	h_p1.text = "AI 1" if ConfigManager.red_is_ai else "PLAYER 1"
	h_p1.add_theme_color_override("font_color", Color("#ff2a7a"))
	h_p1.add_theme_font_size_override("font_size", 16)
	grid.add_child(h_p1)
	
	var h_ai = Label.new()
	h_ai.text = "AI 2" if ConfigManager.blue_is_ai else "PLAYER 2"
	h_ai.add_theme_color_override("font_color", Color("#00f0ff"))
	h_ai.add_theme_font_size_override("font_size", 16)
	grid.add_child(h_ai)
	
	# Rows
	add_breakdown_row(grid, "Captured Cells:", format_breakdown_value(p1_cells), format_breakdown_value(ai_cells))
	add_breakdown_row(grid, "Basic Cores:", format_breakdown_value(p1_basic * 5), format_breakdown_value(ai_basic * 5))
	add_breakdown_row(grid, "Rare Cores:", format_breakdown_value(p1_rare * 10), format_breakdown_value(ai_rare * 10))
	
	var p1_bonus = 50 if winner_type == "RED" else (25 if winner_type == "DRAW" else 0)
	var ai_bonus = 50 if winner_type == "BLUE" else (25 if winner_type == "DRAW" else 0)
	add_breakdown_row(grid, "Round Bonus:", format_breakdown_value(p1_bonus), format_breakdown_value(ai_bonus))
	
	# Visual separator columns before total score row
	for i in range(3):
		var div = ColorRect.new()
		div.custom_minimum_size = Vector2(0, 1)
		div.color = Color("#222736")
		grid.add_child(div)
		
	add_breakdown_row(grid, "Round Total:", "%d pts" % p1_round_pts, "%d pts" % ai_round_pts, true)
	
	var is_ai_vs_ai = ConfigManager.red_is_ai and ConfigManager.blue_is_ai
	var next_lbl = Label.new()
	if is_ai_vs_ai:
		next_lbl.text = "PREPARING NEXT ROUND..."
	else:
		next_lbl.text = "PRESS ANY CONTROL KEY TO START NEXT ROUND\n[ ESCAPE or BACK TO FORFEIT MATCH ]"
	next_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if is_ai_vs_ai:
		next_lbl.add_theme_color_override("font_color", Color("#606575"))
	else:
		next_lbl.add_theme_color_override("font_color", Color("#ffd700")) # gold yellow
	next_lbl.add_theme_font_size_override("font_size", 16)
	vbox.add_child(next_lbl)
	
	post_round_overlay.visible = true
	var p_btn = get_node_or_null("MainControl/GameplayPauseButton")
	if p_btn != null:
		p_btn.visible = false
	
	if is_ai_vs_ai:
		# Wait for 3 seconds, then callback
		await get_tree().create_timer(3.0).timeout
		post_round_overlay.visible = false
		callback.call()
	else:
		# Wait for player input in _unhandled_input
		continue_callback = callback
		waiting_for_continue = false
		# Accidental press protection: Wait 1 second before detecting user inputs
		await get_tree().create_timer(1.0).timeout
		waiting_for_continue = true

func format_breakdown_value(points: int) -> String:
	if points <= 0:
		return "0"
	return "[color=#39ff14]+%d[/color]" % points

func add_breakdown_row(grid: GridContainer, label_text: String, p1_text: String, ai_text: String, bold: bool = false) -> void:
	var lbl = Label.new()
	lbl.text = label_text
	lbl.add_theme_color_override("font_color", Color("#a0a5b5") if not bold else Color.WHITE)
	lbl.add_theme_font_size_override("font_size", 15 if not bold else 17)
	grid.add_child(lbl)
	
	var p1 = RichTextLabel.new()
	p1.bbcode_enabled = true
	p1.text = p1_text
	p1.fit_content = true
	p1.autowrap_mode = TextServer.AUTOWRAP_OFF
	p1.scroll_active = false
	p1.selection_enabled = false
	p1.add_theme_color_override("default_color", Color("#ff2a7a") if bold else Color.WHITE)
	p1.add_theme_font_size_override("normal_font_size", 15 if not bold else 17)
	grid.add_child(p1)
	
	var ai = RichTextLabel.new()
	ai.bbcode_enabled = true
	ai.text = ai_text
	ai.fit_content = true
	ai.autowrap_mode = TextServer.AUTOWRAP_OFF
	ai.scroll_active = false
	ai.selection_enabled = false
	ai.add_theme_color_override("default_color", Color("#00f0ff") if bold else Color.WHITE)
	ai.add_theme_font_size_override("normal_font_size", 15 if not bold else 17)
	grid.add_child(ai)

func setup_post_game_overlay() -> void:
	post_game_overlay = Control.new()
	post_game_overlay.name = "PostGameOverlay"
	post_game_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	post_game_overlay.visible = false
	
	# Set theme
	var hud_theme = Theme.new()
	hud_theme.default_font = preload("res://assets/fonts/ChakraPetch-Regular.ttf")
	post_game_overlay.theme = hud_theme
	
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
	var p1_label = "AI 1" if ConfigManager.red_is_ai else "PLAYER 1"
	var p2_label = "AI 2" if ConfigManager.blue_is_ai else "PLAYER 2"
	scores.text = "%s: %d pts   |   %s: %d pts" % [p1_label, p1_total, p2_label, ai_total]
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
	style_again.border_color = Color("#39ff14") # Matrix Green
	style_again.set_border_width_all(1)
	style_again.set_corner_radius_all(6)
	
	var style_menu = StyleBoxFlat.new()
	style_menu.bg_color = Color("#0c0e14")
	style_menu.border_color = Color("#ff3333") # Neon Red
	style_menu.set_border_width_all(1)
	style_menu.set_corner_radius_all(6)
	
	again_btn.add_theme_stylebox_override("normal", style_again)
	var style_again_focus = style_again.duplicate()
	style_again_focus.shadow_color = Color(0.22, 1.0, 0.08, 0.4) # Green focus shadow
	style_again_focus.shadow_size = 8
	again_btn.add_theme_stylebox_override("hover", style_again_focus)
	again_btn.add_theme_stylebox_override("focus", style_again_focus)
	again_btn.add_theme_color_override("font_color", Color("#39ff14"))
	
	menu_btn.add_theme_stylebox_override("normal", style_menu)
	var style_menu_focus = style_menu.duplicate()
	style_menu_focus.shadow_color = Color(1.0, 0.2, 0.2, 0.4) # Red focus shadow
	style_menu_focus.shadow_size = 8
	menu_btn.add_theme_stylebox_override("hover", style_menu_focus)
	menu_btn.add_theme_stylebox_override("focus", style_menu_focus)
	menu_btn.add_theme_color_override("font_color", Color("#ff3333"))
	
	post_game_overlay.visible = true
	again_btn.grab_focus()
	var p_btn = get_node_or_null("MainControl/GameplayPauseButton")
	if p_btn != null:
		p_btn.visible = false

func setup_pause_overlay() -> void:
	pause_overlay = Control.new()
	pause_overlay.name = "PauseOverlay"
	pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_overlay.visible = false
	
	# Set theme
	var hud_theme = Theme.new()
	hud_theme.default_font = preload("res://assets/fonts/ChakraPetch-Regular.ttf")
	pause_overlay.theme = hud_theme
	
	add_child(pause_overlay)
	
	# Fullscreen dark glass overlay
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.04, 0.06, 0.85)
	pause_overlay.add_child(bg)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 25)
	pause_overlay.add_child(vbox)
	
	var title = Label.new()
	title.text = "GAME PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("#ffd700")) # Gold yellow
	title.add_theme_font_size_override("font_size", 36)
	vbox.add_child(title)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)
	
	# Buttons — wrapped in a styled card panel for a polished look
	var btn_panel = PanelContainer.new()
	btn_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var bp_style = StyleBoxFlat.new()
	bp_style.bg_color = Color("#0c0e14")
	bp_style.border_color = Color("#ffd700") # Gold yellow
	bp_style.set_border_width_all(1)
	bp_style.set_corner_radius_all(10)
	bp_style.content_margin_left = 30
	bp_style.content_margin_right = 30
	bp_style.content_margin_top = 20
	bp_style.content_margin_bottom = 20
	bp_style.shadow_color = Color(1.0, 0.84, 0.0, 0.12) # Gold shadow
	bp_style.shadow_size = 14
	btn_panel.add_theme_stylebox_override("panel", bp_style)
	vbox.add_child(btn_panel)
	
	var btn_vbox = VBoxContainer.new()
	btn_vbox.add_theme_constant_override("separation", 10)
	btn_panel.add_child(btn_vbox)
	
	var resume_btn = Button.new()
	resume_btn.name = "ResumeButton"
	resume_btn.text = "RESUME"
	resume_btn.custom_minimum_size = Vector2(200, 45)
	resume_btn.pressed.connect(func():
		resume_requested.emit()
	)
	btn_vbox.add_child(resume_btn)
	
	var restart_btn = Button.new()
	restart_btn.text = "RESTART MATCH"
	restart_btn.custom_minimum_size = Vector2(200, 45)
	restart_btn.pressed.connect(func():
		pause_overlay.visible = false
		restart_requested.emit()
	)
	btn_vbox.add_child(restart_btn)
	
	var menu_btn = Button.new()
	menu_btn.text = "ABORT TO MENU"
	menu_btn.custom_minimum_size = Vector2(200, 45)
	menu_btn.pressed.connect(func():
		pause_overlay.visible = false
		main_menu_requested.emit()
	)
	btn_vbox.add_child(menu_btn)
	
	# Style buttons
	var style_resume = StyleBoxFlat.new()
	style_resume.bg_color = Color("#0c0e14")
	style_resume.border_color = Color("#39ff14") # Matrix Green
	style_resume.set_border_width_all(1)
	style_resume.set_corner_radius_all(6)
	
	var style_restart = StyleBoxFlat.new()
	style_restart.bg_color = Color("#0c0e14")
	style_restart.border_color = Color("#ff7a00") # Neon Amber
	style_restart.set_border_width_all(1)
	style_restart.set_corner_radius_all(6)
	
	var style_abort = StyleBoxFlat.new()
	style_abort.bg_color = Color("#0c0e14")
	style_abort.border_color = Color("#ff3333") # Neon Red
	style_abort.set_border_width_all(1)
	style_abort.set_corner_radius_all(6)
	
	resume_btn.add_theme_stylebox_override("normal", style_resume)
	var style_resume_focus = style_resume.duplicate()
	style_resume_focus.shadow_color = Color(0.22, 1.0, 0.08, 0.4) # Green focus shadow
	style_resume_focus.shadow_size = 8
	resume_btn.add_theme_stylebox_override("hover", style_resume_focus)
	resume_btn.add_theme_stylebox_override("focus", style_resume_focus)
	resume_btn.add_theme_color_override("font_color", Color("#39ff14"))
	
	restart_btn.add_theme_stylebox_override("normal", style_restart)
	var style_restart_focus = style_restart.duplicate()
	style_restart_focus.shadow_color = Color(1.0, 0.48, 0.0, 0.4) # Amber focus shadow
	style_restart_focus.shadow_size = 8
	restart_btn.add_theme_stylebox_override("hover", style_restart_focus)
	restart_btn.add_theme_stylebox_override("focus", style_restart_focus)
	restart_btn.add_theme_color_override("font_color", Color("#ff7a00"))
	
	menu_btn.add_theme_stylebox_override("normal", style_abort)
	var style_abort_focus = style_abort.duplicate()
	style_abort_focus.shadow_color = Color(1.0, 0.2, 0.2, 0.4) # Red focus shadow
	style_abort_focus.shadow_size = 8
	menu_btn.add_theme_stylebox_override("hover", style_abort_focus)
	menu_btn.add_theme_stylebox_override("focus", style_abort_focus)
	menu_btn.add_theme_color_override("font_color", Color("#ff3333"))

func show_pause_menu() -> void:
	if pause_overlay == null:
		setup_pause_overlay()
	pause_overlay.visible = true
	var resume_btn = pause_overlay.find_child("ResumeButton", true, false)
	if resume_btn != null:
		resume_btn.grab_focus()
	
	var p_btn = get_node_or_null("MainControl/GameplayPauseButton")
	if p_btn != null:
		p_btn.visible = false

func hide_pause_menu() -> void:
	if pause_overlay != null:
		pause_overlay.visible = false
	
	var p_btn = get_node_or_null("MainControl/GameplayPauseButton")
	if p_btn != null:
		p_btn.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if waiting_for_continue:
		if event.is_action_pressed("ui_cancel"):
			var vp = get_viewport()
			if vp != null:
				vp.set_input_as_handled()
			waiting_for_continue = false
			post_round_overlay.visible = false
			main_menu_requested.emit() # Forfeit the match!
			return
			
		if (event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton) and event.is_pressed():
			var vp = get_viewport()
			if vp != null:
				vp.set_input_as_handled()
			waiting_for_continue = false
			post_round_overlay.visible = false
			continue_callback.call()
			return
			
	if pause_overlay != null and pause_overlay.visible:
		if event.is_action_pressed("pause_game") or event.is_action_pressed("ui_cancel"):
			var vp = get_viewport()
			if vp != null:
				vp.set_input_as_handled()
			resume_requested.emit()
			
# Custom Button to draw a borderless glowing pause icon
class GameplayPauseButton extends Button:
	var hud_ref: CanvasLayer
	
	func _init(hud: CanvasLayer) -> void:
		hud_ref = hud
		
	func _ready() -> void:
		custom_minimum_size = Vector2(40, 40)
		size = Vector2(40, 40)
		flat = true
		focus_mode = Control.FOCUS_NONE
		pressed.connect(_on_pressed)
		mouse_entered.connect(queue_redraw)
		mouse_exited.connect(queue_redraw)
		
	func _on_pressed() -> void:
		if hud_ref != null:
			hud_ref.resume_requested.emit()
			
	func _draw() -> void:
		var w = size.x
		var h = size.y
		var hovered = is_hovered()
		
		# Draw background without border
		if hovered:
			draw_rect(Rect2(0, 0, w, h), Color("#ff2a7a", 0.15), true) # Pink background overlay on hover
		else:
			draw_rect(Rect2(0, 0, w, h), Color("#12141c", 0.6), true)
			
		# Icon color is blue (#00f0ff), and pink (#ff2a7a) on hover
		var icon_color = Color("#ff2a7a") if hovered else Color("#00f0ff")
		
		# Draw two pause bars centered inside 40x40 with centered padding
		# Left bar: x = 14, y = 12, w = 4, h = 16 (12px padding top/bottom)
		# Right bar: x = 22, y = 12, w = 4, h = 16
		draw_rect(Rect2(14, 12, 4, 16), icon_color, true)
		draw_rect(Rect2(22, 12, 4, 16), icon_color, true)
