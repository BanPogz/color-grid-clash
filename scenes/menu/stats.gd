# stats.gd
extends Control

func _ready() -> void:
	var control = self
	
	# Load and apply modern cybernetic theme font
	var theme_font_reg = load("res://assets/fonts/ChakraPetch-Regular.ttf")
	var theme_font_bold = load("res://assets/fonts/ChakraPetch-Bold.ttf")
	if theme_font_reg != null:
		var stats_theme = Theme.new()
		stats_theme.default_font = theme_font_reg
		control.theme = stats_theme
	
	var main_margin = MarginContainer.new()
	main_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_margin.add_theme_constant_override("margin_left", 20)
	main_margin.add_theme_constant_override("margin_right", 20)
	main_margin.add_theme_constant_override("margin_top", 15)
	main_margin.add_theme_constant_override("margin_bottom", 15)
	control.add_child(main_margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	main_margin.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "RECORDS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color.WHITE) # Neutral white
	title.add_theme_font_size_override("font_size", 20)
	if theme_font_bold != null:
		title.add_theme_font_override("font", theme_font_bold)
	vbox.add_child(title)
	
	# Clean Neutral White Divider
	var div = ColorRect.new()
	div.custom_minimum_size = Vector2(180, 2)
	div.color = Color(1.0, 1.0, 1.0, 0.15) # Subtle white line
	div.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(div)
	
	# Load current stats
	var stats = StatsManager.load_stats()
	
	# Scroll area for cards content
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)
	
	var scroll_vbox = VBoxContainer.new()
	scroll_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_vbox.add_theme_constant_override("separation", 15)
	scroll.add_child(scroll_vbox)
	
	# Cards Container
	var cards_hbox = HBoxContainer.new()
	cards_hbox.add_theme_constant_override("separation", 20)
	cards_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_vbox.add_child(cards_hbox)
	
	# Helper to create key-value stat row
	var add_stat_row = func(grid: GridContainer, label_text: String, value_text: String, bullet_color: Color):
		var bullet_lbl = Label.new()
		bullet_lbl.text = ">"
		bullet_lbl.add_theme_color_override("font_color", bullet_color)
		bullet_lbl.add_theme_font_size_override("font_size", 11)
		if theme_font_bold != null:
			bullet_lbl.add_theme_font_override("font", theme_font_bold)
		grid.add_child(bullet_lbl)
		
		var label_lbl = Label.new()
		label_lbl.text = label_text
		label_lbl.add_theme_font_size_override("font_size", 12)
		label_lbl.add_theme_color_override("font_color", Color("#a0a5b5"))
		grid.add_child(label_lbl)
		
		var value_lbl = Label.new()
		value_lbl.text = value_text
		value_lbl.add_theme_font_size_override("font_size", 12)
		value_lbl.add_theme_color_override("font_color", Color.WHITE)
		value_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(value_lbl)
		
	# --- CARD 1: Match Performance ---
	var match_card = PanelContainer.new()
	match_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var match_style = StyleBoxFlat.new()
	match_style.bg_color = Color("#11131c")
	match_style.border_color = Color("#1d212f")
	match_style.set_border_width_all(1)
	match_style.border_width_left = 5
	match_style.border_color = Color("#ff2a7a") # Pink Border Accent
	match_style.set_corner_radius_all(6)
	match_style.content_margin_left = 18
	match_style.content_margin_right = 18
	match_style.content_margin_top = 15
	match_style.content_margin_bottom = 15
	match_style.shadow_color = Color(1.0, 0.16, 0.48, 0.03)
	match_style.shadow_size = 8
	match_card.add_theme_stylebox_override("panel", match_style)
	cards_hbox.add_child(match_card)
	
	var match_vbox = VBoxContainer.new()
	match_vbox.add_theme_constant_override("separation", 10)
	match_card.add_child(match_vbox)
	
	var match_title = Label.new()
	match_title.text = "MATCH PERFORMANCE"
	match_title.add_theme_color_override("font_color", Color("#ff2a7a")) # Neon pink
	match_title.add_theme_font_size_override("font_size", 13)
	if theme_font_bold != null:
		match_title.add_theme_font_override("font", theme_font_bold)
	match_vbox.add_child(match_title)
	
	var match_sep = ColorRect.new()
	match_sep.custom_minimum_size = Vector2(0, 1)
	match_sep.color = Color("#1e2230")
	match_vbox.add_child(match_sep)
	
	var match_grid = GridContainer.new()
	match_grid.columns = 3
	match_grid.add_theme_constant_override("h_separation", 6)
	match_grid.add_theme_constant_override("v_separation", 10)
	match_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	match_vbox.add_child(match_grid)
	
	var win_ratio = 0.0
	if stats["games_played"] > 0:
		win_ratio = float(stats["p1_wins"]) / stats["games_played"] * 100.0
	var ai_ratio = 0.0
	if stats["games_played"] > 0:
		ai_ratio = float(stats["ai_wins"]) / stats["games_played"] * 100.0
		
	add_stat_row.call(match_grid, "Total Games Played", str(stats["games_played"]), Color("#ff2a7a"))
	add_stat_row.call(match_grid, "Player 1 Wins", "%d (%.1f%%)" % [stats["p1_wins"], win_ratio], Color("#ff2a7a"))
	add_stat_row.call(match_grid, "AI Wins", "%d (%.1f%%)" % [stats["ai_wins"], ai_ratio], Color("#ff2a7a"))
	add_stat_row.call(match_grid, "Match Draws", str(stats["draws"]), Color("#ff2a7a"))
	
	# --- CARD 2: Gameplay Records ---
	var records_card = PanelContainer.new()
	records_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var records_style = StyleBoxFlat.new()
	records_style.bg_color = Color("#11131c")
	records_style.border_color = Color("#1d212f")
	records_style.set_border_width_all(1)
	records_style.border_width_left = 5
	records_style.border_color = Color("#00f0ff") # Cyan Border Accent
	records_style.set_corner_radius_all(6)
	records_style.content_margin_left = 18
	records_style.content_margin_right = 18
	records_style.content_margin_top = 15
	records_style.content_margin_bottom = 15
	records_style.shadow_color = Color(0.0, 0.94, 1.0, 0.03)
	records_style.shadow_size = 8
	records_card.add_theme_stylebox_override("panel", records_style)
	cards_hbox.add_child(records_card)
	
	var records_vbox = VBoxContainer.new()
	records_vbox.add_theme_constant_override("separation", 10)
	records_card.add_child(records_vbox)
	
	var records_title = Label.new()
	records_title.text = "GAMEPLAY RECORDS"
	records_title.add_theme_color_override("font_color", Color("#00f0ff")) # Neon cyan
	records_title.add_theme_font_size_override("font_size", 13)
	if theme_font_bold != null:
		records_title.add_theme_font_override("font", theme_font_bold)
	records_vbox.add_child(records_title)
	
	var records_sep = ColorRect.new()
	records_sep.custom_minimum_size = Vector2(0, 1)
	records_sep.color = Color("#1e2230")
	records_vbox.add_child(records_sep)
	
	var records_grid = GridContainer.new()
	records_grid.columns = 3
	records_grid.add_theme_constant_override("h_separation", 6)
	records_grid.add_theme_constant_override("v_separation", 10)
	records_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	records_vbox.add_child(records_grid)
	
	add_stat_row.call(records_grid, "Total Cores Absorbed", str(stats["total_cores_eaten"]), Color("#00f0ff"))
	add_stat_row.call(records_grid, "Total Cells Claimed", str(stats["total_cells_captured"]), Color("#00f0ff"))
	add_stat_row.call(records_grid, "P1 Record Score", str(stats["p1_max_round_score"]) + " pts", Color("#00f0ff"))
	add_stat_row.call(records_grid, "AI Record Score", str(stats["ai_max_round_score"]) + " pts", Color("#00f0ff"))
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 5)
	scroll_vbox.add_child(spacer)
	
	# Clear stats button centered
	var clear_btn = Button.new()
	clear_btn.text = "RESET RECORDS"
	clear_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	clear_btn.custom_minimum_size = Vector2(180, 32)
	clear_btn.pressed.connect(_on_reset_pressed)
	scroll_vbox.add_child(clear_btn)
	
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color("#220b12")
	style_normal.border_color = Color("#aa0f33")
	style_normal.set_border_width_all(1)
	style_normal.set_corner_radius_all(6)
	style_normal.content_margin_left = 15
	style_normal.content_margin_right = 15
	clear_btn.add_theme_stylebox_override("normal", style_normal)
	
	var style_focus = style_normal.duplicate()
	style_focus.border_color = Color("#ff2a7a")
	style_focus.shadow_color = Color(1.0, 0.16, 0.48, 0.3)
	style_focus.shadow_size = 8
	clear_btn.add_theme_stylebox_override("hover", style_focus)
	clear_btn.add_theme_stylebox_override("focus", style_focus)
	clear_btn.add_theme_color_override("font_color", Color("#ffa0af"))
	clear_btn.add_theme_color_override("font_hover_color", Color.WHITE)
	clear_btn.add_theme_color_override("font_focus_color", Color.WHITE)
	
	if theme_font_reg != null:
		clear_btn.add_theme_font_override("font", theme_font_reg)

func _on_reset_pressed() -> void:
	StatsManager.save_stats(StatsManager.get_default_stats())
	# Re-enter the statistics panel to reload values
	var main_menu = get_tree().current_scene
	if main_menu and main_menu.has_method("_on_stats_pressed"):
		main_menu._on_stats_pressed()
