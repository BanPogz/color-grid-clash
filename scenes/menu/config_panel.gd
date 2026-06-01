# config_panel.gd
extends Control

var mode_status_lbl: Label

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
	grid.add_theme_constant_override("v_separation", 15)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(grid)
	
	# 1. Player Setup (Two CheckButtons for P1 and P2)
	var mode_lbl = create_label("Player Setup Mode:")
	grid.add_child(mode_lbl)
	
	var mode_box = VBoxContainer.new()
	mode_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mode_box.add_theme_constant_override("separation", 6)
	grid.add_child(mode_box)
	
	var chk_row = HBoxContainer.new()
	chk_row.add_theme_constant_override("separation", 12)
	mode_box.add_child(chk_row)
	
	var red_chk = CheckButton.new()
	red_chk.text = "P1 (Red) AI"
	red_chk.button_pressed = ConfigManager.red_is_ai
	style_checkbutton(red_chk)
	chk_row.add_child(red_chk)
	
	var vs_lbl = Label.new()
	vs_lbl.text = "vs."
	vs_lbl.add_theme_color_override("font_color", Color("#606575"))
	vs_lbl.add_theme_font_size_override("font_size", 14)
	chk_row.add_child(vs_lbl)
	
	var blue_chk = CheckButton.new()
	blue_chk.text = "P2 (Blue) AI"
	blue_chk.button_pressed = ConfigManager.blue_is_ai
	style_checkbutton(blue_chk)
	chk_row.add_child(blue_chk)
	
	mode_status_lbl = Label.new()
	mode_status_lbl.add_theme_color_override("font_color", Color("#00f0ff")) # glowing cyan
	mode_status_lbl.add_theme_font_size_override("font_size", 12)
	mode_box.add_child(mode_status_lbl)
	
	# Connect checkbuttons
	var update_mode_status = func():
		ConfigManager.red_is_ai = red_chk.button_pressed
		ConfigManager.blue_is_ai = blue_chk.button_pressed
		var p1_str = "AI Searcher 1" if ConfigManager.red_is_ai else "Player 1 (WASD)"
		var p2_str = "AI Searcher 2" if ConfigManager.blue_is_ai else "Player 2 (Arrows)"
		mode_status_lbl.text = "Active Protocol: %s vs. %s" % [p1_str.to_upper(), p2_str.to_upper()]
	
	red_chk.toggled.connect(func(pressed): update_mode_status.call())
	blue_chk.toggled.connect(func(pressed): update_mode_status.call())
	update_mode_status.call() # initial call
	
	# 2. Rounds Slider (1-10)
	var format_rounds = func(val):
		return "%d Round(s)" % int(val)
	create_slider_row(
		grid,
		"Match Rounds:",
		1.0, 10.0, 1.0,
		float(ConfigManager.max_rounds),
		func(val): ConfigManager.max_rounds = int(val),
		format_rounds
	)
	
	# 3. Speed Slider (Slow, Intermediate, Fast)
	var speed_idx = 2 # default Fast
	if is_equal_approx(ConfigManager.tick_speed, 0.5):
		speed_idx = 0
	elif is_equal_approx(ConfigManager.tick_speed, 0.1):
		speed_idx = 1
		
	var format_speed = func(val):
		var idx = int(val)
		if idx == 0: return "Slow (0.50s ticks)"
		elif idx == 1: return "Intermediate (0.10s / 100ms ticks)"
		else: return "Fast (0.05s / 50ms ticks)"
		
	create_slider_row(
		grid,
		"Game Movement Speed:",
		0.0, 2.0, 1.0,
		float(speed_idx),
		func(val):
			var idx = int(val)
			if idx == 0: ConfigManager.tick_speed = 0.5
			elif idx == 1: ConfigManager.tick_speed = 0.1
			else: ConfigManager.tick_speed = 0.05,
		format_speed
	)
	
	# 4. Timer / Limit Slider
	var timer_idx = 0 # Default Infinite
	if ConfigManager.timer_mode == ConfigManager.TimerMode.LIMITED:
		var duration_times = [0, 30, 45, 60, 90, 120, 180]
		var found = duration_times.find(ConfigManager.round_time_limit)
		timer_idx = found if found != -1 else 3 # fallback to 60s
		
	var format_timer = func(val):
		var idx = int(val)
		if idx == 0: return "Infinite (No Time Limit)"
		var sec = [0, 30, 45, 60, 90, 120, 180][idx]
		var mins = sec / 60
		var rem = sec % 60
		if mins > 0:
			if rem > 0: return "%d min %d sec (%d s)" % [mins, rem, sec]
			else: return "%d min (%d s)" % [mins, sec]
		return "%d seconds" % sec
		
	create_slider_row(
		grid,
		"Round Time Limit:",
		0.0, 6.0, 1.0,
		float(timer_idx),
		func(val):
			var idx = int(val)
			if idx == 0:
				ConfigManager.timer_mode = ConfigManager.TimerMode.INFINITE
			else:
				ConfigManager.timer_mode = ConfigManager.TimerMode.LIMITED
				ConfigManager.round_time_limit = [0, 30, 45, 60, 90, 120, 180][idx],
		format_timer
	)
	
	# 5. Wall Density Slider
	var wall_idx = 1 # Less default
	match ConfigManager.wall_density_type:
		"NONE": wall_idx = 0
		"LESS": wall_idx = 1
		"MORE": wall_idx = 2
		
	var format_wall = func(val):
		var idx = int(val)
		if idx == 0: return "None (0.00)"
		elif idx == 1: return "Less (0.05 - 0.10)"
		else: return "More (0.11 - 0.20)"
		
	create_slider_row(
		grid,
		"Obstacle Wall Density:",
		0.0, 2.0, 1.0,
		float(wall_idx),
		func(val):
			var idx = int(val)
			if idx == 0: ConfigManager.wall_density_type = "NONE"
			elif idx == 1: ConfigManager.wall_density_type = "LESS"
			else: ConfigManager.wall_density_type = "MORE",
		format_wall
	)
	
	# 6. Energy Cores Slider
	var cores_idx = 1 # Less default
	match ConfigManager.cores_count_type:
		"NONE": cores_idx = 0
		"LESS": cores_idx = 1
		"MORE": cores_idx = 2
		
	var format_cores = func(val):
		var idx = int(val)
		if idx == 0: return "None (0 cores)"
		elif idx == 1: return "Less (2-3 cores simultaneously)"
		else: return "More (3-6 cores simultaneously)"
		
	create_slider_row(
		grid,
		"Energy Cores count:",
		0.0, 2.0, 1.0,
		float(cores_idx),
		func(val):
			var idx = int(val)
			if idx == 0: ConfigManager.cores_count_type = "NONE"
			elif idx == 1: ConfigManager.cores_count_type = "LESS"
			else: ConfigManager.cores_count_type = "MORE",
		format_cores
	)
	
	# 7. Flood Fill Enabled CheckButton
	var flood_lbl = create_label("Enclosure Flood Fill:")
	grid.add_child(flood_lbl)
	
	var flood_chk = CheckButton.new()
	flood_chk.text = "Enabled" if ConfigManager.flood_fill_enabled else "Disabled"
	flood_chk.button_pressed = ConfigManager.flood_fill_enabled
	style_checkbutton(flood_chk)
	grid.add_child(flood_chk)
	
	flood_chk.toggled.connect(func(pressed):
		ConfigManager.flood_fill_enabled = pressed
		flood_chk.text = "Enabled" if pressed else "Disabled"
	)
	
	# Setup autofocus on Red checkbutton so keyboard/controller navigation works immediately
	red_chk.grab_focus()

