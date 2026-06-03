# main_menu.gd
extends CanvasLayer

@onready var display_panel = $DisplayPanel
@onready var start_button = $Control/Panel/VBoxContainer/StartButton
@onready var controls_button = $Control/Panel/VBoxContainer/ControlsButton
@onready var rules_button = $Control/Panel/VBoxContainer/RulesButton
@onready var stats_button = $Control/Panel/VBoxContainer/StatsButton
@onready var quit_button = $Control/Panel/VBoxContainer/QuitButton
@onready var config_button = $Control/Panel/VBoxContainer/ConfigButton
@onready var ai_demo_button = $Control/Panel/VBoxContainer/AIdemo

var credits_button: Button = null
var controls_scene = preload("res://scenes/menu/controls_map.tscn")
var rules_scene = preload("res://scenes/menu/rules_and_mechanics.tscn")
var stats_scene = preload("res://scenes/menu/stats.tscn")
var config_scene = preload("res://scenes/menu/config_panel.tscn")
var quit_scene = preload("res://scenes/menu/quit.tscn")

func _ready() -> void:
	# Play the relaxing retro menu background music loop
	var mp = get_node_or_null("/root/MusicPlayer")
	if mp != null:
		mp.play_menu_music()

	# Ensure VBoxContainer has a decent, wide structure for correct button dimensions
	var vbox = get_node_or_null("Control/Panel/VBoxContainer")
	
	# Create and style Credits button programmatically before adding to layout
	credits_button = Button.new()
	credits_button.name = "CreditsButton"
	credits_button.text = "PROJECT CREDITS"
	credits_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	credits_button.custom_minimum_size = Vector2(0, 35)
	
	var default_font = quit_button.get_theme_font("font")
	if default_font != null:
		credits_button.add_theme_font_override("font", default_font)
	credits_button.add_theme_font_size_override("font_size", 24)

	if vbox != null:
		vbox.size.x = 360 # Custom expanded width to fit all button text cleanly
		vbox.add_theme_constant_override("separation", 12) # Clean spacing between items
		vbox.add_child(credits_button)
		# Move right before the QuitButton
		var quit_idx = quit_button.get_index()
		vbox.move_child(credits_button, quit_idx)

	# Ensure existing button texts are structured perfectly
	rules_button.text = "RULES & MECHANICS"
	rules_button.custom_minimum_size = Vector2(0, 35)
	stats_button.text = "RECORDS"
	stats_button.custom_minimum_size = Vector2(0, 35)
	config_button.text = "CONFIGURATION"
	config_button.custom_minimum_size = Vector2(0, 35) # match other buttons
	ai_demo_button.text = "AI VISUAL DEMO"
	ai_demo_button.custom_minimum_size = Vector2(0, 35)

	# Add the dynamic live cybernetic background snake animation behind all UI
	var panel = get_node_or_null("Control/Panel")
	if panel != null:
		var visualizer = MenuBackgroundVisualizer.new()
		panel.add_child(visualizer)
		panel.move_child(visualizer, 0) # Force to be drawn behind all menu controls!
	
	start_button.pressed.connect(_on_start_pressed)
	controls_button.pressed.connect(_on_controls_pressed)
	rules_button.pressed.connect(_on_rules_pressed)
	stats_button.pressed.connect(_on_stats_pressed)
	config_button.pressed.connect(_on_config_pressed)
	ai_demo_button.pressed.connect(_on_ai_demo_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Apply gorgeous neon theme styling programmatically
	setup_styling()
	
	# Wire up button hover scale animations
	var btn_list = [start_button, controls_button, rules_button, stats_button, config_button, ai_demo_button, credits_button, quit_button]
	for btn in btn_list:
		if btn != null:
			animate_button(btn)
	
	# Show rules or default welcome screen in the display panel
	show_welcome_screen()
	
	# Grab focus initially for controller/keyboard navigation support
	start_button.grab_focus()
	
	# Animate COLOR GRID CLASH title shadow glow back and forth between blue and pink (flashing, no fade)
	var title_lbl = get_node_or_null("Control/Panel/PanelContainer/Label")
	if title_lbl != null and title_lbl.label_settings != null:
		title_lbl.label_settings = title_lbl.label_settings.duplicate()
		
		var title_tween = create_tween().set_loops()
		var pink_glow = Color(1.0, 0.165, 0.475, 0.35)
		var blue_glow = Color(0.0, 0.941, 1.0, 0.35)
		
		# Flash instantly on 0.5s intervals
		title_tween.tween_callback(func(): title_lbl.label_settings.shadow_color = pink_glow)
		title_tween.tween_interval(0.5)
		title_tween.tween_callback(func(): title_lbl.label_settings.shadow_color = blue_glow)
		title_tween.tween_interval(0.5)


func setup_styling() -> void:
	# Main menu panel styling
	var menu_style = StyleBoxFlat.new()
	menu_style.bg_color = Color("#07090e")
	$Control/Panel.add_theme_stylebox_override("panel", menu_style)
	
	# Display panel styling
	var display_style = StyleBoxFlat.new()
	display_style.bg_color = Color("#0c0e14")
	display_style.set_border_width_all(0) # Border drawn by children overlay panels!
	display_style.corner_radius_top_left = 10
	display_style.corner_radius_top_right = 10
	display_style.corner_radius_bottom_left = 10
	display_style.corner_radius_bottom_right = 10
	display_style.shadow_color = Color(1.0, 1.0, 1.0, 0.15) # Neon White shadow
	display_style.shadow_size = 15
	display_panel.add_theme_stylebox_override("panel", display_style)
	
	# Create and style the split neon pink/cyan border overlay panels
	var pink_border = display_panel.get_node_or_null("PinkBorderPanel")
	if pink_border == null:
		pink_border = Panel.new()
		pink_border.name = "PinkBorderPanel"
		pink_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		display_panel.add_child(pink_border)
		
	pink_border.anchor_left = 0.0
	pink_border.anchor_top = 0.0
	pink_border.anchor_right = 0.5
	pink_border.anchor_bottom = 1.0
	pink_border.offset_left = 0
	pink_border.offset_top = 0
	pink_border.offset_right = 0
	pink_border.offset_bottom = 0
		
	var pink_style = StyleBoxFlat.new()
	pink_style.bg_color = Color.TRANSPARENT
	pink_style.border_color = Color("#ff2a7a") # Neon Pink (left half)
	pink_style.border_width_left = 2
	pink_style.border_width_top = 2
	pink_style.border_width_right = 0
	pink_style.border_width_bottom = 2
	pink_style.corner_radius_top_left = 10
	pink_style.corner_radius_top_right = 0
	pink_style.corner_radius_bottom_left = 10
	pink_style.corner_radius_bottom_right = 0
	pink_border.add_theme_stylebox_override("panel", pink_style)
	
	var blue_border = display_panel.get_node_or_null("BlueBorderPanel")
	if blue_border == null:
		blue_border = Panel.new()
		blue_border.name = "BlueBorderPanel"
		blue_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		display_panel.add_child(blue_border)
		
	blue_border.anchor_left = 0.5
	blue_border.anchor_top = 0.0
	blue_border.anchor_right = 1.0
	blue_border.anchor_bottom = 1.0
	blue_border.offset_left = 0
	blue_border.offset_top = 0
	blue_border.offset_right = 0
	blue_border.offset_bottom = 0
		
	var blue_style = StyleBoxFlat.new()
	blue_style.bg_color = Color.TRANSPARENT
	blue_style.border_color = Color("#00f0ff") # Neon Cyan (right half)
	blue_style.border_width_left = 0
	blue_style.border_width_top = 2
	blue_style.border_width_right = 2
	blue_style.border_width_bottom = 2
	blue_style.corner_radius_top_left = 0
	blue_style.corner_radius_top_right = 10
	blue_style.corner_radius_bottom_left = 0
	blue_style.corner_radius_bottom_right = 10
	blue_border.add_theme_stylebox_override("panel", blue_style)
	
	# Style buttons
	var buttons = [start_button, controls_button, rules_button, stats_button, config_button, ai_demo_button, credits_button, quit_button]
	for btn in buttons:
		if btn == null: continue
		# Cybernetic buttons
		var btn_normal = StyleBoxFlat.new()
		btn_normal.bg_color = Color("#12141c")
		btn_normal.border_color = Color("#222736")
		btn_normal.set_border_width_all(1)
		btn_normal.set_corner_radius_all(6)
		btn_normal.content_margin_left = 15
		btn_normal.content_margin_top = 8
		btn_normal.content_margin_bottom = 8
		
		var btn_hover = StyleBoxFlat.new()
		btn_hover.bg_color = Color("#1a1e2a")
		btn_hover.border_color = Color("#00f0ff") # Neon cyan glow
		btn_hover.set_border_width_all(1)
		btn_hover.set_corner_radius_all(6)
		btn_hover.content_margin_left = 22 # Subtle responsive slide-to-right on hover/focus!
		btn_hover.content_margin_top = 8
		btn_hover.content_margin_bottom = 8
		btn_hover.shadow_color = Color(0, 0.94, 1.0, 0.1)
		btn_hover.shadow_size = 8
		
		var btn_pressed = btn_hover.duplicate()
		btn_pressed.border_color = Color("#ff2a7a") # Neon pink border on press
		btn_pressed.shadow_color = Color(1.0, 0.16, 0.48, 0.1) # Neon pink shadow on press
		
		btn.add_theme_stylebox_override("normal", btn_normal)
		btn.add_theme_stylebox_override("hover", btn_hover)
		btn.add_theme_stylebox_override("pressed", btn_pressed)
		btn.add_theme_stylebox_override("focus", btn_hover) # Glow on focus!
		btn.add_theme_color_override("font_color", Color("#a0a5b5"))
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_color_override("font_focus_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", Color("#ff2a7a"))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var active_child = display_panel.get_child(0) if display_panel.get_child_count() > 0 else null
		if active_child != null and active_child.name != "WelcomeScreen":
			show_welcome_screen()
			if active_child.name == "ControlsMap":
				controls_button.grab_focus()
			elif active_child.name == "RulesAndMechanics":
				rules_button.grab_focus()
			elif active_child.name == "StatsPanel":
				stats_button.grab_focus()
			elif active_child.name == "ConfigPanel":
				config_button.grab_focus()
			elif active_child.name == "CreditsPanel":
				credits_button.grab_focus()
			elif active_child.name == "QuitPanel":
				quit_button.grab_focus()
			else:
				start_button.grab_focus()
		else:
			# Welcome screen Back key navigates to Quit panel
			_on_quit_pressed()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_panel.tscn")

func _on_controls_pressed() -> void:
	var inst = controls_scene.instantiate()
	inst.name = "ControlsMap"
	set_display_content(inst)

func _on_rules_pressed() -> void:
	var inst = rules_scene.instantiate()
	inst.name = "RulesAndMechanics"
	set_display_content(inst)

func _on_stats_pressed() -> void:
	var inst = stats_scene.instantiate()
	inst.name = "StatsPanel"
	set_display_content(inst)

func _on_config_pressed() -> void:
	var inst = config_scene.instantiate()
	inst.name = "ConfigPanel"
	set_display_content(inst)

func _on_ai_demo_pressed() -> void:
	var font_reg = load("res://assets/fonts/ChakraPetch-Regular.ttf")
	var font_bold = load("res://assets/fonts/ChakraPetch-Bold.ttf")

	var demo_select = VBoxContainer.new()
	demo_select.name = "DemoSelectPanel"
	demo_select.add_theme_constant_override("separation", 15)
	
	var title = Label.new()
	title.text = "AI VISUAL DEMO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color.WHITE) # Neutral white
	title.add_theme_font_size_override("font_size", 20)
	if font_bold != null:
		title.add_theme_font_override("font", font_bold)
	demo_select.add_child(title)
	
	# Clean Neutral White Divider
	var div = ColorRect.new()
	div.custom_minimum_size = Vector2(180, 2)
	div.color = Color(1.0, 1.0, 1.0, 0.15) # Subtle white line
	div.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	demo_select.add_child(div)
	
	# Styled Card Container
	var card = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color("#11131c")
	card_style.border_color = Color("#1d212f") # Subtle slate gray border
	card_style.set_border_width_all(1)
	card_style.set_corner_radius_all(6)
	card_style.content_margin_left = 20
	card_style.content_margin_right = 20
	card_style.content_margin_top = 15
	card_style.content_margin_bottom = 15
	card_style.shadow_color = Color(0, 0, 0, 0.2) # Deep neutral drop shadow
	card_style.shadow_size = 10
	card.add_theme_stylebox_override("panel", card_style)
	demo_select.add_child(card)
	
	var card_vbox = VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 12)
	card_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(card_vbox)
	
	var desc = Label.new()
	desc.text = "Experience step-by-step minimax search and heuristics visualizers."
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_color_override("font_color", Color("#a0a5b5"))
	desc.add_theme_font_size_override("font_size", 12)
	if font_reg != null:
		desc.add_theme_font_override("font", font_reg)
	card_vbox.add_child(desc)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 5)
	card_vbox.add_child(spacer)
	
	var btn_realtime = Button.new()
	btn_realtime.text = "REAL-TIME WATCH MODE\nWatch the AI play at normal speed."
	style_demo_selector_btn(btn_realtime)
	btn_realtime.pressed.connect(func(): start_ai_demo(ConfigManager.DemoMode.REAL_TIME))
	card_vbox.add_child(btn_realtime)
	
	var btn_slowmo = Button.new()
	btn_slowmo.text = "SLOW MOTION MODE\nAutomatically step through search execution."
	style_demo_selector_btn(btn_slowmo)
	btn_slowmo.pressed.connect(func(): start_ai_demo(ConfigManager.DemoMode.SLOW_MOTION))
	card_vbox.add_child(btn_slowmo)
	
	var btn_step = Button.new()
	btn_step.text = "STEP-BY-STEP MODE\nManually control code stepping using controls."
	style_demo_selector_btn(btn_step)
	btn_step.pressed.connect(func(): start_ai_demo(ConfigManager.DemoMode.LINE_BY_LINE))
	card_vbox.add_child(btn_step)
	
	set_display_content(demo_select)
	btn_step.grab_focus() # Focus the line-by-line mode initially for convenience!

