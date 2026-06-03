# stats.gd
extends Control

func _ready() -> void:
	var control = self
	
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
	title.text = "DATALINK: GRID STATISTICS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("#00f0ff")) # Neon cyan
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)
	
	# Separator line
	var sep = ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 2)
	sep.color = Color("#ff2a7a") # Neon pink line
	vbox.add_child(sep)
	
	# Load current stats
	var stats = StatsManager.load_stats()
	
	# Stats Container Card
	var card = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(card)
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color("#11131c")
	card_style.border_color = Color("#222736")
	card_style.set_border_width_all(1)
	card_style.set_corner_radius_all(6)
	card_style.content_margin_left = 20
	card_style.content_margin_right = 20
	card_style.content_margin_top = 15
	card_style.content_margin_bottom = 15
	card.add_theme_stylebox_override("panel", card_style)
	
	# ScrollContainer to prevent overflow if window size varies
	var scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	card.add_child(scroll)
	
	var stats_vbox = VBoxContainer.new()
	stats_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(stats_vbox)
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 40)
	grid.add_theme_constant_override("v_separation", 10)
	stats_vbox.add_child(grid)
	
	add_stat_row(grid, "Total Games Played:", str(stats["games_played"]))
	
	var win_ratio = 0.0
	if stats["games_played"] > 0:
		win_ratio = float(stats["p1_wins"]) / stats["games_played"] * 100.0
	add_stat_row(grid, "Player 1 Wins:", "%d (%.1f%%)" % [stats["p1_wins"], win_ratio])
	
	var ai_ratio = 0.0
	if stats["games_played"] > 0:
		ai_ratio = float(stats["ai_wins"]) / stats["games_played"] * 100.0
	add_stat_row(grid, "AI Wins:", "%d (%.1f%%)" % [stats["ai_wins"], ai_ratio])
	
	add_stat_row(grid, "Match Draws:", str(stats["draws"]))
	add_stat_row(grid, "Total Cores Absorbed:", str(stats["total_cores_eaten"]))
	add_stat_row(grid, "Total Cells Claimed:", str(stats["total_cells_captured"]))
	add_stat_row(grid, "P1 Record Score:", str(stats["p1_max_round_score"]) + " pts")
	add_stat_row(grid, "AI Record Score:", str(stats["ai_max_round_score"]) + " pts")
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	stats_vbox.add_child(spacer)
	
	# Clear stats button
	var clear_btn = Button.new()
	clear_btn.text = "RESET DATABASE"
	clear_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	clear_btn.custom_minimum_size = Vector2(180, 32)
	clear_btn.pressed.connect(_on_reset_pressed)
	stats_vbox.add_child(clear_btn)
	
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

func add_stat_row(grid: GridContainer, label_text: String, value_text: String) -> void:
	var lbl = Label.new()
	lbl.text = label_text
	lbl.add_theme_color_override("font_color", Color("#a0a5b5"))
	lbl.add_theme_font_size_override("font_size", 13)
	grid.add_child(lbl)
	
	var val = Label.new()
	val.text = value_text
	val.add_theme_color_override("font_color", Color.WHITE)
	val.add_theme_font_size_override("font_size", 13)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	val.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(val)

func _on_reset_pressed() -> void:
	StatsManager.save_stats(StatsManager.get_default_stats())
	# Re-enter the statistics panel to reload values
	var main_menu = get_tree().current_scene
	if main_menu and main_menu.has_method("_on_stats_pressed"):
		main_menu._on_stats_pressed()
