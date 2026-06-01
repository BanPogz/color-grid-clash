# stats.gd
extends Control

func _ready() -> void:
	var control = self
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 15)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	control.add_child(vbox)
	
	# Add dynamic top spacer
	var top_spacer = Control.new()
	top_spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(top_spacer)
	
	var title = Label.new()
	title.text = "DATALINK: GRID STATISTICS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("#00f0ff"))
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)
	
	# Load current stats
	var stats = StatsManager.load_stats()
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.add_theme_constant_override("h_separation", 60)
	grid.add_theme_constant_override("v_separation", 10)
	vbox.add_child(grid)
	
	add_stat_row(grid, "Total Games Played:", str(stats["games_played"]))
	
	var win_ratio = 0.0
	if stats["games_played"] > 0:
		win_ratio = float(stats["p1_wins"]) / stats["games_played"] * 100.0
	add_stat_row(grid, "Player 1 Wins:", "%d (%.1f%%)" % [stats["p1_wins"], win_ratio])
	
	var ai_ratio = 0.0
	if stats["games_played"] > 0:
		ai_ratio = float(stats["ai_wins"]) / stats["games_played"] * 100.0
	add_stat_row(grid, "AI Searcher Wins:", "%d (%.1f%%)" % [stats["ai_wins"], ai_ratio])
	
	add_stat_row(grid, "Match Draws:", str(stats["draws"]))
	add_stat_row(grid, "Total Cores Absorbed:", str(stats["total_cores_eaten"]))
	add_stat_row(grid, "Total Cells Claimed:", str(stats["total_cells_captured"]))
	add_stat_row(grid, "P1 Record Score:", str(stats["p1_max_round_score"]) + " pts")
	add_stat_row(grid, "AI Record Score:", str(stats["ai_max_round_score"]) + " pts")
	
	# Clear stats button
	var clear_btn = Button.new()
	clear_btn.text = "RESET DATABASE"
	clear_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	clear_btn.pressed.connect(_on_reset_pressed)
	
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color("#220b12")
	style_normal.border_color = Color("#aa0f33")
	style_normal.set_border_width_all(1)
	style_normal.set_corner_radius_all(6)
	style_normal.content_margin_left = 12
	style_normal.content_margin_right = 12
	
	clear_btn.add_theme_stylebox_override("normal", style_normal)
	var style_focus = style_normal.duplicate()
	style_focus.shadow_color = Color(1.0, 0.16, 0.48, 0.4)
	style_focus.shadow_size = 8
	clear_btn.add_theme_stylebox_override("hover", style_focus)
	clear_btn.add_theme_stylebox_override("focus", style_focus)
	clear_btn.add_theme_color_override("font_color", Color("#ffa0af"))
	vbox.add_child(clear_btn)
	
	# Add dynamic bottom spacer
	var bottom_spacer = Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(bottom_spacer)

func add_stat_row(grid: GridContainer, label_text: String, value_text: String) -> void:
	var lbl = Label.new()
	lbl.text = label_text
	lbl.add_theme_color_override("font_color", Color("#a0a5b5"))
	lbl.add_theme_font_size_override("font_size", 14)
	grid.add_child(lbl)
	
	var val = Label.new()
	val.text = value_text
	val.add_theme_color_override("font_color", Color.WHITE)
	val.add_theme_font_size_override("font_size", 14)
	grid.add_child(val)

func _on_reset_pressed() -> void:
	StatsManager.save_stats(StatsManager.get_default_stats())
	# Re-enter the statistics panel to reload values
	var main_menu = get_tree().current_scene
	if main_menu and main_menu.has_method("_on_stats_pressed"):
		main_menu._on_stats_pressed()
