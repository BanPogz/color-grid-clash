# BaseSnake.gd
extends Node2D
class_name BasePlayer

@export var player_color: Color = Color.WHITE
@export var player_id: int = 1 # 1 for Red (Player), 2 for Blue (AI)

var grid_position: Vector2i = Vector2i.ZERO
var current_direction: Vector2i = Vector2i.RIGHT
var body_segments: Array[Vector2i] = [] # Keeps track of occupied tiles

# Shared function to calculate what the next coordinate will be
func get_next_grid_position() -> Vector2i:
	return grid_position + current_direction

# Shared function to physically update position in the game board
func move_to(new_grid_pos: Vector2i):
	grid_position = new_grid_pos
	# In your actual code, translate this grid position to screen pixels:
	# position = gameplay_node.tile_to_pixel(grid_position)
