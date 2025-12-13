extends Node

@onready var environment_impact_stream_player: AudioStreamPlayer = $EnvironmentImpactStreamPlayer
@onready var button_clicked_stream_player: AudioStreamPlayer = $ButtonClickedStreamPlayer
@onready var win_stream_player: AudioStreamPlayer = $WinStreamPlayer
@onready var reload_stream_player: AudioStreamPlayer = $ReloadStreamPlayer


func play_environment_impact():
	environment_impact_stream_player.play()


func play_button_clicked():
	button_clicked_stream_player.play()


func play_win():
	if not win_stream_player.playing:
		win_stream_player.play()


func play_reload():
	reload_stream_player.play()
