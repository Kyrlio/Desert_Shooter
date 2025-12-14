extends CanvasLayer

@onready var main_menu_container: VBoxContainer = $VBoxContainer

var old_cursor: CompressedTexture2D


func _ready() -> void:
	visible = false
	get_tree().paused = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("player0_escape"):
		if get_tree().paused:
			Cursor.change_cursor(old_cursor, Vector2.ONE)
			visible = false
			get_tree().paused = false
		else:
			old_cursor = Cursor.get_actual_cursor()
			Cursor.change_cursor(load("uid://cvpl0vkt81dco"))
			visible = true
			get_tree().paused = true
			%ResumeButton.grab_focus()


func _on_resume_button_pressed() -> void:
	MusicPlayer.play_button_clicked()
	Cursor.change_cursor(old_cursor, Vector2.ONE)
	visible = false
	get_tree().paused = false


func _on_quit_button_pressed() -> void:
	MusicPlayer.play_button_clicked()
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("uid://542ov0s7gl6y")
