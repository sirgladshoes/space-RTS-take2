extends Node

@onready var player = AudioStreamPlayer.new()

var tracks = {
	"menu": "res://music/Sci-Fi 3 Loop.mp3",
	"lobby": "res://music/Sci-Fi 1 Loop.mp3"
}

var game_tracks = [
	"res://music/Sci-Fi 2 Loop.mp3",
	"res://music/Sci-Fi 4 Loop.mp3",
	"res://music/Sci-Fi 5 Loop.mp3",
	"res://music/Sci-Fi 6 Loop.mp3",
	"res://music/Sci-Fi 7 Loop.mp3",
	"res://music/Sci-Fi 8 Loop.mp3"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(player)
	player.set_bus("music")
	set_volume(0.5)


func play_track(track_name: String):
	var track_file = load(tracks[track_name])
	if player.stream != track_file:
		player.stream = track_file
		player.play()

func start_shuffle():
	player.finished.connect(play_rand_game_track)
	play_rand_game_track()

func end_shuffle():
	player.finished.disconnect(play_rand_game_track)

func play_rand_game_track():
	var track = game_tracks.pick_random()
	
	var track_file = load(track)
	player.stream = track_file
	player.play()


func set_volume(volume):
	player.volume_linear = volume
