# Player1.gd
extends BasePlayer

var ai_module: AIModule = null

func _ready() -> void:
	if ConfigManager.player_setup == ConfigManager.PlayerSetup.AI_VS_AI:
		ai_module = AIModule.new()
		add_child(ai_module)

func _unhandled_input(event: InputEvent) -> void:
	if ConfigManager.player_setup == ConfigManager.PlayerSetup.AI_VS_AI:
		return # Controlled by AI, ignore human input!
		
	var up_act = "p1_moveUp" if ConfigManager.player_setup == ConfigManager.PlayerSetup.P_VS_P else "ui_up"
	var down_act = "p1_moveDown" if ConfigManager.player_setup == ConfigManager.PlayerSetup.P_VS_P else "ui_down"
	var left_act = "p1_moveLeft" if ConfigManager.player_setup == ConfigManager.PlayerSetup.P_VS_P else "ui_left"
	var right_act = "p1_moveRight" if ConfigManager.player_setup == ConfigManager.PlayerSetup.P_VS_P else "ui_right"
	
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
