# controls_map.gd
extends Control

func _ready() -> void:
	var control = self
	
	# Load and apply modern cybernetic theme font
	var theme_font_reg = load("res://assets/fonts/ChakraPetch-Regular.ttf")
	var theme_font_bold = load("res://assets/fonts/ChakraPetch-Bold.ttf")
	if theme_font_reg != null:
		var map_theme = Theme.new()
		map_theme.default_font = theme_font_reg
		control.theme = map_theme
	
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
	title.text = "CONTROLS"
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
	
	# Helper to create key-value control row
	var add_control_row = func(grid: GridContainer, action_name: String, key_bind: String, bullet_color: Color):
		var bullet_lbl = Label.new()
		bullet_lbl.text = ">"
		bullet_lbl.add_theme_color_override("font_color", bullet_color)
		bullet_lbl.add_theme_font_size_override("font_size", 11)
		if theme_font_bold != null:
			bullet_lbl.add_theme_font_override("font", theme_font_bold)
		grid.add_child(bullet_lbl)
		
		var act_lbl = Label.new()
		act_lbl.text = action_name
		act_lbl.add_theme_font_size_override("font_size", 12)
		act_lbl.add_theme_color_override("font_color", Color("#a0a5b5"))
		grid.add_child(act_lbl)
		
		var val_lbl = Label.new()
		val_lbl.text = key_bind
		val_lbl.add_theme_font_size_override("font_size", 12)
		val_lbl.add_theme_color_override("font_color", Color.WHITE)
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		val_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(val_lbl)
	
	# --- CARD 1: Keyboard ---
	var kb_card = PanelContainer.new()
	kb_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var kb_style = StyleBoxFlat.new()
	kb_style.bg_color = Color("#11131c")
	kb_style.border_color = Color("#1d212f")
	kb_style.set_border_width_all(1)
	kb_style.border_width_left = 5
	kb_style.border_color = Color("#ff2a7a") # Pink Left Border Accent
	kb_style.set_corner_radius_all(6)
	kb_style.content_margin_left = 18
	kb_style.content_margin_right = 18
	kb_style.content_margin_top = 15
	kb_style.content_margin_bottom = 15
	kb_style.shadow_color = Color(1.0, 0.16, 0.48, 0.03)
	kb_style.shadow_size = 8
	kb_card.add_theme_stylebox_override("panel", kb_style)
	cards_hbox.add_child(kb_card)
	
	var kb_vbox = VBoxContainer.new()
	kb_vbox.add_theme_constant_override("separation", 10)
	kb_card.add_child(kb_vbox)
	
	var kb_title = Label.new()
	kb_title.text = "KEYBOARD MAPPINGS"
	kb_title.add_theme_color_override("font_color", Color("#ff2a7a")) # Neon pink
	kb_title.add_theme_font_size_override("font_size", 13)
	if theme_font_bold != null:
		kb_title.add_theme_font_override("font", theme_font_bold)
	kb_vbox.add_child(kb_title)
	
	var kb_sep = ColorRect.new()
	kb_sep.custom_minimum_size = Vector2(0, 1)
	kb_sep.color = Color("#1e2230")
	kb_vbox.add_child(kb_sep)
	
	var kb_grid = GridContainer.new()
	kb_grid.columns = 3
	kb_grid.add_theme_constant_override("h_separation", 6)
	kb_grid.add_theme_constant_override("v_separation", 10)
	kb_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kb_vbox.add_child(kb_grid)
	
	add_control_row.call(kb_grid, "MOVE UP", "W or Up Arrow", Color("#ff2a7a"))
	add_control_row.call(kb_grid, "MOVE DOWN", "S or Down Arrow", Color("#ff2a7a"))
	add_control_row.call(kb_grid, "MOVE LEFT", "A or Left Arrow", Color("#ff2a7a"))
	add_control_row.call(kb_grid, "MOVE RIGHT", "D or Right Arrow", Color("#ff2a7a"))
	add_control_row.call(kb_grid, "PAUSE GAME", "Escape Key", Color("#ff2a7a"))
	
	# --- CARD 2: Gamepad ---
	var gp_card = PanelContainer.new()
	gp_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var gp_style = StyleBoxFlat.new()
	gp_style.bg_color = Color("#11131c")
	gp_style.border_color = Color("#1d212f")
	gp_style.set_border_width_all(1)
	gp_style.border_width_left = 5
	gp_style.border_color = Color("#00f0ff") # Cyan Left Border Accent
	gp_style.set_corner_radius_all(6)
	gp_style.content_margin_left = 18
	gp_style.content_margin_right = 18
	gp_style.content_margin_top = 15
	gp_style.content_margin_bottom = 15
	gp_style.shadow_color = Color(0.0, 0.94, 1.0, 0.03)
	gp_style.shadow_size = 8
	gp_card.add_theme_stylebox_override("panel", gp_style)
	cards_hbox.add_child(gp_card)
	
	var gp_vbox = VBoxContainer.new()
	gp_vbox.add_theme_constant_override("separation", 10)
	gp_card.add_child(gp_vbox)
	
	var gp_title = Label.new()
	gp_title.text = "CONTROLLER MAPPINGS"
	gp_title.add_theme_color_override("font_color", Color("#00f0ff")) # Neon cyan
	gp_title.add_theme_font_size_override("font_size", 13)
	if theme_font_bold != null:
		gp_title.add_theme_font_override("font", theme_font_bold)
	gp_vbox.add_child(gp_title)
	
	var gp_sep = ColorRect.new()
	gp_sep.custom_minimum_size = Vector2(0, 1)
	gp_sep.color = Color("#1e2230")
	gp_vbox.add_child(gp_sep)
	
	var gp_grid = GridContainer.new()
	gp_grid.columns = 3
	gp_grid.add_theme_constant_override("h_separation", 6)
	gp_grid.add_theme_constant_override("v_separation", 10)
	gp_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gp_vbox.add_child(gp_grid)
	
	add_control_row.call(gp_grid, "MOVE / STEER", "Left Analog Stick", Color("#00f0ff"))
	add_control_row.call(gp_grid, "GRID D-PAD", "Directional Buttons", Color("#00f0ff"))
	add_control_row.call(gp_grid, "PAUSE GAME", "Start Button", Color("#00f0ff"))
	add_control_row.call(gp_grid, "NAVIGATE", "A / Cross Button", Color("#00f0ff"))
	add_control_row.call(gp_grid, "GAMEPAD STATUS", "Active & Connected", Color("#39ff14"))
	
	# Subtext footer
	var subtext = Label.new()
	subtext.text = "Note: Immediate 180-degree turns are blocked to prevent self-collision."
	subtext.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtext.add_theme_color_override("font_color", Color("#606575"))
	subtext.add_theme_font_size_override("font_size", 11)
	subtext.autowrap_mode = TextServer.AUTOWRAP_WORD
	if theme_font_reg != null:
		subtext.add_theme_font_override("font", theme_font_reg)
	scroll_vbox.add_child(subtext)