func create_label(txt: String) -> Label:
	var lbl = Label.new()
	lbl.text = txt
	lbl.add_theme_color_override("font_color", Color("#a0a5b5"))
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return lbl

func create_slider_row(grid: GridContainer, label_text: String, min_val: float, max_val: float, step: float, current_val: float, value_changed_callback: Callable, format_callback: Callable) -> HSlider:
	var lbl = create_label(label_text)
	grid.add_child(lbl)
	
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 15)
	grid.add_child(row)
	
	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.step = step
	slider.value = current_val
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(slider)
	
	var val_lbl = Label.new()
	val_lbl.text = format_callback.call(current_val)
	val_lbl.add_theme_color_override("font_color", Color("#00f0ff")) # Cyan glow text
	val_lbl.add_theme_font_size_override("font_size", 13)
	val_lbl.custom_minimum_size = Vector2(180, 0)
	row.add_child(val_lbl)
	
	slider.value_changed.connect(func(val):
		val_lbl.text = format_callback.call(val)
		value_changed_callback.call(val)
	)
	
	style_slider(slider)
	return slider

func style_checkbutton(chk: CheckButton) -> void:
	chk.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	
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
	
	chk.add_theme_stylebox_override("normal", style_normal)
	chk.add_theme_stylebox_override("hover", style_hover)
	chk.add_theme_stylebox_override("pressed", style_hover)
	chk.add_theme_stylebox_override("focus", style_hover) # Glow on focus!
	chk.add_theme_color_override("font_color", Color("#d0d5e5"))
	chk.add_theme_color_override("font_hover_color", Color.WHITE)
	chk.add_theme_color_override("font_focus_color", Color.WHITE)

func style_slider(slider: HSlider) -> void:
	var track = StyleBoxFlat.new()
	track.bg_color = Color("#141722")
	track.set_border_width_all(1)
	track.border_color = Color("#222736")
	track.corner_radius_top_left = 3
	track.corner_radius_top_right = 3
	track.corner_radius_bottom_left = 3
	track.corner_radius_bottom_right = 3
	track.content_margin_top = 4
	track.content_margin_bottom = 4
	
	var area = StyleBoxFlat.new()
	area.bg_color = Color("#00f0ff") # Cyan track filled glow
	area.corner_radius_top_left = 3
	area.corner_radius_top_right = 3
	area.corner_radius_bottom_left = 3
	area.corner_radius_bottom_right = 3
	
	slider.add_theme_stylebox_override("slider", track)
	slider.add_theme_stylebox_override("grabber_area", area)
	slider.add_theme_stylebox_override("grabber_area_highlight", area)
