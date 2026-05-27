# BasePlayer.gd
extends Node2D
class_name BasePlayer

@export var player_color: Color = Color.WHITE
@export var player_id: int = 1 # 1 for Red (Player 1), 2 for Blue (Player 2 / AI)

var grid_position: Vector2i = Vector2i.ZERO
var current_direction: Vector2i = Vector2i.RIGHT
var body_segments: Array[Vector2i] = [] # Keeps track of all coordinates occupied by this player's trail

# Helper function to calculate what the next coordinate will be based on current direction
func get_next_grid_position() -> Vector2i:
	return grid_position + current_direction

# Helper function to update the logical position of the player
func move_to(new_grid_pos: Vector2i) -> void:
	grid_position = new_grid_pos
