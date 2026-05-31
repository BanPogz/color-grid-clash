# StatsManager.gd
class_name StatsManager

const STATS_FILE = "user://grid_clash_stats.json"

static func get_default_stats() -> Dictionary:
	return {
		"games_played": 0,
		"p1_wins": 0,
		"ai_wins": 0,
		"draws": 0,
		"p1_total_score": 0,
		"ai_total_score": 0,
		"p1_max_round_score": 0,
		"ai_max_round_score": 0,
		"total_cores_eaten": 0,
		"total_cells_captured": 0
	}

static func load_stats() -> Dictionary:
	var file = FileAccess.open(STATS_FILE, FileAccess.READ)
	if file == null:
		return get_default_stats()
	var json_text = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_text)
	if error == OK:
		var data = json.get_data()
		if typeof(data) == TYPE_DICTIONARY:
			# Merge with defaults to ensure all keys exist
			var default_stats = get_default_stats()
			for key in default_stats.keys():
				if not data.has(key):
					data[key] = default_stats[key]
			return data
	return get_default_stats()

static func save_stats(stats: Dictionary) -> void:
	var file = FileAccess.open(STATS_FILE, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(stats, "\t"))

static func record_game_result(p1_score: int, ai_score: int, winner: String, total_cores: int, total_cells: int) -> void:
	var stats = load_stats()
	stats["games_played"] += 1
	stats["p1_total_score"] += p1_score
	stats["ai_total_score"] += ai_score
	stats["total_cores_eaten"] += total_cores
	stats["total_cells_captured"] += total_cells
	
	if winner == "RED":
		stats["p1_wins"] += 1
	elif winner == "BLUE":
		stats["ai_wins"] += 1
	else:
		stats["draws"] += 1
		
	if p1_score > stats["p1_max_round_score"]:
		stats["p1_max_round_score"] = p1_score
	if ai_score > stats["ai_max_round_score"]:
		stats["ai_max_round_score"] = ai_score
		
	save_stats(stats)
