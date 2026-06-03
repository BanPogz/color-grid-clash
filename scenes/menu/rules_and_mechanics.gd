# rules_and_mechanics.gd
extends Control

func _ready() -> void:
	var control = self
	
	# Load and apply modern cybernetic theme font
	var theme_font = load("res://assets/fonts/ChakraPetch-Regular.ttf")
	var theme_font_bold = load("res://assets/fonts/ChakraPetch-Bold.ttf")
	if theme_font != null:
		var rules_theme = Theme.new()
		rules_theme.default_font = theme_font
		control.theme = rules_theme
		
	var default_font = load("res://assets/fonts/TRS-Million Rg.otf")
	
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
	title.text = "RULES & MECHANICS"
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
	
	# Scroll area for rules content
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Hide horizontal scrollbar for clean presentation
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)
	
	var content_vbox = VBoxContainer.new()
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.add_theme_constant_override("separation", 15)
	scroll.add_child(content_vbox)
	
	# Shared Card Styling with a left-accent border color
	var create_rule_card = func(num_text: String, title_text: String, desc_text: String, border_color: Color):
		var panel = PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var card_style = StyleBoxFlat.new()
		card_style.bg_color = Color("#11131c")
		card_style.border_color = border_color
		card_style.set_border_width_all(1)
		# Left-accent border (thicker left border to highlight the card)
		card_style.border_width_left = 5
		card_style.set_corner_radius_all(4)
		card_style.content_margin_left = 15
		card_style.content_margin_right = 15
		card_style.content_margin_top = 12
		card_style.content_margin_bottom = 12
		panel.add_theme_stylebox_override("panel", card_style)
		
		var c_vbox = VBoxContainer.new()
		c_vbox.add_theme_constant_override("separation", 6)
		panel.add_child(c_vbox)
		
		var h_lbl = Label.new()
		h_lbl.text = num_text + ". " + title_text.to_upper()
		h_lbl.add_theme_color_override("font_color", border_color)
		h_lbl.add_theme_font_size_override("font_size", 13)
		c_vbox.add_child(h_lbl)
		
		var d_lbl = Label.new()
		d_lbl.text = desc_text
		d_lbl.add_theme_font_size_override("font_size", 12)
		d_lbl.add_theme_color_override("font_color", Color("#a0a5b5"))
		d_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		c_vbox.add_child(d_lbl)
		
		return panel

	# Rule 1
	var card1 = create_rule_card.call(
		"01",
		"Capture Enclosures",
		"Close a loop with your trail against your trail, a wall, or the edge of the grid. The enclosed area is captured in your color, and any energy cores inside are claimed instantly for points.",
		Color("#ffd700")
	)
	content_vbox.add_child(card1)
	
	# Embed Flood Fill Simulation Demo inside Card 1
	var card1_vbox = card1.get_child(0)
	card1_vbox.add_child(HSeparator.new())
	
	var f_center = CenterContainer.new()
	card1_vbox.add_child(f_center)
	
	var flood_visualizer = FloodFillDemoVisualizer.new()
	flood_visualizer.demo_font = default_font
	f_center.add_child(flood_visualizer)
	
	# Rule 2
	var card2 = create_rule_card.call(
		"02",
		"Scoring",
		"Earn points by capturing tiles, collecting cores, and winning rounds:\n- Claimed Trail Cell: +1 point\n- Standard Core (Green): +5 points\n- Rare Core (Gold): +10 points (25% spawn rate)\n- Round Win Bonus: +50 points (Draw: +25 points)",
		Color("#ffd700")
	)
	content_vbox.add_child(card2)
	
	# Embed Scoring Simulation Demo inside Card 2
	var card2_vbox = card2.get_child(0)
	card2_vbox.add_child(HSeparator.new())
	
	var s_center = CenterContainer.new()
	card2_vbox.add_child(s_center)
	
	var scoring_visualizer = ScoringDemoVisualizer.new()
	scoring_visualizer.demo_font = default_font
	s_center.add_child(scoring_visualizer)
	
	# Rule 3
	var card3 = create_rule_card.call(
		"03",
		"Matches",
		"Matches consist of 5 rounds. The player with the highest total score at the end wins the match. Spawn positions are randomized each round.",
		Color("#ffd700")
	)
	content_vbox.add_child(card3)
	
	# Embed Championship Simulation Demo inside Card 3
	var card3_vbox = card3.get_child(0)
	card3_vbox.add_child(HSeparator.new())
	
	var c3_center = CenterContainer.new()
	card3_vbox.add_child(c3_center)
	
	var championship_visualizer = ChampionshipDemoVisualizer.new()
	championship_visualizer.demo_font = default_font
	c3_center.add_child(championship_visualizer)

	# Crash Demonstration Card
	var card4 = PanelContainer.new()
	card4.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color("#11131c")
	card_style.border_color = Color("#ffd700") # Gold border accent
	card_style.set_border_width_all(1)
	card_style.border_width_left = 5
	card_style.set_corner_radius_all(4)
	card_style.content_margin_left = 15
	card_style.content_margin_right = 15
	card_style.content_margin_top = 12
	card_style.content_margin_bottom = 12
	card4.add_theme_stylebox_override("panel", card_style)
	
	var c4_vbox = VBoxContainer.new()
	c4_vbox.add_theme_constant_override("separation", 8)
	card4.add_child(c4_vbox)
	
	var h4_lbl = Label.new()
	h4_lbl.text = "04. COLLISIONS & CRASHES"
	h4_lbl.add_theme_color_override("font_color", Color("#ffd700"))
	h4_lbl.add_theme_font_size_override("font_size", 13)
	c4_vbox.add_child(h4_lbl)
	
	var d4_lbl = Label.new()
	d4_lbl.text = "Crashing into a wall, an opponent's trail, your own trail, or head-on into another player eliminates you for the round."
	d4_lbl.add_theme_font_size_override("font_size", 12)
	d4_lbl.add_theme_color_override("font_color", Color("#a0a5b5"))
	d4_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	c4_vbox.add_child(d4_lbl)
	
	# Current Demo status label
	var status_lbl = Label.new()
	status_lbl.text = "SIMULATING: WALL COLLISION"
	status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_lbl.add_theme_font_size_override("font_size", 11)
	c4_vbox.add_child(status_lbl)
	
	# Center container for the simulator
	var center = CenterContainer.new()
	c4_vbox.add_child(center)
	
	var visualizer = CrashDemoVisualizer.new()
	visualizer.status_label = status_lbl # Pass status label reference
	visualizer.demo_font = default_font # Pass theme font for crash text
	center.add_child(visualizer)
	
	content_vbox.add_child(card4)