func start_ai_demo(mode: int) -> void:
	ConfigManager.is_in_demo = true
	ConfigManager.active_demo_mode = mode
	
	# Override settings for the demo: AI vs. AI watch-mode, 1-10 rounds (set config is kept)
	ConfigManager.red_is_ai = true
	ConfigManager.blue_is_ai = true
	
	get_tree().change_scene_to_file("res://scenes/menu/ai_demo_panel.tscn")

func style_demo_selector_btn(btn: Button) -> void:
	btn.custom_minimum_size = Vector2(500, 50)
	
	var font_reg = load("res://assets/fonts/ChakraPetch-Regular.ttf")
	if font_reg != null:
		btn.add_theme_font_override("font", font_reg)
	
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color("#12141c")
	btn_normal.border_color = Color("#222736")
	btn_normal.set_border_width_all(1)
	btn_normal.set_corner_radius_all(6)
	btn_normal.content_margin_left = 15
	btn_normal.content_margin_top = 10
	btn_normal.content_margin_bottom = 10
	
	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color("#1a1e2a")
	btn_hover.border_color = Color("#00f0ff") # Neon cyan glow
	btn_hover.set_border_width_all(1)
	btn_hover.set_corner_radius_all(6)
	btn_hover.content_margin_left = 22 # Subtle responsive slide-to-right on hover/focus!
	btn_hover.content_margin_top = 10
	btn_hover.content_margin_bottom = 10
	btn_hover.shadow_color = Color(0, 0.94, 1.0, 0.15)
	btn_hover.shadow_size = 8
	
	btn.add_theme_stylebox_override("normal", btn_normal)
	btn.add_theme_stylebox_override("hover", btn_hover)
	btn.add_theme_stylebox_override("pressed", btn_hover)
	btn.add_theme_stylebox_override("focus", btn_hover) # Glow on focus!
	btn.add_theme_color_override("font_color", Color("#d0d5e5"))
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_focus_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color("#00f0ff"))
	btn.add_theme_font_size_override("font_size", 12)


