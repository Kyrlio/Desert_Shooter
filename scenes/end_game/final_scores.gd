extends Control

@onready var scores_container: VBoxContainer = %ScoresContainer
@onready var title_label: Label = %TitleLabel
@onready var button_menu: Button = %MenuButton

func _ready() -> void:
	_populate_scores()
	button_menu.pressed.connect(_on_menu_pressed)


func _populate_scores() -> void:
	var points: Array[int] = ScoreManager.get_all_points()
	# Trouver le vainqueur pour le titre
	var winner_idx := 0
	for i in range(points.size()):
		if points[i] > points[winner_idx]:
			winner_idx = i
	# Mettre à jour le titre
	title_label.text = "PLAYER %d WINS" % (winner_idx + 1)
	# Afficher chaque score
	_clear_container(scores_container)
	for i in range(points.size()):
		var lbl := Label.new()
		lbl.text = "Player %d : %d pts" % [i + 1, points[i]]
		scores_container.add_child(lbl)


func _on_menu_pressed() -> void:
	# Réinitialiser les scores pour une nouvelle partie
	ScoreManager.reset_all_scores()
	get_tree().change_scene_to_file("res://scenes/menu_scene/main_menu.tscn")


func _clear_container(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()
