# rules_and_mechanics.gd
extends CanvasLayer

func _ready() -> void:
	var control = $Control
	
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
	title.text = "RULES & GRID MECHANICS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("#00f0ff"))
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)
	
	var rules_scroll = ScrollContainer.new()
	rules_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(rules_scroll)
	
	var scroll_vbox = VBoxContainer.new()
	scroll_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_vbox.add_theme_constant_override("separation", 12)
	rules_scroll.add_child(scroll_vbox)
	
	# Rule 1: Enclosure Flood
	var rule_ef = Label.new()
	rule_ef.text = "1. ENCLOSURE FLOOD MECHANISM"
	rule_ef.add_theme_color_override("font_color", Color("#ff2a7a"))
	rule_ef.add_theme_font_size_override("font_size", 14)
	scroll_vbox.add_child(rule_ef)
	
	var rule_ef_desc = Label.new()
	rule_ef_desc.text = "   Draw a closed shape with your trail that connects back to your trail, a wall, or the grid edge.\n   The entire enclosed empty region instantly floods in your color. Any energy cores caught inside\n   are swallowed, giving you full points, and new cores spawn in the open grid."
	rule_ef_desc.add_theme_font_size_override("font_size", 12)
	rule_ef_desc.add_theme_color_override("font_color", Color("#a0a5b5"))
	scroll_vbox.add_child(rule_ef_desc)
	
	# Rule 2: Scoring Matrix
	var rule_score = Label.new()
	rule_score.text = "2. SCORING MATRIX"
	rule_score.add_theme_color_override("font_color", Color("#ff2a7a"))
	rule_score.add_theme_font_size_override("font_size", 14)
	scroll_vbox.add_child(rule_score)
	
	var rule_score_desc = Label.new()
	rule_score_desc.text = "   • Captured Cell: +1 point\n   • Basic Energy Core (Neon Green): +5 points\n   • Rare Energy Core (Neon Gold): +10 points (25% spawn chance)\n   • Round Victory: +50 points (Draw: +25 points each)"
	rule_score_desc.add_theme_font_size_override("font_size", 12)
	rule_score_desc.add_theme_color_override("font_color", Color("#a0a5b5"))
	scroll_vbox.add_child(rule_score_desc)
	
	# Rule 3: Match Rounds
	var rule_rounds = Label.new()
	rule_rounds.text = "3. CHAMPIONSHIP ROUNDS"
	rule_rounds.add_theme_color_override("font_color", Color("#ff2a7a"))
	rule_rounds.add_theme_font_size_override("font_size", 14)
	scroll_vbox.add_child(rule_rounds)
	
	var rule_rounds_desc = Label.new()
	rule_rounds_desc.text = "   Games consist of 5 distinct rounds. The player with the highest accumulated score across all\n   rounds is crowned the Grid Champion. Between rounds, spawn positions are randomized."
	rule_rounds_desc.add_theme_font_size_override("font_size", 12)
	rule_rounds_desc.add_theme_color_override("font_color", Color("#a0a5b5"))
	scroll_vbox.add_child(rule_rounds_desc)
	
	# Add dynamic bottom spacer
	var bottom_spacer = Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(bottom_spacer)