# Subclass for drawing a live interactive crash simulation demo
class CrashDemoVisualizer extends Control:
	var grid_cols = 20
	var grid_rows = 10
	var cell_size = 15
	
	enum DemoState { WALL_CRASH, TRAIL_CRASH, HEAD_COLLISION }
	var current_demo = DemoState.WALL_CRASH
	
	var sim_tick = 0
	var update_timer: Timer
	
	var red_snek = []
	var red_dir = Vector2i.RIGHT
	var blue_snek = []
	var blue_dir = Vector2i.LEFT
	
	var static_walls = []
	var static_red_trail = []
	var static_blue_trail = []
	
	var is_crashed = false
	var crash_cells = []
	var crash_pulse = 0.0
	var crash_text = ""
	
	var status_label: Label = null
	var demo_font: Font = null

	func _ready() -> void:
		custom_minimum_size = Vector2(300, 150)
		
		# Set up movement timer
		update_timer = Timer.new()
		update_timer.wait_time = 0.25 # slither speed
		update_timer.autostart = true
		add_child(update_timer)
		update_timer.timeout.connect(_on_tick)
		
		start_demo(DemoState.WALL_CRASH)
		
	func start_demo(state: DemoState) -> void:
		current_demo = state
		sim_tick = 0
		is_crashed = false
		crash_cells.clear()
		crash_pulse = 0.0
		
		red_snek.clear()
		blue_snek.clear()
		static_walls.clear()
		static_red_trail.clear()
		static_blue_trail.clear()
		
		match current_demo:
			DemoState.WALL_CRASH:
				if status_label != null:
					status_label.text = "SIMULATION: WALL COLLISION (RED)"
					status_label.add_theme_color_override("font_color", Color("#ff2a7a"))
				# Red starts left, slithers right to hit a wall block at (10, 5)
				red_snek = [Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5)]
				red_dir = Vector2i.RIGHT
				static_walls = [Vector2i(10, 5)]
				
			DemoState.TRAIL_CRASH:
				if status_label != null:
					status_label.text = "SIMULATION: TRAIL COLLISION (BLUE)"
					status_label.add_theme_color_override("font_color", Color("#00f0ff"))
				# Blue starts top, moving Down into static Red trail at (10, 6)
				static_red_trail = [Vector2i(6, 6), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 6), Vector2i(10, 6), Vector2i(11, 6), Vector2i(12, 6)]
				blue_snek = [Vector2i(10, 2), Vector2i(10, 3), Vector2i(10, 4)]
				blue_dir = Vector2i.DOWN
				
			DemoState.HEAD_COLLISION:
				if status_label != null:
					status_label.text = "SIMULATION: HEAD-ON CRASH (BOTH)"
					status_label.add_theme_color_override("font_color", Color("#ffd700"))
				# Red moving Right, Blue moving Left, meet at (9, 5)
				red_snek = [Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5)]
				red_dir = Vector2i.RIGHT
				blue_snek = [Vector2i(14, 5), Vector2i(13, 5), Vector2i(12, 5)]
				blue_dir = Vector2i.LEFT
				
		queue_redraw()

	func _process(delta: float) -> void:
		if is_crashed:
			crash_pulse += delta * 5.0
			queue_redraw()

	func _on_tick() -> void:
		if is_crashed:
			return
			
		sim_tick += 1
		
		# Move Red snek
		var next_red = Vector2i.ZERO
		var red_crashed = false
		if not red_snek.is_empty():
			next_red = red_snek[-1] + red_dir
			# Obstacle checks
			if next_red in static_walls or next_red in static_red_trail or next_red in static_blue_trail:
				red_crashed = true
			elif next_red.x < 0 or next_red.x >= grid_cols or next_red.y < 0 or next_red.y >= grid_rows:
				red_crashed = true
				
		# Move Blue snek
		var next_blue = Vector2i.ZERO
		var blue_crashed = false
		if not blue_snek.is_empty():
			next_blue = blue_snek[-1] + blue_dir
			# Obstacle checks
			if next_blue in static_walls or next_blue in static_red_trail or next_blue in static_blue_trail:
				blue_crashed = true
			elif next_blue.x < 0 or next_blue.x >= grid_cols or next_blue.y < 0 or next_blue.y >= grid_rows:
				blue_crashed = true

		# Head-to-head check
		if not red_snek.is_empty() and not blue_snek.is_empty():
			if next_red == next_blue:
				red_crashed = true
				blue_crashed = true

		if red_crashed or blue_crashed:
			var crash_points = []
			if red_crashed:
				crash_points.append(next_red)
			if blue_crashed:
				crash_points.append(next_blue)
			trigger_crash(crash_points)
			return

		# Commit moves for Red
		if not red_snek.is_empty():
			red_snek.append(next_red)
			red_snek.pop_front()

		# Commit moves for Blue
		if not blue_snek.is_empty():
			blue_snek.append(next_blue)
			blue_snek.pop_front()
			
		queue_redraw()

	func trigger_crash(cells: Array) -> void:
		is_crashed = true
		crash_cells = cells
		
		# Set crash text based on collision type: DRAW for head-to-head, LOSS for single crash
		if current_demo == DemoState.HEAD_COLLISION:
			crash_text = "DRAW"
		else:
			crash_text = "LOSS"
			
		queue_redraw()
		
		# Set a timer to cycle to the next demo state in 1.8 seconds
		var t = get_tree().create_timer(1.8)
		t.timeout.connect(func():
			var next_idx = (int(current_demo) + 1) % 3
			start_demo(DemoState.values()[next_idx])
		)

	func _draw() -> void:
		# Draw mini panel border and backing grid
		var panel_rect = Rect2(Vector2.ZERO, size)
		draw_rect(panel_rect, Color("#08090d"), true)
		
		# Glowing border glow
		var border_color = Color("#ff2a7a")
		if current_demo == DemoState.TRAIL_CRASH:
			border_color = Color("#00f0ff")
		elif current_demo == DemoState.HEAD_COLLISION:
			border_color = Color("#ffd700")
			
		draw_rect(panel_rect, border_color * 0.5, false, 1.5)
		
		# Subtle coordinate guide dots
		var dot_color = Color(0.12, 0.15, 0.22, 0.3)
		for x in range(grid_cols):
			for y in range(grid_rows):
				draw_circle(Vector2(x * cell_size + cell_size / 2.0, y * cell_size + cell_size / 2.0), 0.8, dot_color)
				
		# Draw static walls
		for w in static_walls:
			var rect = Rect2(w.x * cell_size + 1, w.y * cell_size + 1, cell_size - 2, cell_size - 2)
			draw_rect(rect, Color("#ffb703"), true)
			
		# Draw static trails
		for t in static_red_trail:
			var rect = Rect2(t.x * cell_size + 1, t.y * cell_size + 1, cell_size - 2, cell_size - 2)
			draw_rect(rect, Color("#ff2a7a", 0.4), true)
		for t in static_blue_trail:
			var rect = Rect2(t.x * cell_size + 1, t.y * cell_size + 1, cell_size - 2, cell_size - 2)
			draw_rect(rect, Color("#00f0ff", 0.4), true)
			
		# Draw snakes body segments and glowing head circles
		# Red snake
		var red_size = red_snek.size()
		for idx in range(red_size):
			var pos = red_snek[idx]
			var pixel_pos = Vector2(pos.x * cell_size + cell_size / 2.0, pos.y * cell_size + cell_size / 2.0)
			
			if idx == red_size - 1:
				# Head
				draw_circle(pixel_pos, cell_size * 0.4, Color("#ff2a7a"))
				# Direction indicator eyeball
				var dir_f = Vector2(red_dir)
				draw_circle(pixel_pos + dir_f * 2.0, 1.2, Color.WHITE)
			else:
				var rect = Rect2(pos.x * cell_size + 1.5, pos.y * cell_size + 1.5, cell_size - 3, cell_size - 3)
				var opacity = lerp(0.1, 0.6, float(idx) / float(red_size - 1))
				draw_rect(rect, Color("#ff2a7a", opacity), true)

		# Blue snake
		var blue_size = blue_snek.size()
		for idx in range(blue_size):
			var pos = blue_snek[idx]
			var pixel_pos = Vector2(pos.x * cell_size + cell_size / 2.0, pos.y * cell_size + cell_size / 2.0)
			
			if idx == blue_size - 1:
				# Head
				draw_circle(pixel_pos, cell_size * 0.4, Color("#00f0ff"))
				# Direction indicator eyeball
				var dir_f = Vector2(blue_dir)
				draw_circle(pixel_pos + dir_f * 2.0, 1.2, Color.WHITE)
			else:
				var rect = Rect2(pos.x * cell_size + 1.5, pos.y * cell_size + 1.5, cell_size - 3, cell_size - 3)
				var opacity = lerp(0.1, 0.6, float(idx) / float(blue_size - 1))
				draw_rect(rect, Color("#00f0ff", opacity), true)

		# Draw crash explosion circles
		if is_crashed:
			for cell in crash_cells:
				var pixel_pos = Vector2(cell.x * cell_size + cell_size / 2.0, cell.y * cell_size + cell_size / 2.0)
				var radius1 = clamp(crash_pulse * 10.0, 0.0, cell_size * 2.0)
				var alpha = clamp(1.0 - crash_pulse / 2.0, 0.0, 1.0)
				draw_circle(pixel_pos, radius1, Color(1.0, 0.2, 0.4, alpha * 0.7))
				draw_circle(pixel_pos, radius1 * 0.5, Color(1.0, 0.9, 0.2, alpha * 0.8))

		# Draw arcade-style crash text overlay (LOSS or DRAW) floating and fading out
		if is_crashed and demo_font != null:
			var float_y = crash_pulse * 6.0
			var alpha = clamp(1.2 - crash_pulse / 2.0, 0.0, 1.0)
			var text_color = Color("#ff2a7a", alpha) # Red/Pink for LOSS
			if crash_text == "DRAW":
				text_color = Color("#ffd700", alpha) # Gold for DRAW
			
			draw_string(demo_font, Vector2(0, 85 - float_y), crash_text, HORIZONTAL_ALIGNMENT_CENTER, 300, 24, text_color)


