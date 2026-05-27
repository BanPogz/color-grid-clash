class_name Gameplay extends Node2D

@onready var grid_layer: TileMapLayer = $GridLayer
@onready var player_red: BasePlayer = $Player1
@onready var ai_player: BasePlayer = $Player2
@onready var tick_timer: Timer = $TickTimer

enum CellType {EMPTY, WALL, RED_TAIL, BLUE_TAIL, ENERGY_CORE}

#Grid parameters
var tile_size: int = 30
var grid_width: int = 20
var grid_height: int = 20
var grid_matrix: Array = []

func initialize_matrix():
	grid_matrix.clear()
	for x in range (grid_width):
		var row = []
		for y in range(grid_height):
			row.append(CellType.EMPTY)
		grid_matrix.append(row)

# Assuming these are your initial spawn tiles
var red_spawn_pos := Vector2i(2, 10)
var blue_spawn_pos := Vector2i(17, 10)

func generate_random_walls(density: float) -> void:
	# 1. Calculate exactly how many walls are needed
	# 20 * 20 = 400 total cells. 400 * 0.15 = 60 walls
	var total_cells: int = grid_width * grid_height
	var target_wall_count: int = int(total_cells * density)
	
	var walls_placed: int = 0
	
	# 2. Keep looping until we successfully place the exact target number
	while walls_placed < target_wall_count:
		# Pick a completely random coordinate on your 20x20 grid (0 to 19)
		var rand_x: int = randi_range(0, grid_width - 1)
		var rand_y: int = randi_range(0, grid_height - 1)
		var candidate_pos := Vector2i(rand_x, rand_y)
		
		# 3. SAFETY CHECKS: Skip this tile if it violates starting conditions
		
		# Check A: Is there already a wall here? (Prevents duplicates)
		if grid_matrix[rand_x][rand_y] == CellType.WALL:
			continue # Skip the rest of the loop and try a new random coordinate
			
		# Check B: Is this position on or directly adjacent to Player 1's spawn?
		if candidate_pos == red_spawn_pos or candidate_pos == red_spawn_pos + Vector2i.RIGHT:
			continue
			
		# Check C: Is this position on or directly adjacent to the AI's spawn?
		if candidate_pos == blue_spawn_pos or candidate_pos == blue_spawn_pos + Vector2i.LEFT:
			continue
			
		# 4. COMMIT THE WALL: If it passes all safety checks, place it!
		
		# Update the data matrix (Single source of truth for Crystal's Minimax)
		grid_matrix[rand_x][rand_y] = CellType.WALL
		
		# Update the visual Grid Layer
		# Replace source_id (0) and atlas coordinates Vector2i(x, y) with your actual wall tile assets
		grid_layer.set_cell(candidate_pos, 0, Vector2i(2, 0)) 
		
		walls_placed += 1
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_matrix()
	generate_random_walls(randf_range(0.1, 0.15)) # 10-15% static walls
	tick_timer.timeout.connect(_on_tick_timer_timeout)
	tick_timer.start()

func _on_tick_timer_timeout() -> void:
	# 1. Get intended movements
	var red_dir = player_red.current_direction
	
	# Pass game state data structure directly to Van and Crystal's AI routines
	var current_state_data = {
		"matrix": grid_matrix.duplicate(true),
		"red_pos": player_red.grid_position,
		"blue_pos": ai_player.grid_position
	}
	var blue_dir = ai_player.think_and_decide(current_state_data)
	
	# 2. Compute candidate positions
	var next_red = player_red.grid_position + red_dir
	var next_blue = ai_player.grid_position + blue_dir
	
	"""
	# 3. Check for terminal/crash states simultaneously
	if check_collision(next_red, next_blue):
		handle_game_over()
		return
	"""
	
	# 4. Commit moves to logical data grid matrix
	update_logical_matrix(player_red.grid_position, next_red, "RED")
	update_logical_matrix(ai_player.grid_position, next_blue, "BLUE")
	
	# 5. Move actual game nodes visually
	player_red.grid_position = next_red
	player_red.position = next_red * tile_size
	
	ai_player.grid_position = next_blue
	ai_player.position = next_blue * tile_size
	
	# 6. Render new trail tiles onto display
	grid_layer.set_cell(next_red, 0, Vector2i(0, 0))  # Paints red trail atlas coordinate
	grid_layer.set_cell(next_blue, 0, Vector2i(1, 0)) # Paints blue trail atlas coordinate

func check_collision(next_red: Vector2i, next_blue: Vector2i) -> bool:
	# Out of bounds check using grid size dimensions
	if next_red.x < 0 or next_red.x >= grid_width or next_red.y < 0 or next_red.y >= grid_height:
		return true
	# Matrix collision check
	if grid_matrix[next_red.x][next_red.y] != 0: # 0 represents EMPTY
		return true
	return false

func update_logical_matrix(old_pos: Vector2i, new_pos: Vector2i, type: String):
	# Turn old position into trailing obstacle data
	grid_matrix[old_pos.x][old_pos.y] = 2 if type == "RED" else 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
