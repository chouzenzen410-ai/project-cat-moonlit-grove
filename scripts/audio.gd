extends Node
## Small pooled synthesized audio service. No downloaded audio samples.
var voices: Array[AudioStreamPlayer] = []
var music: AudioStreamPlayer
var muted := false

func _ready() -> void:
	for i in range(12):
		var p := AudioStreamPlayer.new()
		add_child(p)
		voices.append(p)
	music = AudioStreamPlayer.new()
	music.stream = load("res://assets/grove.wav")
	music.volume_db = -10
	add_child(music)
	music.finished.connect(_loop_music)
	music.play()

func _loop_music() -> void:
	music.play()

func sfx(cue: String, pitch := 1.0) -> void:
	for p in voices:
		if not p.playing:
			p.stream = load("res://assets/" + cue + ".wav")
			p.pitch_scale = pitch
			p.volume_db = -7
			p.play()
			return

func toggle() -> void:
	muted = not muted
	AudioServer.set_bus_mute(0, muted)

func _exit_tree() -> void:
	stop_all()

func stop_all() -> void:
	if is_instance_valid(music):
		music.stop()
		music.stream = null
	for p in voices:
		p.stop()
		p.stream = null
