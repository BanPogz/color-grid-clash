# config_panel.gd
extends Control

func _ready() -> void:
	var control = self
	
	# ScrollContainer to allow scrolling if window size is small
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	control.add_child(scroll)
	
	# MarginContainer for padding
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "SYSTEM CONFIGURATION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("#00f0ff")) # Neon cyan
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)
	
	# GridContainer for parameters
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 40)
	grid.add_theme_constant_override("v_separation", 12)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(grid)
	
	# 1. Player Setup (Game Mode)
	var mode_lbl = create_label("Player Setup Mode:")
	grid.add_child(mode_lbl)
	
	var mode_opt = OptionButton.new()
	mode_opt.add_item("Player vs. AI (Default)", 0)
	mode_opt.add_item("Player vs. Player (PvP)", 1)
	mode_opt.add_item("AI vs. AI (Watch Mode)", 2)
	mode_opt.selected = ConfigManager.player_setup
	mode_opt.item_selected.connect(func(idx): ConfigManager.player_setup = idx)
	style_dropdown(mode_opt)
	grid.add_child(mode_opt)
	
	# 2. Rounds (1-10)
	var rounds_lbl = create_label("Match Rounds:")
	grid.add_child(rounds_lbl)
	
	var rounds_opt = OptionButton.new()
	for i in range(1, 11):
		rounds_opt.add_item("%d Round(s)" % i, i)
	rounds_opt.selected = ConfigManager.max_rounds - 1
	rounds_opt.item_selected.connect(func(idx): ConfigManager.max_rounds = idx + 1)
	style_dropdown(rounds_opt)
	grid.add_child(rounds_opt)
	
	# 3. Speed (Slow = 0.5, Intermediate = 0.1, Fast = 0.05)
	var speed_lbl = create_label("Game Movement Speed:")
	grid.add_child(speed_lbl)
	
	var speed_opt = OptionButton.new()
	speed_opt.add_item("Slow (0.50s ticks)", 0)
	speed_opt.add_item("Intermediate (0.10s ticks)", 1)
	speed_opt.add_item("Fast (0.05s ticks)", 2)
	
	if is_equal_approx(ConfigManager.tick_speed, 0.5):
		speed_opt.selected = 0
	elif is_equal_approx(ConfigManager.tick_speed, 0.1):
		speed_opt.selected = 1
	else:
		speed_opt.selected = 2
		
	speed_opt.item_selected.connect(func(idx):
		if idx == 0:
			ConfigManager.tick_speed = 0.5
		elif idx == 1:
			ConfigManager.tick_speed = 0.1
		else:
			ConfigManager.tick_speed = 0.05
	)
	style_dropdown(speed_opt)
	grid.add_child(speed_opt)
	
	# 4. Timer Mode (Infinite, Limited)
	var timer_lbl = create_label("Clock Mode:")
	grid.add_child(timer_lbl)
	
	var timer_opt = OptionButton.new()
	timer_opt.add_item("Infinite (No Time Limit)", 0)
	timer_opt.add_item("Limited (Countdown)", 1)
	timer_opt.selected = ConfigManager.timer_mode
	style_dropdown(timer_opt)
	grid.add_child(timer_opt)
	
	# 5. Round Duration (Used if Limited)
	var duration_lbl = create_label("Round Time Limit:")
	grid.add_child(duration_lbl)
	
	var duration_opt = OptionButton.new()
	var duration_times = [30, 45, 60, 90, 120, 180]
	for sec in duration_times:
		var mins = sec / 60
		var rem = sec % 60
		if mins > 0:
			if rem > 0:
				duration_opt.add_item("%d min %d sec (%d s)" % [mins, rem, sec], sec)
			else:
				duration_opt.add_item("%d min (%d s)" % [mins, sec], sec)
		else:
			duration_opt.add_item("%d seconds" % sec, sec)
			
	var current_limit = ConfigManager.round_time_limit
	var found_idx = duration_times.find(current_limit)
	if found_idx != -1:
		duration_opt.selected = found_idx
	else:
		duration_opt.selected = 2 # fallback to 60s
		
	duration_opt.item_selected.connect(func(idx):
		ConfigManager.round_time_limit = duration_times[idx]
	)
	style_dropdown(duration_opt)
	grid.add_child(duration_opt)
	
	# Connect visibility / enable state of time limit dropdown dynamically
	timer_opt.item_selected.connect(func(idx):
		ConfigManager.timer_mode = idx
		duration_opt.disabled = idx == 0
		duration_opt.modulate.a = 0.35 if idx == 0 else 1.0
	)
	# Trigger initially
	duration_opt.disabled = ConfigManager.timer_mode == ConfigManager.TimerMode.INFINITE
	duration_opt.modulate.a = 0.35 if ConfigManager.timer_mode == ConfigManager.TimerMode.INFINITE else 1.0
	
	# 6. Wall Density
	var wall_lbl = create_label("Obstacle Wall Density:")
	grid.add_child(wall_lbl)
	
	var wall_opt = OptionButton.new()
	wall_opt.add_item("None (0.00)", 0)
	wall_opt.add_item("Less (0.05 - 0.10)", 1)
	wall_opt.add_item("More (0.11 - 0.20)", 2)
	
	match ConfigManager.wall_density_type:
		"NONE":
			wall_opt.selected = 0
		"LESS":
			wall_opt.selected = 1
		"MORE":
			wall_opt.selected = 2
			
	wall_opt.item_selected.connect(func(idx):
		if idx == 0:
			ConfigManager.wall_density_type = "NONE"
		elif idx == 1:
			ConfigManager.wall_density_type = "LESS"
		else:
			ConfigManager.wall_density_type = "MORE"
	)
	style_dropdown(wall_opt)
	grid.add_child(wall_opt)
	
	# 7. Energy Cores
	var cores_lbl = create_label("Energy Cores count:")
	grid.add_child(cores_lbl)
	
	var cores_opt = OptionButton.new()
	cores_opt.add_item("None (0 cores)", 0)
	cores_opt.add_item("Less (2-3 cores)", 1)
	cores_opt.add_item("More (3-6 cores)", 2)
	
	match ConfigManager.cores_count_type:
		"NONE":
			cores_opt.selected = 0
		"LESS":
			cores_opt.selected = 1
		"MORE":
			cores_opt.selected = 2
			
	cores_opt.item_selected.connect(func(idx):
		if idx == 0:
			ConfigManager.cores_count_type = "NONE"
		elif idx == 1:
			ConfigManager.cores_count_type = "LESS"
		else:
			ConfigManager.cores_count_type = "MORE"
	)
	style_dropdown(cores_opt)
	grid.add_child(cores_opt)
	
	# 8. Flood Fill Enabled
	var flood_lbl = create_label("Enclosure Flood Fill:")
	grid.add_child(flood_lbl)
	
	var flood_opt = OptionButton.new()
	flood_opt.add_item("Enabled (Protocol Active)", 0)
	flood_opt.add_item("Disabled (Canceled)", 1)
	flood_opt.selected = 0 if ConfigManager.flood_fill_enabled else 1
	flood_opt.item_selected.connect(func(idx):
		ConfigManager.flood_fill_enabled = idx == 0
	)
	style_dropdown(flood_opt)
	grid.add_child(flood_opt)
	
	# Setup autofocus on first OptionButton so controller navigation works immediately
	mode_opt.grab_focus()

