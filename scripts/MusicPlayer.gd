# MusicPlayer.gd
extends AudioStreamPlayer

var music_stream: AudioStreamWAV
var menu_music_stream: AudioStreamWAV
var sfx_player: AudioStreamPlayer
var sfx_streams: Dictionary = {}

func _ready() -> void:
	# Set process mode to ALWAYS so that music continues to play/process even when the tree is paused!
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Load the generated retro gameplay music WAV
	var path = "res://assets/retro_music.wav"
	if ResourceLoader.exists(path):
		music_stream = load(path) as AudioStreamWAV
		if music_stream != null:
			music_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			music_stream.loop_begin = 0
			music_stream.loop_end = music_stream.get_length() * music_stream.mix_rate
			
	# Load the generated retro menu music WAV
	var menu_path = "res://assets/menu_music.wav"
	if ResourceLoader.exists(menu_path):
		menu_music_stream = load(menu_path) as AudioStreamWAV
		if menu_music_stream != null:
			menu_music_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			menu_music_stream.loop_begin = 0
			menu_music_stream.loop_end = menu_music_stream.get_length() * menu_music_stream.mix_rate
	
	# Create a child player specifically for SFX
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS # Make SFX playable even during pause!
	add_child(sfx_player)
	
	# Load SFX streams
	var sfx_names = [
		"countdown_beep", "countdown_go", "round_win", "round_loss", "round_draw",
		"button_click", "match_win", "match_loss", "match_draw"
	]
	for sfx in sfx_names:
		var sfx_path = "res://assets/sfx/%s.wav" % sfx
		if ResourceLoader.exists(sfx_path):
			var stream_wav = load(sfx_path) as AudioStreamWAV
			if stream_wav != null:
				sfx_streams[sfx] = stream_wav
	
	# Connect to tree's node_added signal to automatically play a sound when any Button is pressed!
	get_tree().node_added.connect(_on_node_added)
	
	# Connect existing buttons in the current scene just in case some are already loaded
	_connect_buttons_recursive(get_tree().root)
	
	# Update volume to match initial configuration
	update_volume()
	
	# Create a CanvasLayer for global UI overlays
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "GlobalAudioUI"
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var sound_btn = SoundToggleButton.new()
	sound_btn.name = "GlobalMuteButton"
	sound_btn.position = Vector2(1225, 10)
	canvas_layer.add_child(sound_btn)

func _on_node_added(node: Node) -> void:
	if node is Button:
		_connect_button(node)

func _connect_button(btn: Button) -> void:
	# Avoid double connections if node_added is somehow fired twice
	if not btn.pressed.is_connected(_on_button_pressed):
		btn.pressed.connect(_on_button_pressed)
	if not btn.mouse_entered.is_connected(_on_button_hovered):
		btn.mouse_entered.connect(_on_button_hovered)
	if not btn.focus_entered.is_connected(_on_button_hovered):
		btn.focus_entered.connect(_on_button_hovered)

func _on_button_pressed() -> void:
	play_sfx("button_click")

func _on_button_hovered() -> void:
	play_sfx_volume("button_click", -15.0) # 15dB quieter for subtle hover tick

func _connect_buttons_recursive(node: Node) -> void:
	if node is Button:
		_connect_button(node)
	for child in node.get_children():
		_connect_buttons_recursive(child)

func play_music() -> void:
	if music_stream == null:
		return
		
	# Switch stream if not already active
	if stream != music_stream:
		stop()
		stream = music_stream
		
	# Only play if we are not already playing
	if not playing:
		play()
	
	stream_paused = false
	update_volume()

func play_menu_music() -> void:
	if menu_music_stream == null:
		return
		
	# Switch stream if not already active
	if stream != menu_music_stream:
		stop()
		stream = menu_music_stream
		
	# Only play if we are not already playing
	if not playing:
		play()
		
	stream_paused = false
	update_volume()

func stop_music() -> void:
	stop()

func pause_music() -> void:
	stream_paused = true

func resume_music() -> void:
	if not playing:
		play()
	stream_paused = false
	update_volume()

