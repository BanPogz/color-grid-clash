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

var controls_scene = preload("res://scenes/menu/controls_map.tscn")
var rules_scene = preload("res://scenes/menu/rules_and_mechanics.tscn")
var stats_scene = preload("res://scenes/menu/stats.tscn")
var config_scene = preload("res://scenes/menu/config_panel.tscn")
var quit_scene = preload("res://scenes/menu/quit.tscn")

func _ready() -> void:
	# Ensure existing button texts are structured perfectly
	config_button.text = "CONFIGURATION"
	config_button.custom_minimum_size = Vector2(0, 35) # match other buttons
	ai_demo_button.text = "AI VISUAL DEMO"
	ai_demo_button.custom_minimum_size = Vector2(0, 35)
	
	start_button.pressed.connect(_on_start_pressed)
	controls_button.pressed.connect(_on_controls_pressed)
	rules_button.pressed.connect(_on_rules_pressed)
	stats_button.pressed.connect(_on_stats_pressed)
	config_button.pressed.connect(_on_config_pressed)
	ai_demo_button.pressed.connect(_on_ai_demo_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Apply gorgeous neon theme styling programmatically
	setup_styling()
	
	# Show rules or default welcome screen in the display panel
	show_welcome_screen()
	
	# Grab focus initially for controller/keyboard navigation support
	start_button.grab_focus()

func setup_styling() -> void:
	# Main menu panel styling
	var menu_style = StyleBoxFlat.new()
	menu_style.bg_color = Color("#07090e")
	$Control/Panel.add_theme_stylebox_override("panel", menu_style)
	
	# Display panel styling
	var display_style = StyleBoxFlat.new()
	display_style.bg_color = Color("#0c0e14")
	display_style.border_color = Color("#ff2a7a") # Pulse pink
	display_style.set_border_width_all(2)
	display_style.corner_radius_top_left = 10
	display_style.corner_radius_top_right = 10
	display_style.corner_radius_bottom_left = 10
	display_style.corner_radius_bottom_right = 10
	display_style.shadow_color = Color(1.0, 0.16, 0.48, 0.2)
	display_style.shadow_size = 15
	display_panel.add_theme_stylebox_override("panel", display_style)
	
	# Style buttons
	var buttons = [start_button, controls_button, rules_button, stats_button, config_button, ai_demo_button, quit_button]
	for btn in buttons:
		# Gorgeous cybernetic buttons
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
		btn_hover.content_margin_left = 15
		btn_hover.content_margin_top = 8
		btn_hover.content_margin_bottom = 8
		btn_hover.shadow_color = Color(0, 0.94, 1.0, 0.1)
		btn_hover.shadow_size = 8
		
		btn.add_theme_stylebox_override("normal", btn_normal)
		btn.add_theme_stylebox_override("hover", btn_hover)
		btn.add_theme_stylebox_override("pressed", btn_hover)
		btn.add_theme_stylebox_override("focus", btn_hover) # Glow on focus!
		btn.add_theme_color_override("font_color", Color("#a0a5b5"))
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", Color("#00f0ff"))

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
	var demo_select = VBoxContainer.new()
	demo_select.name = "DemoSelectPanel"
	demo_select.alignment = BoxContainer.ALIGNMENT_CENTER
	demo_select.add_theme_constant_override("separation", 15)
	
	var title = Label.new()
	title.text = "SELECT AI VISUAL DEMO MODE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("#00f0ff")) # Glowing cyan
	title.add_theme_font_size_override("font_size", 20)
	demo_select.add_child(title)
	
	var desc = Label.new()
	desc.text = "Experience step-by-step code execution & board heuristic visualizers."
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_color_override("font_color", Color("#606575"))
	desc.add_theme_font_size_override("font_size", 12)
	demo_select.add_child(desc)
	
	var btn_realtime = Button.new()
	btn_realtime.text = "REAL-TIME WATCH MODE\nRun AI vs. AI match at full speed without highlighting pauses."
	style_demo_selector_btn(btn_realtime)
	btn_realtime.pressed.connect(func(): start_ai_demo(ConfigManager.DemoMode.REAL_TIME))
	demo_select.add_child(btn_realtime)
	
	var btn_slowmo = Button.new()
	btn_slowmo.text = "SLOW MOTION WALKTHROUGH\nAutomatically steps code execution line-by-line."
	style_demo_selector_btn(btn_slowmo)
	btn_slowmo.pressed.connect(func(): start_ai_demo(ConfigManager.DemoMode.SLOW_MOTION))
	demo_select.add_child(btn_slowmo)
	
	var btn_step = Button.new()
	btn_step.text = "LINE-BY-LINE STEPPING\nPause game execution and step manually using stepper deck."
	style_demo_selector_btn(btn_step)
	btn_step.pressed.connect(func(): start_ai_demo(ConfigManager.DemoMode.LINE_BY_LINE))
	demo_select.add_child(btn_step)
	
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
	btn_hover.content_margin_left = 15
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

func set_display_content(node: Node) -> void:
	for child in display_panel.get_children():
		child.queue_free()
	display_panel.add_child(node)
	if node is Control:
		node.set_anchors_preset(Control.PRESET_FULL_RECT)
		node.offset_left = 15
		node.offset_top = 15
		node.offset_right = -15
		node.offset_bottom = -15

func show_welcome_screen() -> void:
	# Create a beautiful welcome screen in code for a seamless experience
	var welcome = VBoxContainer.new()
	welcome.name = "WelcomeScreen"
	welcome.alignment = BoxContainer.ALIGNMENT_CENTER
	welcome.add_theme_constant_override("separation", 20)
	
	var welcome_lbl = Label.new()
	welcome_lbl.text = "WELCOME TO THE GRID"
	welcome_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	welcome_lbl.add_theme_color_override("font_color", Color("#ff2a7a"))
	welcome_lbl.add_theme_font_size_override("font_size", 28)
	welcome.add_child(welcome_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = "SELECT AN OPTION FROM THE LEFT TO BEGIN\n\n\n[ PROTOCOL ACTIVATED: COLOR GRID CLASH v1.2 ]"
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.add_theme_color_override("font_color", Color("#606575"))
	desc_lbl.add_theme_font_size_override("font_size", 14)
	welcome.add_child(desc_lbl)
	
	set_display_content(welcome)