func create_label(txt: String) -> Label:
	var lbl = Label.new()
	lbl.text = txt
	lbl.add_theme_color_override("font_color", Color("#a0a5b5"))
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return lbl

func style_dropdown(opt: OptionButton) -> void:
	opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color("#12141c")
	style_normal.border_color = Color("#222736")
	style_normal.set_border_width_all(1)
	style_normal.set_corner_radius_all(6)
	style_normal.content_margin_left = 12
	style_normal.content_margin_right = 12
	style_normal.content_margin_top = 6
	style_normal.content_margin_bottom = 6
	
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color("#1a1e2a")
	style_hover.border_color = Color("#00f0ff") # Neon cyan
	style_hover.set_border_width_all(1)
	style_hover.set_corner_radius_all(6)
	style_hover.content_margin_left = 12
	style_hover.content_margin_right = 12
	style_hover.content_margin_top = 6
	style_hover.content_margin_bottom = 6
	style_hover.shadow_color = Color(0, 0.94, 1.0, 0.1)
	style_hover.shadow_size = 6
	
	opt.add_theme_stylebox_override("normal", style_normal)
	opt.add_theme_stylebox_override("hover", style_hover)
	opt.add_theme_stylebox_override("pressed", style_hover)
	opt.add_theme_stylebox_override("focus", style_hover) # Glow on focus!
	opt.add_theme_color_override("font_color", Color("#d0d5e5"))
	opt.add_theme_color_override("font_hover_color", Color.WHITE)
	opt.add_theme_color_override("font_focus_color", Color.WHITE)
