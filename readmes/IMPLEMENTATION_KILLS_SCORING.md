## Système de Kills et Scoring Multi-Rounds 🎮

J'ai implémenté un système complet de comptage de kills et de scoring global pour votre jeu. Voici comment ça fonctionne :

### 📊 Résumé du Système

**Le concept :**
- Chaque joueur compte le nombre de kills qu'il fait pendant une round
- À la fin de la round, chaque kill = 1 point
- Les points s'accumulent à travers plusieurs rounds
- **Le premier à atteindre 10 points gagne le match entier** 🏆

### 🔧 Fichiers Modifiés / Créés

#### 1. **Fichiers Créés**
- `autoload/score_manager.gd` - Gestionnaire des scores globaux
- `autoload/score_manager.gd` - Configuration de l'autoload
- `scenes/ui/score_display.gd` - UI pour afficher les scores (optionnel)
- `scenes/ui/score_display.tscn` - Scène d'affichage des scores
- `KILL_SCORING_SYSTEM.md` - Documentation technique détaillée

#### 2. **Fichiers Modifiés**

**player.gd** (`/scenes/entities/player/player.gd`)
```gdscript
# Variables ajoutées :
var kill_count: int = 0                 # Kills dans la round actuelle
var killer_player_index: int = -1       # Qui a tué ce joueur

# Méthodes ajoutées :
func get_kill_count() -> int            # Récupérer les kills
func set_killer(killer_index: int)      # Enregistrer le tueur
```

**hurtbox_component.gd** (`/scenes/component/hurtbox_component.gd`)
- Enregistre l'index du joueur qui attaque quand les dégâts sont appliqués

**main.gd** (`/scenes/main_scene/main.gd`)
- À la fin d'une round : ajoute les kills comme points via `ScoreManager`
- Écoute le signal de victoire pour afficher "PLAYER X WINS THE MATCH!"
- Réinitialise les scores après la victoire globale

**project.godot**
- Enregistre `ScoreManager` en tant qu'autoload

---

### 🎯 Flux du Système

```
1. DÉGÂTS → HurtboxComponent détecte l'attaquant
2. MORT → Player._on_died() incrémente kill_count du tueur
3. FIN ROUND → Main.end_round() convertit kills en points
4. POINTS AJOUTÉS → ScoreManager.add_points() met à jour
5. CHECK VICTOIRE → Si points >= 10, gagnant déclaré!
6. REBOOT → Scores réinitialisés, nouveau round
```

---

### 💡 Utilisation

#### Récupérer les points d'un joueur
```gdscript
var points = get_node("/root/ScoreManager").get_points(player_index)
```

#### Afficher les points (optionnel)
Ajoutez cette scène au niveau de jeu :
```gdscript
var score_ui = load("res://scenes/ui/score_display.tscn").instantiate()
add_child(score_ui)
```

#### Réinitialiser les scores
```gdscript
get_node("/root/ScoreManager").reset_all_scores()
```

---

### ⚙️ Configuration

Tous les paramètres sont dans `score_manager.gd` :
```gdscript
const POINTS_TO_WIN: int = 10      # Points pour gagner
const MAX_PLAYERS: int = 4         # Nombre max de joueurs
```

Pour changer le nombre de points pour gagner, modifiez simplement `POINTS_TO_WIN`

---

### ✅ Cas d'Usage

| Situation | Résultat |
|-----------|----------|
| Player 1 tue Player 2 | Player 1: +1 kill |
| Player 1 accumule 10 kills sur 3 rounds | Player 1: 10 points → Victoire! |
| Player 2 tombe dans le vide | Aucun kill (pas de tueur) |
| Dégâts environnement | Aucun kill compté |

---

### 🚀 Prochaines Étapes Optionnelles

1. **Afficher les kills en temps réel** dans l'HUD pendant la round
2. **Points bonus** pour être le dernier survivant (+5 points par exemple)
3. **Multi-kills bonus** (3 kills en 10 secondes = bonus)
4. **Statistiques** : K/D ratio, best streak, etc.
5. **Persistance** : Sauvegarder le meilleur score

---

### 📝 Notes

- Les scores se réinitialisent quand le jeu se termine
- Chaque joueur doit avoir un `player_index` unique (0, 1, 2, 3)
- Le système fonctionne aussi bien en solo qu'en 4 joueurs
- L'affichage du gagnant global attend 5 secondes avant de lancer la suite

---

**Amusez-vous! 🎮**
