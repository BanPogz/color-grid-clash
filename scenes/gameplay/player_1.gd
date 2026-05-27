# Player1.gd
extends BasePlayer

# Captures keyboard and controller inputs to change movement direction
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p1_moveUp") and current_direction != Vector2i.DOWN:
		current_direction = Vector2i.UP
	elif event.is_action_pressed("p1_moveDown") and current_direction != Vector2i.UP:
		current_direction = Vector2i.DOWN
	elif event.is_action_pressed("p1_moveLeft") and current_direction != Vector2i.RIGHT:
		current_direction = Vector2i.LEFT
	elif event.is_action_pressed("p1_moveRight") and current_direction != Vector2i.LEFT:
		current_direction = Vector2i.RIGHT