# Subclass for drawing a live interactive flood fill simulation demo
class FloodFillDemoVisualizer extends Control:
	var grid_cols = 20
	var grid_rows = 10
	var cell_size = 15
	
	var update_timer: Timer
	var demo_font: Font = null
	
	var snek_body = []
	var static_trail = []
	var is_flooded = false
	var core_eaten = false
	var flood_pulse = 0.0
	
	func _ready() -> void:
		custom_minimum_size = Vector2(300, 150)
		
		# Set up movement timer
		update_timer = Timer.new()
		update_timer.wait_time = 0.35 # slither speed
		update_timer.autostart = true
		add_child(update_timer)
		update_timer.timeout.connect(_on_tick)
		
		reset_demo()
		
	func reset_demo() -> void:
		is_flooded = false
		core_eaten = false
		flood_pulse = 0.0
		
		# Set up static loop segments
		static_trail.clear()
		
		# Left wall segments
		for y in range(2, 7):
			static_trail.append(Vector2i(6, y))
		# Bottom wall segments
		for x in range(6, 13):
			static_trail.append(Vector2i(x, 6))
		# Right wall segments (leave (12, 2) empty so the head lands on it to connect the loop)
		for y in range(3, 7):
			static_trail.append(Vector2i(12, y))
		# Top segment starts
		static_trail.append(Vector2i(6, 2))
		static_trail.append(Vector2i(7, 2))
		
		# Snek body starting position
		snek_body = [Vector2i(8, 2)]
		
		queue_redraw()

	func _process(delta: float) -> void:
		if is_flooded:
			flood_pulse += delta * 4.0
			queue_redraw()

	func _on_tick() -> void:
		if is_flooded:
			return
			
		var head = snek_body[-1]
		var next_pos = head + Vector2i.RIGHT
		
		# If head reaches the right wall connection (12, 2), trigger flood!
		if next_pos.x == 12:
			snek_body.append(next_pos)
			is_flooded = true
			core_eaten = true
			queue_redraw()
			
			# Reset demo after 2.0 seconds
			get_tree().create_timer(2.0).timeout.connect(func():
				reset_demo()
			)
		else:
			snek_body.append(next_pos)
			queue_redraw()

	func _draw() -> void:
		# Draw backing grid
		var panel_rect = Rect2(Vector2.ZERO, size)
		draw_rect(panel_rect, Color("#08090d"), true)
		draw_rect(panel_rect, Color("#ffd700") * 0.5, false, 1.5) # Yellow glowing border
		
		# Guide dots
		var dot_color = Color(0.12, 0.15, 0.22, 0.3)
		for x in range(grid_cols):
			for y in range(grid_rows):
				draw_circle(Vector2(x * cell_size + cell_size / 2.0, y * cell_size + cell_size / 2.0), 0.8, dot_color)
				
		# Draw the static trail segments
		for t in static_trail:
			var rect = Rect2(t.x * cell_size + 1, t.y * cell_size + 1, cell_size - 2, cell_size - 2)
			draw_rect(rect, Color("#ff2a7a", 0.4), true)
			
		# Draw active moving snake body
		var s_size = snek_body.size()
		for idx in range(s_size):
			var pos = snek_body[idx]
			var pixel_pos = Vector2(pos.x * cell_size + cell_size / 2.0, pos.y * cell_size + cell_size / 2.0)
			if idx == s_size - 1:
				# Head
				draw_circle(pixel_pos, cell_size * 0.4, Color("#ff2a7a"))
				# Direction indicator eyeball
				draw_circle(pixel_pos + Vector2(2, 0), 1.2, Color.WHITE) # look right
			else:
				var rect = Rect2(pos.x * cell_size + 1.5, pos.y * cell_size + 1.5, cell_size - 3, cell_size - 3)
				draw_rect(rect, Color("#ff2a7a", 0.6), true)
				
		# Draw Energy Core
		if not core_eaten:
			var core_pos = Vector2(9 * cell_size + cell_size/2.0, 4 * cell_size + cell_size/2.0)
			# Pulsing green core
			var pulse = sin(Time.get_ticks_msec() * 0.008) * 1.5 + 4.5
			draw_circle(core_pos, pulse, Color("#39ff14"))
			draw_circle(core_pos, pulse * 0.5, Color.WHITE)
			
		# Draw Flood fill area
		if is_flooded:
			var fill_alpha = clamp(flood_pulse / 1.5, 0.0, 0.35)
			# Enclosed cells are x from 7 to 11, y from 3 to 5
			var fill_rect = Rect2(7 * cell_size, 3 * cell_size, 5 * cell_size, 3 * cell_size)
			draw_rect(fill_rect, Color("#ff2a7a", fill_alpha), true)
			
			# Draw +5 PTS popup text floating up
			if demo_font != null:
				var float_y = flood_pulse * 8.0
				var text_alpha = clamp(1.2 - flood_pulse / 2.0, 0.0, 1.0)
				var text_pos = Vector2(9 * cell_size + cell_size/2.0, 4 * cell_size + 8 - float_y)
				draw_string(demo_font, text_pos - Vector2(100, 0), "+5 PTS", HORIZONTAL_ALIGNMENT_CENTER, 200, 12, Color("#39ff14", text_alpha))


