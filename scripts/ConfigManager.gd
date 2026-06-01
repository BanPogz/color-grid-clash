# ConfigManager.gd
extends Node

enum PlayerSetup {P_VS_AI, P_VS_P, AI_VS_AI}
enum TimerMode {INFINITE, LIMITED}
enum DemoMode { REAL_TIME, SLOW_MOTION, LINE_BY_LINE }

var red_is_ai: bool = false
var blue_is_ai: bool = true

var active_demo_mode: DemoMode = DemoMode.LINE_BY_LINE
var is_in_demo: bool = false

var player_setup: PlayerSetup:
	get:
		if not red_is_ai and blue_is_ai:
			return PlayerSetup.P_VS_AI
		elif not red_is_ai and not blue_is_ai:
			return PlayerSetup.P_VS_P
		else:
			return PlayerSetup.AI_VS_AI
	set(val):
		match val:
			PlayerSetup.P_VS_AI:
				red_is_ai = false
				blue_is_ai = true
			PlayerSetup.P_VS_P:
				red_is_ai = false
				blue_is_ai = false
			PlayerSetup.AI_VS_AI:
				red_is_ai = true
				blue_is_ai = true

var max_rounds: int = 5
var tick_speed: float = 0.05 # default is Intermediate (0.1) or Fast (0.05)
var timer_mode: TimerMode = TimerMode.INFINITE
var round_time_limit: int = 60 # in seconds (default is 1 minute)
var wall_density_type: String = "LESS" # NONE, LESS, MORE
var cores_count_type: String = "LESS" # NONE, LESS, MORE
var flood_fill_enabled: bool = true

func get_wall_density() -> float:
	match wall_density_type:
		"NONE":
			return 0.00
		"LESS":
			return randf_range(0.05, 0.10)
		"MORE":
			return randf_range(0.11, 0.20)
		_:
			return randf_range(0.05, 0.10)

func get_basic_cores_count() -> int:
	match cores_count_type:
		"NONE":
			return 0
		"LESS":
			return 2
		"MORE":
			return 4
		_:
			return 2

func get_rare_cores_count() -> int:
	match cores_count_type:
		"NONE":
			return 0
		"LESS":
			return 1
		"MORE":
			return 2
		_:
			return 1