func _on_quit_pressed() -> void:
	var quit_inst = quit_scene.instantiate()
	quit_inst.name = "QuitPanel"
	set_display_content(quit_inst)
	# Connect signals from the quit scene
	var yes_btn = quit_inst.find_child("YesButton", true, false)
	var no_btn = quit_inst.find_child("NoButton", true, false)
	if yes_btn:
		yes_btn.pressed.connect(func(): get_tree().quit())
	if no_btn:
		no_btn.pressed.connect(_on_quit_cancelled)
		no_btn.grab_focus() # Focus NO button by default for safety!

func _on_quit_cancelled() -> void:
	show_welcome_screen()
	quit_button.grab_focus() # Refocus the quit button on cancel

func _on_credits_pressed() -> void:
	var font_reg = load("res://assets/fonts/ChakraPetch-Regular.ttf")
	var font_bold = load("res://assets/fonts/ChakraPetch-Bold.ttf")

	var credits_panel_node = VBoxContainer.new()
	credits_panel_node.name = "CreditsPanel"
	credits_panel_node.add_theme_constant_override("separation", 15)
	
	var title = Label.new()
	title.text = "PROJECT CREDITS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color.WHITE) # Neutral white
	title.add_theme_font_size_override("font_size", 20)
	if font_bold != null:
		title.add_theme_font_override("font", font_bold)
	credits_panel_node.add_child(title)
	
	# Clean Neutral White Divider
	var div = ColorRect.new()
	div.custom_minimum_size = Vector2(180, 2)
	div.color = Color(1.0, 1.0, 1.0, 0.15) # Subtle white line
	div.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	credits_panel_node.add_child(div)
	
	# Styled Card Container (Clean Neutral Styling)
	var card = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color("#11131c")
	card_style.border_color = Color("#1d212f") # Subtle slate gray border
	card_style.set_border_width_all(1)
	card_style.set_corner_radius_all(6)
	card_style.content_margin_left = 18
	card_style.content_margin_right = 18
	card_style.content_margin_top = 18
	card_style.content_margin_bottom = 18
	card_style.shadow_color = Color(0, 0, 0, 0.2) # Deep neutral drop shadow
	card_style.shadow_size = 10
	card.add_theme_stylebox_override("panel", card_style)
	credits_panel_node.add_child(card)
	
	# ScrollContainer to hold details and prevent any potential text cutoff
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	card.add_child(scroll)
	
	var rtl = RichTextLabel.new()
	rtl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rtl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rtl.bbcode_enabled = true
	rtl.fit_content = true
	
	if font_reg != null:
		rtl.add_theme_font_override("normal_font", font_reg)
		rtl.add_theme_font_override("bold_font", font_bold if font_bold != null else font_reg)
		rtl.add_theme_font_override("italics_font", font_reg)
		
	rtl.add_theme_font_size_override("normal_font_size", 12)
	rtl.add_theme_font_size_override("bold_font_size", 12)
	rtl.add_theme_font_size_override("italics_font_size", 12)
	
	var bb_text = ""
	bb_text += "[color=#ff2a7a][font_size=16][b]DISCLAIMER[/b][/font_size][/color]\n\n"
	bb_text += "[color=#e2e6f0]This game was developed by [/color][color=#00f0ff][b]Group 2[/b][/color][color=#e2e6f0] of [/color][color=#00f0ff][b]BSCS 3-3[/b][/color][color=#e2e6f0] as a project requirement for the [/color][color=#ffd700][b]Introduction to Artificial Intelligence[/b][/color][color=#e2e6f0] course under the Bachelor of Science in Computer Science program at the [/color][color=#39ff14][b]College of Computer and Information Sciences (CCIS)[/b][/color][color=#e2e6f0], [/color][color=#00f0ff][b]Polytechnic University of the Philippines (PUP) – Sta. Mesa, Manila[/b][/color][color=#e2e6f0]. This project was created solely for academic, educational, and demonstration purposes.[/color]\n\n\n"
	bb_text += "[color=#ff2a7a][font_size=14][b]DEVELOPMENT TEAM[/b][/font_size][/color]\n\n"
	bb_text += "[color=#ffd700][b]> Fiona Mikaela Beatriz Alberto[/b][/color]\n"
	bb_text += "[color=#ffd700][b]> Van Ernest Molo[/b][/color]\n"
	bb_text += "[color=#ffd700][b]> Nichole Shaynne Odion[/b][/color]\n"
	bb_text += "[color=#ffd700][b]> Crystal Kylla Viagedor[/b][/color]\n\n\n"
	bb_text += "[color=#ff2a7a][font_size=14][b]COURSE INFORMATION[/b][/font_size][/color]\n\n"
	bb_text += "[color=#e2e6f0]Course: [/color][color=#ffd700][b]Introduction to Artificial Intelligence[/b][/color]\n"
	bb_text += "[color=#e2e6f0]Institution: [/color][color=#39ff14][b]PUP Sta. Mesa, Manila[/b][/color]\n"
	bb_text += "[color=#e2e6f0]Section: [/color][color=#00f0ff][b]BSCS 3-3[/b][/color][color=#e2e6f0]  ·  [/color][color=#00f0ff][b]Group 2[/b][/color]\n"
	
	rtl.text = bb_text
	scroll.add_child(rtl)
	
	set_display_content(credits_panel_node)

