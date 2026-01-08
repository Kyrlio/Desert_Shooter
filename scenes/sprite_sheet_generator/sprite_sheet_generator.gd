extends Node2D

# --- CONFIGURATION ---
@export var nom_fichier: String = "mon_effet.png"
@export var colonnes: int = 8       # Nombre d'images à l'horizontale
@export var lignes: int = 4         # Nombre d'images à la verticale
@export var duree_capture: float = 2.0 # Durée totale de l'animation en secondes

@onready var viewport = $ViewportCapture
@onready var particles: GPUParticles2D = $ViewportCapture/GPUParticles2D

func _ready():
	# On attend un tout petit peu que Godot initialise le viewport
	await get_tree().process_frame
	await get_tree().process_frame
	
	capturer_spritesheet()

func capturer_spritesheet():
	print("Début de la capture...")
	
	# 1. Calculs de base
	var frame_width = viewport.size.x
	var frame_height = viewport.size.y
	var total_frames = colonnes * lignes
	var sheet_width = frame_width * colonnes
	var sheet_height = frame_height * lignes
	
	# Création de l'image vide qui recevra tout (la spritesheet finale)
	var spritesheet = Image.create(sheet_width, sheet_height, false, Image.FORMAT_RGBA8)
	
	# 2. Préparation des particules
	particles.emitting = true
	
	if particles.one_shot:
		particles.restart()
		
	# Calcul du temps d'attente entre chaque frame
	var wait_time = duree_capture / float(total_frames)
	
	# 3. Boucle de capture
	for i in range(total_frames):
		# On calcule la position X et Y de la case actuelle dans la grille
		var grid_x = (i % colonnes) * frame_width
		var grid_y = (i / colonnes) * frame_height
		
		# On capture l'image actuelle du viewport
		var img = viewport.get_texture().get_image()
		
		# On "colle" (blit) cette image dans la grande spritesheet
		spritesheet.blit_rect(img, Rect2(0, 0, frame_width, frame_height), Vector2(grid_x, grid_y))
		
		# On attend le temps nécessaire pour la prochaine frame
		await get_tree().create_timer(wait_time).timeout
	
	# 4. Sauvegarde
	# On sauvegarde à la racine du projet (res://) ou dans le dossier user://
	var chemin_complet = "res://" + nom_fichier
	var erreur = spritesheet.save_png(chemin_complet)
	
	if erreur == OK:
		print("Succès ! Spritesheet sauvegardée ici : ", chemin_complet)
		# Petit hack pour rafraîchir l'éditeur de fichiers Godot
		var editor_fs = EditorInterface.get_resource_filesystem() if Engine.is_editor_hint() else null
		if editor_fs: editor_fs.scan()
	else:
		printerr("Erreur lors de la sauvegarde : ", erreur)
		
	# Optionnel : Quitter après la capture
	get_tree().quit()