func update_volume() -> void:
	if ConfigManager.music_enabled:
		# Map linear 0.0 - 1.0 volume to decibel range -40dB to +6dB
		var vol = ConfigManager.music_volume
		if vol <= 0.001:
			volume_db = -80.0
		else:
			volume_db = linear_to_db(vol)
	else:
		volume_db = -80.0
		
	var btn = get_node_or_null("GlobalAudioUI/GlobalMuteButton")
	if btn != null:
		btn.queue_redraw()

func play_sfx(sfx_name: String) -> void:
	if not ConfigManager.music_enabled:
		return
	if sfx_streams.has(sfx_name) and sfx_player != null:
		sfx_player.stream = sfx_streams[sfx_name]
		var vol = ConfigManager.music_volume
		if vol <= 0.001:
			sfx_player.volume_db = -80.0
		else:
			if sfx_name == "button_click":
				sfx_player.volume_db = linear_to_db(vol) - 1.0
			else:
				sfx_player.volume_db = linear_to_db(vol) + 2.0
		sfx_player.play()

func play_sfx_volume(sfx_name: String, vol_offset: float) -> void:
	if not ConfigManager.music_enabled:
		return
	if sfx_streams.has(sfx_name) and sfx_player != null:
		sfx_player.stream = sfx_streams[sfx_name]
		var vol = ConfigManager.music_volume
		if vol <= 0.001:
			sfx_player.volume_db = -80.0
		else:
			sfx_player.volume_db = linear_to_db(vol) + vol_offset
		sfx_player.play()


func toggle_mute() -> void:
	ConfigManager.music_enabled = not ConfigManager.music_enabled
	update_volume()
	
	var root_scene = get_tree().current_scene
	if root_scene != null:
		var config_panel = root_scene.find_child("ConfigPanel", true, false)
		if config_panel != null:
			var check_buttons = []
			_find_nodes_of_type(config_panel, "CheckButton", check_buttons)
			for cb in check_buttons:
				if cb.text == "Enabled" or cb.text == "Disabled":
					cb.button_pressed = ConfigManager.music_enabled
					cb.text = "Enabled" if ConfigManager.music_enabled else "Disabled"

func _find_nodes_of_type(node: Node, type_name: String, result: Array) -> void:
	if node.is_class(type_name) or node.get_class() == type_name:
		result.append(node)
	for child in node.get_children():
		_find_nodes_of_type(child, type_name, result)


# Custom Button to draw a glowing speaker/mute icon
class SoundToggleButton extends Button:
	func _ready() -> void:
		custom_minimum_size = Vector2(40, 40)
		size = Vector2(40, 40)
		flat = true
		focus_mode = Control.FOCUS_NONE
		pressed.connect(_on_pressed)
		mouse_entered.connect(queue_redraw)
		mouse_exited.connect(queue_redraw)
		
	func _on_pressed() -> void:
		var mp = get_node_or_null("/root/MusicPlayer")
		if mp != null:
			mp.toggle_mute()
			
	func _draw() -> void:
		var w = size.x
		var h = size.y
		var enabled = ConfigManager.music_enabled
		
		if is_hovered():
			draw_rect(Rect2(0, 0, w, h), Color("#00f0ff", 0.15), true)
		else:
			draw_rect(Rect2(0, 0, w, h), Color("#12141c", 0.6), true)
			
		var speaker_color = Color("#00f0ff") if enabled else Color("#ff2a7a")
		
		draw_rect(Rect2(11, 14, 4, 12), speaker_color, true)
		
		var points = PackedVector2Array([
			Vector2(15, 14),
			Vector2(21, 9),
			Vector2(21, 31),
			Vector2(15, 26)
		])
		draw_polygon(points, PackedColorArray([speaker_color]))
		
		if enabled:
			draw_arc(Vector2(21, 20), 5.0, -PI/3.0, PI/3.0, 8, speaker_color, 1.5)
			draw_arc(Vector2(21, 20), 9.0, -PI/3.0, PI/3.0, 8, speaker_color, 1.5)
		else:
			draw_line(Vector2(25, 15), Vector2(31, 25), speaker_color, 1.5)
			draw_line(Vector2(31, 15), Vector2(25, 25), speaker_color, 1.5)
