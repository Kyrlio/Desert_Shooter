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

var number_players: int = 1
var _previous_points: Array[int] = [0, 0, 0, 0]
var _labels: Array[Label] = []

const COLOR_GREEN := Color(0.2, 0.9, 0.3)
const COLOR_RED := Color(0.9, 0.2, 0.2)
const COLOR_WHITE := Color.WHITE
const COLOR_OUTLINE := Color("47324b")
const OUTLINE_SIZE := 9

var _initialized := false


func _ready() -> void:
	_labels = [player_1_point_label, player_2_point_label, player_3_point_label, player_4_point_label]


func initialize_previous_scores() -> void:
	"""Appeler cette fonction AVANT d'ajouter des points pour capturer les anciens scores"""
	for i in range(4):
		_previous_points[i] = ScoreManager.get_points(i)
	_initialized = true


func update_scores() -> void:
	# Masquer les containers non utilisés
	match number_players:
		1:
			player_2_box_container.visible = false
			player_3_box_container.visible = false
			player_4_box_container.visible = false
		2:
			player_3_box_container.visible = false
			player_4_box_container.visible = false
		3:
			player_4_box_container.visible = false
	
	# Animer chaque score
	for i in range(number_players):
		var old_score: int = _previous_points[i]
		var new_score: int = ScoreManager.get_points(i)
		
		# Animation uniquement si le score a changé
		if old_score != new_score:
			_animate_score_change(_labels[i], old_score, new_score)
			_previous_points[i] = new_score
		else:
			# Afficher le score sans animation
			_labels[i].text = str(new_score) + "\nPTS"
			_labels[i].modulate = COLOR_WHITE


func _animate_score_change(label: Label, old_score: int, new_score: int) -> void:
	"""Anime le changement de score avec effet visuel"""
	var score_diff: int = new_score - old_score
	
	# Déterminer la couleur selon si le score augmente ou diminue
	var anim_color: Color = COLOR_GREEN if score_diff > 0 else COLOR_RED
	
	# Afficher d'abord l'ancien score
	label.text = str(old_score) + "\nPTS"
	label.modulate = COLOR_WHITE
	label.pivot_offset = label.size / 2.0
	
	await get_tree().create_timer(0.4).timeout
	
	# Créer un label temporaire pour l'ancien score qui va disparaître
	var temp_label := Label.new()
	temp_label.text = str(old_score) + "\nPTS"
	temp_label.horizontal_alignment = label.horizontal_alignment
	temp_label.vertical_alignment = label.vertical_alignment
	temp_label.add_theme_font_size_override("font_size", label.get_theme_font_size("font_size"))
	temp_label.add_theme_color_override("font_color", anim_color)
	temp_label.add_theme_color_override("font_outline_color", COLOR_OUTLINE)
	temp_label.add_theme_constant_override("outline_size", OUTLINE_SIZE)
	temp_label.size = label.size
	temp_label.pivot_offset = label.size / 2.0
	# Utiliser un CanvasLayer pour ne pas affecter le layout
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)
	canvas.add_child(temp_label)
	temp_label.global_position = label.global_position
	
	# Masquer le label principal pendant l'animation
	label.modulate.a = 0.0
	
	# Animation de l'ancien score : descend et disparaît
	var tween_temp := create_tween()
	tween_temp.set_parallel(true)
	tween_temp.tween_property(temp_label, "position:y", temp_label.position.y + 30, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween_temp.tween_property(temp_label, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	await get_tree().create_timer(0.15).timeout
	
	# Créer un label temporaire pour le nouveau score qui arrive
	var new_label := Label.new()
	new_label.text = str(new_score) + "\nPTS"
	new_label.horizontal_alignment = label.horizontal_alignment
	new_label.vertical_alignment = label.vertical_alignment
	new_label.add_theme_font_size_override("font_size", label.get_theme_font_size("font_size"))
	new_label.add_theme_color_override("font_color", anim_color)
	new_label.add_theme_color_override("font_outline_color", COLOR_OUTLINE)
	new_label.add_theme_constant_override("outline_size", OUTLINE_SIZE)
	new_label.size = label.size
	new_label.pivot_offset = label.size / 2.0
	canvas.add_child(new_label)
	new_label.position = Vector2(label.global_position.x, label.global_position.y - 30)
	new_label.modulate.a = 0.0
	new_label.scale = Vector2(1.3, 1.3)
	
	
	# Animation du nouveau score : apparaît d'en haut et se place
	var tween_new := create_tween()
	tween_new.set_parallel(true)
	tween_new.tween_property(new_label, "position:y", label.global_position.y, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_new.tween_property(new_label, "modulate:a", 1.0, 0.25).set_ease(Tween.EASE_OUT)
	tween_new.tween_property(new_label, "scale", Vector2.ONE, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	await tween_new.finished
	
	# Transition de la couleur verte vers blanc sur le label temporaire
	var tween_color := create_tween()
	tween_color.tween_property(new_label, "modulate", COLOR_WHITE, 0.5).set_ease(Tween.EASE_OUT)
	
	await tween_color.finished
	
	# Remettre le label principal avec le nouveau score
	label.text = str(new_score) + "\nPTS"
	label.modulate = COLOR_WHITE
	
	# Nettoyer
	canvas.queue_free()
