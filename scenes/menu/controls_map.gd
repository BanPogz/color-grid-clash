# controls_map.gd
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
	title.text = "SYSTEM MAPPING: CONTROLS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("#00f0ff")) # Neon cyan
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)
	
	# Neon line separator
	var sep = ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 2)
	sep.color = Color("#ff2a7a") # Pulse pink line
	vbox.add_child(sep)
	
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
	
	# Shared Card Style
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color("#11131c")
	card_style.border_color = Color("#222736")
	card_style.set_border_width_all(1)
	card_style.set_corner_radius_all(8)
	card_style.content_margin_left = 18
	card_style.content_margin_right = 18
	card_style.content_margin_top = 18
	card_style.content_margin_bottom = 18
	card_style.shadow_color = Color(0, 0, 0, 0.3)
	card_style.shadow_size = 5
	
	# --- CARD 1: Keyboard ---
	var kb_card = PanelContainer.new()
	kb_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kb_card.add_theme_stylebox_override("panel", card_style)
	cards_hbox.add_child(kb_card)
	
	var kb_vbox = VBoxContainer.new()
	kb_vbox.add_theme_constant_override("separation", 10)
	kb_card.add_child(kb_vbox)
	
	var kb_title = Label.new()
	kb_title.text = "KEYBOARD MAPPINGS"
	kb_title.add_theme_color_override("font_color", Color("#ff2a7a")) # Neon pink
	kb_title.add_theme_font_size_override("font_size", 14)
	kb_vbox.add_child(kb_title)
	
	var kb_sep = ColorRect.new()
	kb_sep.custom_minimum_size = Vector2(0, 1)
	kb_sep.color = Color("#222736")
	kb_vbox.add_child(kb_sep)
	
	var kb_info = Label.new()
	kb_info.text = "◆ MOVE UP:\n  W or Up Arrow\n\n◆ MOVE DOWN:\n  S or Down Arrow\n\n◆ MOVE LEFT:\n  A or Left Arrow\n\n◆ MOVE RIGHT:\n  D or Right Arrow\n\n◆ PAUSE ACTION:\n  Escape Key"
	kb_info.add_theme_font_size_override("font_size", 12)
	kb_info.add_theme_color_override("font_color", Color("#a0a5b5"))
	kb_info.autowrap_mode = TextServer.AUTOWRAP_WORD
	kb_vbox.add_child(kb_info)
	
	# --- CARD 2: Gamepad ---
	var gp_card = PanelContainer.new()
	gp_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gp_card.add_theme_stylebox_override("panel", card_style)
	cards_hbox.add_child(gp_card)
	
	var gp_vbox = VBoxContainer.new()
	gp_vbox.add_theme_constant_override("separation", 10)
	gp_card.add_child(gp_vbox)
	
	var gp_title = Label.new()
	gp_title.text = "CONTROLLER MAPPINGS"
	gp_title.add_theme_color_override("font_color", Color("#00f0ff")) # Neon cyan
	gp_title.add_theme_font_size_override("font_size", 14)
	gp_vbox.add_child(gp_title)
	
	var gp_sep = ColorRect.new()
	gp_sep.custom_minimum_size = Vector2(0, 1)
	gp_sep.color = Color("#222736")
	gp_vbox.add_child(gp_sep)
	
	var gp_info = Label.new()
	gp_info.text = "◆ STEERING or TURNS:\n  Left Analog Stick\n\n◆ GRID DIRECTIONAL:\n  D-Pad Buttons\n\n◆ PAUSE PROTOCOL:\n  Start Button\n\n◆ GAME NAVIGATION:\n  A or Cross Button\n\n[ FULL JOYPAD INTEGRATION ACTIVE ]"
	gp_info.add_theme_font_size_override("font_size", 12)
	gp_info.add_theme_color_override("font_color", Color("#a0a5b5"))
	gp_info.autowrap_mode = TextServer.AUTOWRAP_WORD
	gp_vbox.add_child(gp_info)
	
	# Subtext footer
	var subtext = Label.new()
	subtext.text = "System: 180-degree quick turns into your own trail are blocked to prevent self-collision crashes."
	subtext.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtext.add_theme_color_override("font_color", Color("#606575"))
	subtext.add_theme_font_size_override("font_size", 11)
	subtext.autowrap_mode = TextServer.AUTOWRAP_WORD
	scroll_vbox.add_child(subtext)

