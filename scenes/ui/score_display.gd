extends CanvasLayer

## Affiche les points globaux de chaque joueur pendant le match

const MAX_PLAYERS := 4

@onready var score_container: VBoxContainer = $VBoxContainer

# Labels for each player's score
var score_labels: Array[Label] = []


func _ready() -> void:
	# Create score labels for each player
	for i in range(MAX_PLAYERS):
		var label = Label.new()
		label.text = "P%d: %d/10" % [i + 1, 0]
		label.add_theme_font_size_override("font_size", 16)
		score_container.add_child(label)
		score_labels.append(label)
	
	# Connect to ScoreManager
	if ScoreManager.points_changed.is_connected(_on_points_changed):
		ScoreManager.points_changed.disconnect(_on_points_changed)
	ScoreManager.points_changed.connect(_on_points_changed)
	
	# Initial refresh
	_refresh_all_scores()


func _refresh_all_scores() -> void:
	"""Rafraîchir l'affichage de tous les scores"""
	var all_points = ScoreManager.get_all_points()
	for i in range(min(all_points.size(), MAX_PLAYERS)):
		if i < score_labels.size():
			score_labels[i].text = "P%d: %d/10" % [i + 1, all_points[i]]


func _on_points_changed(player_index: int, points: int) -> void:
	"""Appelé quand les points d'un joueur changent"""
	if player_index >= 0 and player_index < score_labels.size():
		score_labels[player_index].text = "P%d: %d/10" % [player_index + 1, points]
		
		# Animation simple pour montrer le changement
		var label = score_labels[player_index]
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BOUNCE)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.2).from(Vector2.ONE)
		tween.tween_property(label, "scale", Vector2.ONE, 0.1)
