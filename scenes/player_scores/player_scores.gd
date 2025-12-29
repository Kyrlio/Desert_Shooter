class_name PlayerScores
extends CanvasLayer

@onready var player_1_point_label: Label = %Player1PointLabel
@onready var player_2_point_label: Label = %Player2PointLabel
@onready var player_3_point_label: Label = %Player3PointLabel
@onready var player_4_point_label: Label = %Player4PointLabel


func update_scores() -> void:
	player_1_point_label.text = str(ScoreManager.get_points(0)) + "\nPTS"
	player_2_point_label.text = str(ScoreManager.get_points(1)) + "\nPTS"
	player_3_point_label.text = str(ScoreManager.get_points(2)) + "\nPTS"
	player_4_point_label.text = str(ScoreManager.get_points(3)) + "\nPTS"
