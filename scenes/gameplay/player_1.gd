# Player1.gd
extends BasePlayer

var ai_module: AIModule = null

func _ready() -> void:
	if ConfigManager.red_is_ai:
		ai_module = AIModule.new()
		add_child(ai_module)

func _unhandled_input(event: InputEvent) -> void:
	if ConfigManager.red_is_ai:
		return # Controlled by AI, ignore human input!
		
	var is_pvp = (not ConfigManager.red_is_ai) and (not ConfigManager.blue_is_ai)
	var up_act = "p1_moveUp" if is_pvp else "ui_up"
	var down_act = "p1_moveDown" if is_pvp else "ui_down"
	var left_act = "p1_moveLeft" if is_pvp else "ui_left"
	var right_act = "p1_moveRight" if is_pvp else "ui_right"
	
	if event.is_action_pressed(up_act) and current_direction != Vector2i.DOWN:
		current_direction = Vector2i.UP
	elif event.is_action_pressed(down_act) and current_direction != Vector2i.UP:
		current_direction = Vector2i.DOWN
	elif event.is_action_pressed(left_act) and current_direction != Vector2i.RIGHT:
		current_direction = Vector2i.LEFT
	elif event.is_action_pressed(right_act) and current_direction != Vector2i.LEFT:
		current_direction = Vector2i.RIGHT

func think_and_decide(game_state_data: Dictionary) -> Vector2i:
	if ai_module != null:
		# Player 1 is RED, which is the minimizing player (is_maximizing_player = false)
		var best_move = ai_module.get_best_move(game_state_data, 150.0, false)
		current_direction = best_move
		return best_move
	return current_direction
