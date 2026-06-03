# quit.gd
extends Control

func _ready() -> void:
	var control = self
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 25)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	control.add_child(vbox)
	
	var prompt = Label.new()
	prompt.text = "QUIT GAME?\n\nAre you sure you want to exit?"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_color_override("font_color", Color("#ff2a7a"))
	prompt.add_theme_font_size_override("font_size", 20)
	vbox.add_child(prompt)
	
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 30)
	vbox.add_child(hbox)
	
	var yes_btn = Button.new()
	yes_btn.name = "YesButton"
	yes_btn.text = "YES"
	yes_btn.custom_minimum_size = Vector2(150, 40)
	hbox.add_child(yes_btn)
	
	var no_btn = Button.new()
	no_btn.name = "NoButton"
	no_btn.text = "NO"
	no_btn.custom_minimum_size = Vector2(150, 40)
	hbox.add_child(no_btn)
	
	# Style buttons
	var style_yes = StyleBoxFlat.new()
	style_yes.bg_color = Color("#220b12")
	style_yes.border_color = Color("#ff2a7a")
	style_yes.set_border_width_all(1)
	style_yes.set_corner_radius_all(6)
	
	var style_no = StyleBoxFlat.new()
	style_no.bg_color = Color("#0b221a")
	style_no.border_color = Color("#00f0ff")
	style_no.set_border_width_all(1)
	style_no.set_corner_radius_all(6)
	
	yes_btn.add_theme_stylebox_override("normal", style_yes)
	var style_yes_focus = style_yes.duplicate()
	style_yes_focus.shadow_color = Color(1.0, 0.16, 0.48, 0.4)
	style_yes_focus.shadow_size = 8
	yes_btn.add_theme_stylebox_override("hover", style_yes_focus)
	yes_btn.add_theme_stylebox_override("focus", style_yes_focus)
	yes_btn.add_theme_color_override("font_color", Color("#ff2a7a"))
	
	no_btn.add_theme_stylebox_override("normal", style_no)
	var style_no_focus = style_no.duplicate()
	style_no_focus.shadow_color = Color(0, 0.94, 1.0, 0.4)
	style_no_focus.shadow_size = 8
	no_btn.add_theme_stylebox_override("hover", style_no_focus)
	no_btn.add_theme_stylebox_override("focus", style_no_focus)
	no_btn.add_theme_color_override("font_color", Color("#00f0ff"))