func set_display_content(node: Node) -> void:
	for child in display_panel.get_children():
		if child.name != "PinkBorderPanel" and child.name != "BlueBorderPanel":
			child.queue_free()
	display_panel.add_child(node)
	
	# Move border overlay panels to the bottom of the child list so they are drawn on top
	var pink = display_panel.get_node_or_null("PinkBorderPanel")
	if pink != null:
		display_panel.move_child(pink, display_panel.get_child_count() - 1)
	var blue = display_panel.get_node_or_null("BlueBorderPanel")
	if blue != null:
		display_panel.move_child(blue, display_panel.get_child_count() - 1)
		
	if node is Control:
		node.set_anchors_preset(Control.PRESET_FULL_RECT)
		node.offset_left = 15
		node.offset_top = 15
		node.offset_right = -15
		node.offset_bottom = -15
		# Smooth fade-in transition
		node.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(node, "modulate:a", 1.0, 0.18)

func show_welcome_screen() -> void:
	var font_reg = load("res://assets/fonts/ChakraPetch-Regular.ttf")
	var font_bold = load("res://assets/fonts/ChakraPetch-Bold.ttf")

	var welcome_root = Control.new()
	welcome_root.name = "WelcomeScreen"
	
	# Subtle grid background overlay ONLY on the Welcome HUD
	var grid_bg = TextureRect.new()
	grid_bg.name = "GridBackground"
	grid_bg.texture = load("res://assets/grid3.png")
	grid_bg.stretch_mode = TextureRect.STRETCH_TILE
	grid_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	grid_bg.self_modulate = Color(0.12, 0.15, 0.22, 0.15) # Faint grid pattern matching gameplay
	welcome_root.add_child(grid_bg)

	var welcome = VBoxContainer.new()
	welcome.alignment = BoxContainer.ALIGNMENT_CENTER
	welcome.add_theme_constant_override("separation", 16)
	welcome.set_anchors_preset(Control.PRESET_FULL_RECT)
	welcome_root.add_child(welcome)
	
	var welcome_lbl = Label.new()
	welcome_lbl.text = "WELCOME TO THE GRID"
	welcome_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	welcome_lbl.add_theme_color_override("font_color", Color("#ff2a7a"))
	welcome_lbl.add_theme_font_size_override("font_size", 36)
	if font_bold != null:
		welcome_lbl.add_theme_font_override("font", font_bold)
	welcome.add_child(welcome_lbl)
	
	var tagline_lbl = Label.new()
	tagline_lbl.text = "Two Cycles. One Grid. No Mercy."
	tagline_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline_lbl.add_theme_color_override("font_color", Color("#606575"))
	tagline_lbl.add_theme_font_size_override("font_size", 18)
	if font_reg != null:
		tagline_lbl.add_theme_font_override("font", font_reg)
	welcome.add_child(tagline_lbl)
	
	# Split-Color Neon Divider
	var div_hbox = HBoxContainer.new()
	div_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	div_hbox.add_theme_constant_override("separation", 0)
	welcome.add_child(div_hbox)
	
	var div_pink = ColorRect.new()
	div_pink.custom_minimum_size = Vector2(90, 2)
	div_pink.color = Color("#ff2a7a")
	div_hbox.add_child(div_pink)
	
	var div_cyan = ColorRect.new()
	div_cyan.custom_minimum_size = Vector2(90, 2)
	div_cyan.color = Color("#00f0ff")
	div_hbox.add_child(div_cyan)
	
	var desc_lbl = Label.new()
	desc_lbl.text = "Select an option from the left panel to begin."
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.add_theme_color_override("font_color", Color("#404555"))
	desc_lbl.add_theme_font_size_override("font_size", 16)
	if font_reg != null:
		desc_lbl.add_theme_font_override("font", font_reg)
	welcome.add_child(desc_lbl)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	welcome.add_child(spacer)
	
	var tip_panel = PanelContainer.new()
	tip_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var tip_style = StyleBoxFlat.new()
	tip_style.bg_color = Color("#11131c")
	tip_style.border_color = Color("#222736")
	tip_style.set_border_width_all(1)
	tip_style.border_width_left = 4
	tip_style.border_color = Color("#ffd700") # Gold Accent Left Border
	tip_style.set_corner_radius_all(6)
	tip_style.content_margin_left = 22
	tip_style.content_margin_right = 22
	tip_style.content_margin_top = 14
	tip_style.content_margin_bottom = 14
	tip_style.shadow_color = Color(1.0, 0.84, 0.0, 0.04) # Subtle gold glow
	tip_style.shadow_size = 8
	tip_panel.add_theme_stylebox_override("panel", tip_style)
	welcome.add_child(tip_panel)
	
	var tip_vbox = VBoxContainer.new()
	tip_vbox.add_theme_constant_override("separation", 8)
	tip_panel.add_child(tip_vbox)
	
	var tip_title = Label.new()
	tip_title.text = "QUICK SYSTEM RULES"
	tip_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip_title.add_theme_color_override("font_color", Color("#ffd700"))
	tip_title.add_theme_font_size_override("font_size", 16)
	if font_bold != null:
		tip_title.add_theme_font_override("font", font_bold)
	tip_vbox.add_child(tip_title)
	
	# Small separator inside the card
	var tip_sep = ColorRect.new()
	tip_sep.custom_minimum_size = Vector2(0, 1)
	tip_sep.color = Color("#1e2230")
	tip_vbox.add_child(tip_sep)
	
	var tips = [
		{"text": "Use WASD or Arrow Keys to steer.", "color": Color("#ff2a7a")},
		{"text": "Enclose areas to capture territory and claim Energy Cores.", "color": Color("#00f0ff")},
		{"text": "Rare Gold Cores are worth 10 pts — prioritize them!", "color": Color("#ffd700")},
		{"text": "Head-on collisions result in a DRAW.", "color": Color("#ff2a7a")}
	]
	for tip in tips:
		var tip_hbox = HBoxContainer.new()
		tip_hbox.add_theme_constant_override("separation", 8)
		tip_vbox.add_child(tip_hbox)
		
		var bullet = Label.new()
		bullet.text = ">"
		bullet.add_theme_color_override("font_color", tip.color)
		bullet.add_theme_font_size_override("font_size", 14)
		if font_bold != null:
			bullet.add_theme_font_override("font", font_bold)
		tip_hbox.add_child(bullet)
		
		var tip_lbl = Label.new()
		tip_lbl.text = tip.text
		tip_lbl.add_theme_color_override("font_color", Color("#a0a5b5")) # Light gray, highly readable
		tip_lbl.add_theme_font_size_override("font_size", 14)
		if font_reg != null:
			tip_lbl.add_theme_font_override("font", font_reg)
		tip_hbox.add_child(tip_lbl)
	
	var version_lbl = Label.new()
	version_lbl.text = "v1.2  ·  Group 2  ·  BSCS 3-3  ·  Introduction to Artificial Intelligence"
	version_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version_lbl.add_theme_color_override("font_color", Color("#252830"))
	version_lbl.add_theme_font_size_override("font_size", 13)
	if font_reg != null:
		version_lbl.add_theme_font_override("font", font_reg)
	welcome.add_child(version_lbl)
	
	set_display_content(welcome_root)