# Subclass for drawing a live scoring rules demo
class ScoringDemoVisualizer extends Control:
	var grid_cols = 20
	var grid_rows = 10
	var cell_size = 15
	
	var update_timer: Timer
	var demo_font: Font = null
	
	var snek_body = []
	var snek_dir = Vector2i.RIGHT
	
	var green_core_pos = Vector2i(-1, -1)
	var gold_core_pos = Vector2i(-1, -1)
	var green_eaten = false
	var gold_eaten = false
	
	var score = 0
	var sim_tick = 0
	var is_finished = false
	
	var floating_texts = []
	
	func _ready() -> void:
		custom_minimum_size = Vector2(300, 150)
		
		update_timer = Timer.new()
		update_timer.wait_time = 0.3
		update_timer.autostart = true
		add_child(update_timer)
		update_timer.timeout.connect(_on_tick)
		
		reset_demo()
		
	func reset_demo() -> void:
		score = 0
		sim_tick = 0
		is_finished = false
		green_eaten = false
		gold_eaten = false
		floating_texts.clear()
		
		snek_body = [Vector2i(3, 4), Vector2i(4, 4), Vector2i(5, 4)]
		snek_dir = Vector2i.RIGHT
		green_core_pos = Vector2i(9, 4)
		gold_core_pos = Vector2i(-1, -1)
		
		queue_redraw()
		
	func _process(delta: float) -> void:
		var to_remove = []
		for t in floating_texts:
			t.pos.y -= delta * 25.0
			t.alpha -= delta * 0.8
			if t.alpha <= 0.0:
				to_remove.append(t)
		for r in to_remove:
			floating_texts.erase(r)
		if not floating_texts.is_empty():
			queue_redraw()
			
	func _on_tick() -> void:
		if is_finished:
			return
			
		sim_tick += 1
		
		if sim_tick >= 1 and sim_tick <= 4:
			snek_dir = Vector2i.RIGHT
		elif sim_tick == 5:
			snek_dir = Vector2i.DOWN
		elif sim_tick == 6:
			snek_dir = Vector2i.RIGHT
		elif sim_tick >= 7 and sim_tick <= 9:
			snek_dir = Vector2i.RIGHT
		elif sim_tick == 10:
			snek_dir = Vector2i.DOWN
		elif sim_tick >= 11 and sim_tick <= 13:
			snek_dir = Vector2i.RIGHT
			
		var head = snek_body[-1]
		var next_pos = head + snek_dir
		
		next_pos.x = clampi(next_pos.x, 0, grid_cols - 1)
		next_pos.y = clampi(next_pos.y, 0, grid_rows - 1)
		
		snek_body.append(next_pos)
		
		if not green_eaten and next_pos == green_core_pos:
			green_eaten = true
			score += 5
			var text_pos = Vector2(green_core_pos.x * cell_size + cell_size/2.0, green_core_pos.y * cell_size + cell_size/2.0)
			floating_texts.append({
				"text": "+5 PTS",
				"pos": text_pos,
				"color": Color("#39ff14"),
				"alpha": 1.0
			})
			gold_core_pos = Vector2i(13, 6)
			
		elif not gold_eaten and next_pos == gold_core_pos:
			gold_eaten = true
			score += 10
			var text_pos = Vector2(gold_core_pos.x * cell_size + cell_size/2.0, gold_core_pos.y * cell_size + cell_size/2.0)
			floating_texts.append({
				"text": "+10 PTS",
				"pos": text_pos,
				"color": Color("#ffd700"),
				"alpha": 1.0
			})
			
		if snek_body.size() > 4:
			snek_body.pop_front()
			
		if sim_tick >= 14:
			is_finished = true
			get_tree().create_timer(1.8).timeout.connect(func():
				reset_demo()
			)
			
		queue_redraw()
		
	func _draw() -> void:
		var panel_rect = Rect2(Vector2.ZERO, size)
		draw_rect(panel_rect, Color("#08090d"), true)
		draw_rect(panel_rect, Color("#ffd700") * 0.5, false, 1.5)
		
		var dot_color = Color(0.12, 0.15, 0.22, 0.3)
		for x in range(grid_cols):
			for y in range(grid_rows):
				draw_circle(Vector2(x * cell_size + cell_size / 2.0, y * cell_size + cell_size / 2.0), 0.8, dot_color)
				
		if not green_eaten and green_core_pos != Vector2i(-1, -1):
			var core_pos = Vector2(green_core_pos.x * cell_size + cell_size/2.0, green_core_pos.y * cell_size + cell_size/2.0)
			var pulse = sin(Time.get_ticks_msec() * 0.008) * 1.5 + 4.5
			draw_circle(core_pos, pulse, Color("#39ff14"))
			draw_circle(core_pos, pulse * 0.5, Color.WHITE)
			
		if not gold_eaten and gold_core_pos != Vector2i(-1, -1):
			var core_pos = Vector2(gold_core_pos.x * cell_size + cell_size/2.0, gold_core_pos.y * cell_size + cell_size/2.0)
			var pulse = sin(Time.get_ticks_msec() * 0.008) * 1.5 + 4.5
			draw_circle(core_pos, pulse, Color("#ffd700"))
			draw_circle(core_pos, pulse * 0.5, Color.WHITE)
			
		var s_size = snek_body.size()
		for idx in range(s_size):
			var pos = snek_body[idx]
			var pixel_pos = Vector2(pos.x * cell_size + cell_size / 2.0, pos.y * cell_size + cell_size / 2.0)
			if idx == s_size - 1:
				draw_circle(pixel_pos, cell_size * 0.4, Color("#ff2a7a"))
				var eye_pos = Vector2(snek_dir) * 2.0
				draw_circle(pixel_pos + eye_pos, 1.2, Color.WHITE)
			else:
				var rect = Rect2(pos.x * cell_size + 1.5, pos.y * cell_size + 1.5, cell_size - 3, cell_size - 3)
				var opacity = lerp(0.1, 0.6, float(idx) / float(s_size - 1))
				draw_rect(rect, Color("#ff2a7a", opacity), true)
				
		if demo_font != null:
			var score_text = "SCORE: %d" % score
			draw_string(demo_font, Vector2(10, 20), score_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#00f0ff"))
			
		for t in floating_texts:
			if demo_font != null:
				var color_with_alpha = Color(t.color.r, t.color.g, t.color.b, t.alpha)
				draw_string(demo_font, t.pos - Vector2(50, 0), t.text, HORIZONTAL_ALIGNMENT_CENTER, 100, 12, color_with_alpha)


# Subclass for drawing a live championship rounds demo
class ChampionshipDemoVisualizer extends Control:
	var grid_cols = 20
	var grid_rows = 10
	var cell_size = 15
	
	var update_timer: Timer
	var demo_font: Font = null
	
	var current_round = 1
	var sim_tick = 0
	
	var red_snek = []
	var red_dir = Vector2i.RIGHT
	var blue_snek = []
	var blue_dir = Vector2i.LEFT
	
	var red_score = 0
	var blue_score = 0
	var match_ended = false
	var round_paused = false
	var message_text = ""
	
	var round_configs = {
		1: {
			"red_start": [Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3)],
			"red_d": Vector2i.RIGHT,
			"blue_start": [Vector2i(17, 6), Vector2i(16, 6), Vector2i(15, 6)],
			"blue_d": Vector2i.LEFT,
			"red_s": 12,
			"blue_s": 8
		},
		2: {
			"red_start": [Vector2i(3, 8), Vector2i(3, 7), Vector2i(3, 6)],
			"red_d": Vector2i.UP,
			"blue_start": [Vector2i(16, 1), Vector2i(16, 2), Vector2i(16, 3)],
			"blue_d": Vector2i.DOWN,
			"red_s": 27,
			"blue_s": 28
		},
		3: {
			"red_start": [Vector2i(15, 2), Vector2i(14, 2), Vector2i(13, 2)],
			"red_d": Vector2i.LEFT,
			"blue_start": [Vector2i(4, 7), Vector2i(5, 7), Vector2i(6, 7)],
			"blue_d": Vector2i.RIGHT,
			"red_s": 37,
			"blue_s": 40
		},
		4: {
			"red_start": [Vector2i(10, 1), Vector2i(10, 2), Vector2i(10, 3)],
			"red_d": Vector2i.DOWN,
			"blue_start": [Vector2i(10, 8), Vector2i(10, 7), Vector2i(10, 6)],
			"blue_d": Vector2i.UP,
			"red_s": 62,
			"blue_s": 55
		},
		5: {
			"red_start": [Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5)],
			"red_d": Vector2i.RIGHT,
			"blue_start": [Vector2i(17, 5), Vector2i(16, 5), Vector2i(15, 5)],
			"blue_d": Vector2i.LEFT,
			"red_s": 80,
			"blue_s": 65
		}
	}
	
	func _ready() -> void:
		custom_minimum_size = Vector2(300, 150)
		
		update_timer = Timer.new()
		update_timer.wait_time = 0.25
		update_timer.autostart = true
		add_child(update_timer)
		update_timer.timeout.connect(_on_tick)
		
		start_match()
		
	func start_match() -> void:
		current_round = 1
		red_score = 0
		blue_score = 0
		match_ended = false
		start_round(1)
		
	func start_round(r_num: int) -> void:
		current_round = r_num
		sim_tick = 0
		round_paused = false
		message_text = ""
		
		var config = round_configs[current_round]
		red_snek = config["red_start"].duplicate()
		red_dir = config["red_d"]
		blue_snek = config["blue_start"].duplicate()
		blue_dir = config["blue_d"]
		
		queue_redraw()
		
	func _on_tick() -> void:
		if match_ended or round_paused:
			return
			
		sim_tick += 1
		
		var next_red = red_snek[-1] + red_dir
		red_snek.append(next_red)
		red_snek.pop_front()
		
		var next_blue = blue_snek[-1] + blue_dir
		blue_snek.append(next_blue)
		blue_snek.pop_front()
		
		if sim_tick >= 5:
			round_paused = true
			var config = round_configs[current_round]
			red_score = config["red_s"]
			blue_score = config["blue_s"]
			
			if current_round < 5:
				message_text = "ROUND %d COMPLETE" % current_round
				queue_redraw()
				get_tree().create_timer(1.2).timeout.connect(func():
					start_round(current_round + 1)
				)
			else:
				match_ended = true
				message_text = "RED WINS THE MATCH! 80-65"
				queue_redraw()
				get_tree().create_timer(2.5).timeout.connect(func():
					start_match()
				)
		else:
			queue_redraw()
			
	func _draw() -> void:
		var panel_rect = Rect2(Vector2.ZERO, size)
		draw_rect(panel_rect, Color("#08090d"), true)
		draw_rect(panel_rect, Color("#ffd700") * 0.5, false, 1.5)
		
		var dot_color = Color(0.12, 0.15, 0.22, 0.3)
		for x in range(grid_cols):
			for y in range(grid_rows):
				draw_circle(Vector2(x * cell_size + cell_size / 2.0, y * cell_size + cell_size / 2.0), 0.8, dot_color)
				
		var red_size = red_snek.size()
		for idx in range(red_size):
			var pos = red_snek[idx]
			var pixel_pos = Vector2(pos.x * cell_size + cell_size / 2.0, pos.y * cell_size + cell_size / 2.0)
			if idx == red_size - 1:
				draw_circle(pixel_pos, cell_size * 0.4, Color("#ff2a7a"))
				draw_circle(pixel_pos + Vector2(red_dir) * 2.0, 1.2, Color.WHITE)
			else:
				var rect = Rect2(pos.x * cell_size + 1.5, pos.y * cell_size + 1.5, cell_size - 3, cell_size - 3)
				var opacity = lerp(0.1, 0.6, float(idx) / float(red_size - 1))
				draw_rect(rect, Color("#ff2a7a", opacity), true)
				
		var blue_size = blue_snek.size()
		for idx in range(blue_size):
			var pos = blue_snek[idx]
			var pixel_pos = Vector2(pos.x * cell_size + cell_size / 2.0, pos.y * cell_size + cell_size / 2.0)
			if idx == blue_size - 1:
				draw_circle(pixel_pos, cell_size * 0.4, Color("#00f0ff"))
				draw_circle(pixel_pos + Vector2(blue_dir) * 2.0, 1.2, Color.WHITE)
			else:
				var rect = Rect2(pos.x * cell_size + 1.5, pos.y * cell_size + 1.5, cell_size - 3, cell_size - 3)
				var opacity = lerp(0.1, 0.6, float(idx) / float(blue_size - 1))
				draw_rect(rect, Color("#00f0ff", opacity), true)
				
		if demo_font != null:
			var info_y = 20
			var r_text = "RED: %d" % red_score
			draw_string(demo_font, Vector2(10, info_y), r_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#ff2a7a"))
			
			var b_text = "BLUE: %d" % blue_score
			draw_string(demo_font, Vector2(size.x - 90, info_y), b_text, HORIZONTAL_ALIGNMENT_RIGHT, 80, 11, Color("#00f0ff"))
			
			var round_text = "ROUND %d of 5" % current_round
			if match_ended:
				round_text = "FINAL"
			draw_string(demo_font, Vector2(0, info_y), round_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 11, Color("#ffd700"))
			
			if message_text != "":
				draw_rect(Rect2(0, size.y / 2.0 - 20, size.x, 36), Color(0, 0, 0, 0.65), true)
				var msg_color = Color("#ffd700")
				if match_ended:
					msg_color = Color("#39ff14")
				draw_string(demo_font, Vector2(0, size.y / 2.0 + 4), message_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 12, msg_color)
