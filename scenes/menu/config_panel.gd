# config_panel.gd
extends Control

var mode_status_lbl: Label

func _ready() -> void:
	var control = self
	
	# Load and apply modern cybernetic theme font
	var theme_font = load("res://assets/fonts/ChakraPetch-Regular.ttf")
	var theme_font_bold = load("res://assets/fonts/ChakraPetch-Bold.ttf")
	if theme_font != null:
		var config_theme = Theme.new()
		config_theme.default_font = theme_font
		control.theme = config_theme
	
	# ScrollContainer to allow scrolling if window size is small
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	control.add_child(scroll)
	
	# MarginContainer for padding
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 35)
	margin.add_theme_constant_override("margin_right", 35)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 18)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "SYSTEM CONFIGURATION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color.WHITE) # Neutral white
	title.add_theme_font_size_override("font_size", 20)
	if theme_font_bold != null:
		title.add_theme_font_override("font", theme_font_bold)
	vbox.add_child(title)
	
	# Clean Neutral White Divider
	var sep = ColorRect.new()
	sep.custom_minimum_size = Vector2(180, 2)
	sep.color = Color(1.0, 1.0, 1.0, 0.15) # Subtle white line
	sep.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(sep)
	
	# Helper to create styled cards with left-accent borders
	var create_category_card = func(title_text: String, border_color: Color):
		var panel = PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var card_style = StyleBoxFlat.new()
		card_style.bg_color = Color("#11131c")
		card_style.border_color = Color("#1d212f")
		card_style.set_border_width_all(1)
		card_style.border_width_left = 5
		card_style.border_color = border_color
		card_style.set_corner_radius_all(6)
		card_style.content_margin_left = 18
		card_style.content_margin_right = 18
		card_style.content_margin_top = 14
		card_style.content_margin_bottom = 14
		panel.add_theme_stylebox_override("panel", card_style)
		
		var c_vbox = VBoxContainer.new()
		c_vbox.add_theme_constant_override("separation", 10)
		panel.add_child(c_vbox)
		
		var h_lbl = Label.new()
		h_lbl.text = title_text.to_upper()
		h_lbl.add_theme_color_override("font_color", border_color)
		h_lbl.add_theme_font_size_override("font_size", 13)
		c_vbox.add_child(h_lbl)
		
		# Divider line
		var c_sep = ColorRect.new()
		c_sep.custom_minimum_size = Vector2(0, 1)
		c_sep.color = Color("#1e2230")
		c_vbox.add_child(c_sep)
		
		var c_grid = GridContainer.new()
		c_grid.columns = 2
		c_grid.add_theme_constant_override("h_separation", 25)
		c_grid.add_theme_constant_override("v_separation", 12)
		c_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c_vbox.add_child(c_grid)
		
		return [panel, c_grid]

	# --- CARD 1: GAME MODE & ROUNDS ---
	var card1_res = create_category_card.call("1. Game Mode & Speed Setup", Color.WHITE) # White Accent
	vbox.add_child(card1_res[0])
	var grid1 = card1_res[1]
	
	# 1. Player Setup Mode
	var mode_lbl = create_label("Player Setup Mode:")
	grid1.add_child(mode_lbl)
	
	var mode_box = VBoxContainer.new()
	mode_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mode_box.add_theme_constant_override("separation", 6)
	grid1.add_child(mode_box)
	
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
	mode_status_lbl.add_theme_color_override("font_color", Color("#ffd700")) # Glowing gold
	mode_status_lbl.add_theme_font_size_override("font_size", 12)
	mode_box.add_child(mode_status_lbl)
	
	# Connect checkbuttons
	var update_mode_status = func():
		ConfigManager.red_is_ai = red_chk.button_pressed
		ConfigManager.blue_is_ai = blue_chk.button_pressed
		var p1_str = "AI 1" if ConfigManager.red_is_ai else "Player 1 (WASD)"
		var p2_str = "AI 2" if ConfigManager.blue_is_ai else "Player 2 (Arrows)"
		mode_status_lbl.text = "Matchup: %s vs. %s" % [p1_str.to_upper(), p2_str.to_upper()]
	
	red_chk.toggled.connect(func(pressed): update_mode_status.call())
	blue_chk.toggled.connect(func(pressed): update_mode_status.call())
	update_mode_status.call()
	
	# 2. Rounds Slider
	var format_rounds = func(val):
		return "%d Round(s)" % int(val)
	create_slider_row(
		grid1,
		"Match Rounds:",
		1.0, 10.0, 1.0,
		float(ConfigManager.max_rounds),
		func(val): ConfigManager.max_rounds = int(val),
		format_rounds
	)
	
	# 3. Speed Slider (Slow, Intermediate, Fast with ticks parentheses removed)
	var speed_idx = 1
	if is_equal_approx(ConfigManager.tick_speed, 0.4):
		speed_idx = 0
	elif is_equal_approx(ConfigManager.tick_speed, 0.2):
		speed_idx = 1
	elif is_equal_approx(ConfigManager.tick_speed, 0.1):
		speed_idx = 2
		
	var format_speed = func(val):
		var idx = int(val)
		if idx == 0: return "Slow"
		elif idx == 1: return "Intermediate"
		else: return "Fast"
		
	create_slider_row(
		grid1,
		"Movement Speed:",
		0.0, 2.0, 1.0,
		float(speed_idx),
		func(val):
			var idx = int(val)
			if idx == 0: ConfigManager.tick_speed = 0.4
			elif idx == 1: ConfigManager.tick_speed = 0.2
			else: ConfigManager.tick_speed = 0.1,
		format_speed
	)
	
	# 4. Timer / Limit Slider
	var timer_idx = 0
	if ConfigManager.timer_mode == ConfigManager.TimerMode.LIMITED:
		var duration_times = [0, 30, 45, 60, 90, 120, 180]
		var found = duration_times.find(ConfigManager.round_time_limit)
		timer_idx = found if found != -1 else 3
		
	var format_timer = func(val):
		var idx = int(val)
		if idx == 0: return "Infinite"
		var sec = [0, 30, 45, 60, 90, 120, 180][idx]
		var mins = sec / 60
		var rem = sec % 60
		if mins > 0:
			if rem > 0: return "%d min %d sec" % [mins, rem]
			else: return "%d min" % [mins]
		return "%d seconds" % sec
		
	create_slider_row(
		grid1,
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

	# --- CARD 2: ARENA & grid2 ---
	var card2_res = create_category_card.call("2. Arena & Grid Mechanics", Color.WHITE) # White Accent
	vbox.add_child(card2_res[0])
	var grid2 = card2_res[1]
	
	# 5. Wall Density Slider
	var wall_idx = 1
	match ConfigManager.wall_density_type:
		"NONE": wall_idx = 0
		"LESS": wall_idx = 1
		"MORE": wall_idx = 2
		
	var format_wall = func(val):
		var idx = int(val)
		if idx == 0: return "None"
		elif idx == 1: return "Low"
		else: return "High"
		
	create_slider_row(
		grid2,
		"Wall Density:",
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
	var cores_idx = 1
	match ConfigManager.cores_count_type:
		"NONE": cores_idx = 0
		"LESS": cores_idx = 1
		"MORE": cores_idx = 2
		
	var format_cores = func(val):
		var idx = int(val)
		if idx == 0: return "None"
		elif idx == 1: return "Low (2-3 cores)"
		else: return "High (3-6 cores)"
		
	create_slider_row(
		grid2,
		"Energy Cores:",
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
	var flood_lbl = create_label("Capture Enclosures:")
	grid2.add_child(flood_lbl)
	
	var flood_chk = CheckButton.new()
	flood_chk.text = "Enabled" if ConfigManager.flood_fill_enabled else "Disabled"
	flood_chk.button_pressed = ConfigManager.flood_fill_enabled
	style_checkbutton(flood_chk)
	grid2.add_child(flood_chk)
	
	flood_chk.toggled.connect(func(pressed):
		ConfigManager.flood_fill_enabled = pressed
		flood_chk.text = "Enabled" if pressed else "Disabled"
	)

	# --- CARD 3: AUDIO SYSTEM ---
	var card3_res = create_category_card.call("3. Audio Configuration", Color.WHITE) # White Accent
	vbox.add_child(card3_res[0])
	var grid3 = card3_res[1]
	
	# 8. Background Music CheckButton
	var music_lbl = create_label("Background Music:")
	grid3.add_child(music_lbl)
	
	var music_chk = CheckButton.new()
	music_chk.text = "Enabled" if ConfigManager.music_enabled else "Disabled"
	music_chk.button_pressed = ConfigManager.music_enabled
	style_checkbutton(music_chk)
	grid3.add_child(music_chk)
	
	# 9. Music Volume Slider
	var format_volume = func(val):
		return "%d%%" % int(val * 100.0)
		
	create_slider_row(
		grid3,
		"Music Volume:",
		0.0, 1.0, 0.05,
		ConfigManager.music_volume,
		func(val):
			ConfigManager.music_volume = val
			var mp = get_node_or_null("/root/MusicPlayer")
			if mp != null:
				mp.update_volume(),
		format_volume
	)
	
	music_chk.toggled.connect(func(pressed):
		ConfigManager.music_enabled = pressed
		music_chk.text = "Enabled" if pressed else "Disabled"
		var mp = get_node_or_null("/root/MusicPlayer")
		if mp != null:
			mp.update_volume()
			if pressed:
				mp.play_music()
			else:
				mp.stop_music()
	)
	
	# Setup autofocus on Red checkbutton so keyboard/controller navigation works immediately
	red_chk.grab_focus()


func create_label(txt: String) -> Label:
	var lbl = Label.new()
	lbl.text = txt
	lbl.add_theme_color_override("font_color", Color("#a0a5b5"))
	lbl.add_theme_font_size_override("font_size", 13)
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
	val_lbl.add_theme_color_override("font_color", Color("#ffd700")) # Yellow text
	val_lbl.add_theme_font_size_override("font_size", 13)
	val_lbl.custom_minimum_size = Vector2(120, 0)
	row.add_child(val_lbl)
	
	slider.value_changed.connect(func(val):
		val_lbl.text = format_callback.call(val)
		value_changed_callback.call(val)
	)
	
	style_slider(slider)
	return slider

func style_checkbutton(chk: CheckButton) -> void:
	chk.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	
	# Style for OFF state (unpressed, unhovered)
	var style_off = StyleBoxFlat.new()
	style_off.bg_color = Color("#12141c")
	style_off.border_color = Color("#222736") # Gray border when off
	style_off.set_border_width_all(1)
	style_off.set_corner_radius_all(6)
	style_off.content_margin_left = 12
	style_off.content_margin_right = 12
	style_off.content_margin_top = 6
	style_off.content_margin_bottom = 6
	
	# Style for OFF state when hovered/focused
	var style_off_hover = StyleBoxFlat.new()
	style_off_hover.bg_color = Color("#1a1e2a")
	style_off_hover.border_color = Color("#3a3f50") # Lighter gray border when off
	style_off_hover.set_border_width_all(1)
	style_off_hover.set_corner_radius_all(6)
	style_off_hover.content_margin_left = 12
	style_off_hover.content_margin_right = 12
	style_off_hover.content_margin_top = 6
	style_off_hover.content_margin_bottom = 6
	style_off_hover.shadow_color = Color(0, 0, 0, 0.15) # Dark neutral shadow
	style_off_hover.shadow_size = 6
	
	# Style for ON state (pressed, unhovered)
	var style_on = StyleBoxFlat.new()
	style_on.bg_color = Color("#12141c")
	style_on.border_color = Color("#ffd700") # Yellow border when on
	style_on.set_border_width_all(1)
	style_on.set_corner_radius_all(6)
	style_on.content_margin_left = 12
	style_on.content_margin_right = 12
	style_on.content_margin_top = 6
	style_on.content_margin_bottom = 6
	
	# Style for ON state when hovered/focused
	var style_on_hover = StyleBoxFlat.new()
	style_on_hover.bg_color = Color("#1a1e2a")
	style_on_hover.border_color = Color("#ffd700") # Yellow border when on
	style_on_hover.set_border_width_all(1)
	style_on_hover.set_corner_radius_all(6)
	style_on_hover.content_margin_left = 12
	style_on_hover.content_margin_right = 12
	style_on_hover.content_margin_top = 6
	style_on_hover.content_margin_bottom = 6
	style_on_hover.shadow_color = Color(1.0, 0.84, 0.0, 0.12) # Yellow glow
	style_on_hover.shadow_size = 6
	
	chk.add_theme_stylebox_override("normal", style_off)
	chk.add_theme_stylebox_override("hover", style_off_hover)
	chk.add_theme_stylebox_override("pressed", style_on)
	chk.add_theme_stylebox_override("hover_pressed", style_on_hover)
	
	# Focus style overlays a yellow border
	var style_focus = StyleBoxFlat.new()
	style_focus.bg_color = Color.TRANSPARENT
	style_focus.draw_center = false
	style_focus.border_color = Color("#ffd700") # Yellow focus outline
	style_focus.set_border_width_all(1)
	style_focus.set_corner_radius_all(6)
	style_focus.content_margin_left = 12
	style_focus.content_margin_right = 12
	style_focus.content_margin_top = 6
	style_focus.content_margin_bottom = 6
	chk.add_theme_stylebox_override("focus", style_focus)
	
	chk.add_theme_color_override("font_color", Color("#a0a5b5")) # Gray when OFF
	chk.add_theme_color_override("font_hover_color", Color.WHITE)
	chk.add_theme_color_override("font_focus_color", Color.WHITE)
	chk.add_theme_color_override("font_pressed_color", Color("#ffd700")) # Yellow when ON
	chk.add_theme_color_override("font_hover_pressed_color", Color("#ffd700")) # Yellow when ON (hovered)

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
	area.bg_color = Color("#ffd700") # Yellow track filled glow
	area.corner_radius_top_left = 3
	area.corner_radius_top_right = 3
	area.corner_radius_bottom_left = 3
	area.corner_radius_bottom_right = 3
	
	var style_focus = StyleBoxFlat.new()
	style_focus.bg_color = Color.TRANSPARENT
	style_focus.draw_center = false
	style_focus.border_color = Color("#ffd700") # Yellow outline on focus
	style_focus.set_border_width_all(1)
	style_focus.set_corner_radius_all(4)
	style_focus.content_margin_left = 4
	style_focus.content_margin_right = 4
	style_focus.content_margin_top = 4
	style_focus.content_margin_bottom = 4
	
	slider.add_theme_stylebox_override("slider", track)
	slider.add_theme_stylebox_override("grabber_area", area)
	slider.add_theme_stylebox_override("grabber_area_highlight", area)
	slider.add_theme_stylebox_override("focus", style_focus)