# --- LIVING ARCADE BACKGROUND SCREENSAVER CLASS ---
class MenuBackgroundVisualizer extends Control:
	var grid_cols = 43
	var grid_rows = 24
	var cell_size = 30
	
	# Each snek is a Dictionary: {"body": Array[Vector2i], "dir": Vector2i, "color": Color}
	var sneks: Array = []
	var max_length = 20
	var update_timer: Timer
	
	func _ready() -> void:
		set_anchors_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# Initialize spawns
		reset_sneks()
		
		# Set up simulation timer
		update_timer = Timer.new()
		update_timer.wait_time = 0.12 # slither speed
		update_timer.autostart = true
		add_child(update_timer)
		update_timer.timeout.connect(_on_tick)
		
	func reset_sneks() -> void:
		sneks.clear()
		
		# Spawn 2 Red sneks on the left side at different heights
		var spawn_red_1 = Vector2i(5, 6)
		var spawn_red_2 = Vector2i(5, 18)
		
		# Spawn 2 Blue sneks on the right side at different heights
		var spawn_blue_1 = Vector2i(38, 6)
		var spawn_blue_2 = Vector2i(38, 18)
		
		sneks.append({"body": [spawn_red_1], "dir": Vector2i.RIGHT, "color": Color("#ff2a7a")})
		sneks.append({"body": [spawn_red_2], "dir": Vector2i.RIGHT, "color": Color("#ff2a7a")})
		sneks.append({"body": [spawn_blue_1], "dir": Vector2i.LEFT, "color": Color("#00f0ff")})
		sneks.append({"body": [spawn_blue_2], "dir": Vector2i.LEFT, "color": Color("#00f0ff")})

	func reset_snek(i: int) -> void:
		var s = sneks[i]
		s["body"].clear()
		match i:
			0:
				s["body"].append(Vector2i(5, 6))
				s["dir"] = Vector2i.RIGHT
			1:
				s["body"].append(Vector2i(5, 18))
				s["dir"] = Vector2i.RIGHT
			2:
				s["body"].append(Vector2i(38, 6))
				s["dir"] = Vector2i.LEFT
			3:
				s["body"].append(Vector2i(38, 18))
				s["dir"] = Vector2i.LEFT

	func _on_tick() -> void:
		# 1. Decide directions for all snakes
		for s in sneks:
			s["dir"] = choose_direction(s)
			
		# 2. Compute candidate positions
		var next_positions = []
		for s in sneks:
			next_positions.append(s["body"][-1] + s["dir"])
			
		# 3. Identify which snakes crash
		var crashed_indices = []
		for i in range(sneks.size()):
			var next_pos = next_positions[i]
			
			# Check boundary/body collision
			if is_occupied(next_pos):
				crashed_indices.append(i)
				continue
				
			# Check head-to-head collision with other snakes' next positions
			var head_to_head = false
			for j in range(sneks.size()):
				if i != j and next_pos == next_positions[j]:
					head_to_head = true
					break
			if head_to_head:
				crashed_indices.append(i)
				continue
				
		# 4. Apply movements for survivors, reset crashed ones on their own
		for i in range(sneks.size()):
			var s = sneks[i]
			if i in crashed_indices:
				reset_snek(i)
			else:
				var next_pos = next_positions[i]
				s["body"].append(next_pos)
				if s["body"].size() > max_length:
					s["body"].pop_front()
			
		queue_redraw()

	func is_occupied(pos: Vector2i) -> bool:
		# Boundaries
		if pos.x < 0 or pos.x >= grid_cols or pos.y < 0 or pos.y >= grid_rows:
			return true
		# Bodies
		for s in sneks:
			if pos in s["body"]:
				return true
		return false

	func choose_direction(snek: Dictionary) -> Vector2i:
		var body = snek["body"]
		var curr_dir = snek["dir"]
		var head = body[-1]
		
		var candidates = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		# Do not turn 180 degrees backward
		candidates.erase(-curr_dir)
		
		var safe_moves = []
		for dir in candidates:
			var target = head + dir
			if not is_occupied(target):
				safe_moves.append(dir)
				
		if safe_moves.is_empty():
			# No safe moves, pick anything to crash gracefully
			return candidates.pick_random()
			
		# Prefer continuing in the same direction with a high probability (75%)
		if curr_dir in safe_moves and randf() < 0.75:
			return curr_dir
			
		# Otherwise pick a random safe direction
		return safe_moves.pick_random()

	func _draw() -> void:
		# 1. Draw subtle background coordinate dots
		var dot_color = Color(0.12, 0.15, 0.22, 0.2) # extremely faint
		for x in range(grid_cols):
			for y in range(grid_rows):
				draw_circle(Vector2(x * cell_size + cell_size/2.0, y * cell_size + cell_size/2.0), 1.0, dot_color)
				
		# 2. Draw all snakes
		for s in sneks:
			draw_snek(s["body"], s["color"], s["dir"])

	func draw_snek(body: Array, base_color: Color, dir: Vector2i) -> void:
		if body.is_empty():
			return
		
		var body_size = body.size()
		for i in range(body_size):
			var pos = body[i]
			var pixel_pos = Vector2(pos.x * cell_size + cell_size/2.0, pos.y * cell_size + cell_size/2.0)
			
			# Fade opacity: tail has lower opacity, head has maximum opacity (0.18 so it remains a background screensaver!)
			var progress = float(i) / float(body_size - 1) if body_size > 1 else 1.0
			var opacity = lerp(0.02, 0.18, progress)
			
			# Glowing box/rect for body
			var style_color = Color(base_color.r, base_color.g, base_color.b, opacity)
			
			if i == body_size - 1:
				# Snek Head: Draw glowing outer shadow rings like in gameplay (but softer for background)
				for j in range(3):
					var radius = 11.0 + (3 - j) * 3.0
					var alpha = 0.05 + j * 0.05
					draw_circle(pixel_pos, radius, Color(base_color.r, base_color.g, base_color.b, alpha))
				
				# Solid head circle
				var head_color = Color(base_color.r, base_color.g, base_color.b, 0.45)
				draw_circle(pixel_pos, 11.0, head_color)
				
				# White inner core highlighting edge
				draw_circle(pixel_pos, 9.0, Color(1.0, 1.0, 1.0, 0.12))
				
				# Convert direction vector to floats
				var dir_f = Vector2(dir)
				var perp_f = Vector2(-dir.y, dir.x)
				
				# Position eyes relative to snek heading direction (proportional to 11.0 radius)
				var eye1_pos = pixel_pos + dir_f * 3.8 + perp_f * -3.5
				var eye2_pos = pixel_pos + dir_f * 3.8 + perp_f * 3.5
				
				var eye_color = Color(1.0, 1.0, 1.0, 0.7) # white eyeball
				var pupil_color = Color(0.0, 0.0, 0.0, 0.7) # black pupil
				
				var eye_r = 3.0
				var pupil_r = 1.3
				
				# Eyeballs
				draw_circle(eye1_pos, eye_r, eye_color)
				draw_circle(eye2_pos, eye_r, eye_color)
				
				# Pupils shifted slightly forward to look alive
				var pupil_shift = dir_f * 0.9
				draw_circle(eye1_pos + pupil_shift, pupil_r, pupil_color)
				draw_circle(eye2_pos + pupil_shift, pupil_r, pupil_color)
			else:
				# Body segment: Draw rounded line segments or solid boxes
				var rect = Rect2(pixel_pos - Vector2(12, 12), Vector2(24, 24))
				draw_rect(rect, style_color, true)

func animate_button(btn: Button) -> void:
	btn.mouse_entered.connect(func():
		btn.pivot_offset = btn.size / 2.0
		var tween = btn.create_tween()
		tween.tween_property(btn, "scale", Vector2(1.03, 1.03), 0.12).set_trans(Tween.TRANS_SINE)
	)
	btn.mouse_exited.connect(func():
		btn.pivot_offset = btn.size / 2.0
		if not btn.has_focus():
			var tween = btn.create_tween()
			tween.tween_property(btn, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE)
	)
	btn.focus_entered.connect(func():
		btn.pivot_offset = btn.size / 2.0
		var tween = btn.create_tween()
		tween.tween_property(btn, "scale", Vector2(1.03, 1.03), 0.12).set_trans(Tween.TRANS_SINE)
	)
	btn.focus_exited.connect(func():
		btn.pivot_offset = btn.size / 2.0
		var tween = btn.create_tween()
		tween.tween_property(btn, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE)
	)
