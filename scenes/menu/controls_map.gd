# controls_map.gd
extends Control

func _ready() -> void:
	var control = self
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 25)
	# Center it inside the panel with padding
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	control.add_child(vbox)
	
	# Add dynamic top spacer
	var top_spacer = Control.new()
	top_spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(top_spacer)
	
	var title = Label.new()
	title.text = "SYSTEM CONTROLS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("#00f0ff")) # Neon cyan
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.add_theme_constant_override("h_separation", 60)
	grid.add_theme_constant_override("v_separation", 15)
	vbox.add_child(grid)
	
	# Keyboard controls
	var keyboard_title = Label.new()
	keyboard_title.text = "KEYBOARD MAPPINGS"
	keyboard_title.add_theme_color_override("font_color", Color("#ff2a7a"))
	keyboard_title.add_theme_font_size_override("font_size", 16)
	grid.add_child(keyboard_title)
	
	var gamepad_title = Label.new()
	gamepad_title.text = "CONTROLLER MAPPINGS"
	gamepad_title.add_theme_color_override("font_color", Color("#ff2a7a"))
	gamepad_title.add_theme_font_size_override("font_size", 16)
	grid.add_child(gamepad_title)
	
	var key_info = Label.new()
	key_info.text = "• MOVE UP: W / Up Arrow\n• MOVE DOWN: S / Down Arrow\n• MOVE LEFT: A / Left Arrow\n• MOVE RIGHT: D / Right Arrow\n\n• PAUSE: Escape"
	key_info.add_theme_font_size_override("font_size", 14)
	key_info.add_theme_color_override("font_color", Color("#a0a5b5"))
	grid.add_child(key_info)
	
	var pad_info = Label.new()
	pad_info.text = "• STEERING: Left Analog Stick\n• DIRECTIONAL: D-Pad buttons\n\n• SYSTEM: Start Button\n\n[ FULL CONTROLLER SUPPORT ACTIVE ]"
	pad_info.add_theme_font_size_override("font_size", 14)
	pad_info.add_theme_color_override("font_color", Color("#a0a5b5"))
	grid.add_child(pad_info)
	
	# Expand spacer
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	var subtext = Label.new()
	subtext.text = "Note: 180-degree quick turns into your own trail are blocked to prevent accidental crashes."
	subtext.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtext.add_theme_color_override("font_color", Color("#606575"))
	subtext.add_theme_font_size_override("font_size", 12)
	vbox.add_child(subtext)
	
	# Add dynamic bottom spacer
	var bottom_spacer = Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(bottom_spacer)
