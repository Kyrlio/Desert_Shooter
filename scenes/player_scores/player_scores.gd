class_name PlayerScores
extends CanvasLayer

# LABELS
@onready var player_1_point_label: Label = %Player1PointLabel
@onready var player_2_point_label: Label = %Player2PointLabel
@onready var player_3_point_label: Label = %Player3PointLabel
@onready var player_4_point_label: Label = %Player4PointLabel

# CONTAINER
@onready var player_1_box_container: HBoxContainer = %Player1HBoxContainer
@onready var player_2_box_container: HBoxContainer = %Player2HBoxContainer
@onready var player_3_box_container: HBoxContainer = %Player3HBoxContainer
@onready var player_4_box_container: HBoxContainer = %Player4HBoxContainer


func update_scores() -> void:
	match ControllerManager.get_number_players():
		1:
			player_1_point_label.text = str(ScoreManager.get_points(0)) + "\nPTS"
			player_2_box_container.visible = false
			player_3_box_container.visible = false
			player_4_box_container.visible = false
		2:
			player_1_point_label.text = str(ScoreManager.get_points(0)) + "\nPTS"
			player_2_point_label.text = str(ScoreManager.get_points(1)) + "\nPTS"
			player_3_box_container.visible = false
			player_4_box_container.visible = false
		3:
			player_1_point_label.text = str(ScoreManager.get_points(0)) + "\nPTS"
			player_2_point_label.text = str(ScoreManager.get_points(1)) + "\nPTS"
			player_3_point_label.text = str(ScoreManager.get_points(2)) + "\nPTS"
			player_4_box_container.visible = false
		4:
			player_1_point_label.text = str(ScoreManager.get_points(0)) + "\nPTS"
			player_2_point_label.text = str(ScoreManager.get_points(1)) + "\nPTS"
			player_3_point_label.text = str(ScoreManager.get_points(2)) + "\nPTS"
			player_4_point_label.text = str(ScoreManager.get_points(3)) + "\nPTS"
	
	#player_1_point_label.text = str(ScoreManager.get_points(0)) + "\nPTS"
	#player_2_point_label.text = str(ScoreManager.get_points(1)) + "\nPTS"
	#player_3_point_label.text = str(ScoreManager.get_points(2)) + "\nPTS"
	#player_4_point_label.text = str(ScoreManager.get_points(3)) + "\nPTS"
