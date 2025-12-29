# 🎮 Système de Comptage de Kills - Guide Rapide

## C'est quoi ? 🤔

Un système qui compte combien de joueurs vous tuez, et le premier à 10 kills/10 points gagne le match entier!

## Comment ça marche en pratique ? 🎯

### Round 1:
- **Player 1** tue 2 joueurs → 2 kills → **2 points**
- **Player 2** tue 1 joueur → 1 kill → **1 point**
- Player 3 n'a tué personne → 0 kills → **0 points**
- Scores: P1: 2/10 | P2: 1/10 | P3: 0/10

### Round 2:
- **Player 1** tue 1 joueur → 1 kill → **+1 point** (total: 3/10)
- **Player 2** tue 3 joueurs → 3 kills → **+3 points** (total: 4/10)
- Scores: P1: 3/10 | P2: 4/10 | P3: 0/10

### Round 3:
- **Player 2** tue 6 joueurs → 6 kills → **+6 points** (total: 10/10) ✅
- **🏆 PLAYER 2 WINS THE MATCH! 🏆**

## Fichiers Affectés 📄

| Fichier | Changement |
|---------|-----------|
| `player.gd` | +variable `kill_count` pour tracker les kills |
| `hurtbox_component.gd` | Enregistre qui attaque |
| `main.gd` | Ajoute les kills comme points |
| `project.godot` | Ajoute `ScoreManager` autoload |
| ✨ `score_manager.gd` | **NOUVEAU** - Gère les points globaux |

## Code Important ⚡

### Dans `player.gd._on_died()`:
Quand un joueur meurt, on incremente le kill du tueur:
```gdscript
if killer_player_index != -1:
    var killer = ControllerManager.player_nodes.get(killer_player_index)
    if killer and is_instance_valid(killer):
        killer.kill_count += 1  # +1 kill pour le tueur!
```

### Dans `main.gd.end_round()`:
À la fin d'une round, on convertit les kills en points:
```gdscript
for player in all_players:
    var kill_count = player.get_kill_count()
    if kill_count > 0:
        get_node("/root/ScoreManager").add_points(
            player.player_index,  # Quel joueur
            kill_count            # Combien de points
        )
```

### Dans `score_manager.gd`:
Vérifie si quelqu'un a atteint 10 points:
```gdscript
if player_points[player_index] >= POINTS_TO_WIN:
    victory.emit(player_index)  # GAGNANT!
```

## Cas Spéciaux 🎪

1. **Tué par le vide** → Pas de tueur identifié → 0 kill compté
2. **Dégâts environnement** → owner_player_index = -1 → 0 kill
3. **Self-kill** → On ne compte pas (logique: pas tué par soi-même)
4. **Dernier survivant** → Gagne la round seulement s'il a des kills

## Test Rapide ✅

1. Lancez 2 rounds test
2. Round 1: P1 tue tout le monde = 1 point
3. Round 2: P1 ne tue personne = 0 point  
4. Round 3-10: P1 tue 1 joueur par round = +1 point
5. Round 11: P1 devrait avoir 10 points → **Victoire!**

## Paramètres à Modifier 🔧

Dans `score_manager.gd`:
```gdscript
const POINTS_TO_WIN: int = 10      # Changer ici pour 5, 15, 20, etc.
const MAX_PLAYERS: int = 4         # Nombre de joueurs (laissez 4)
```

---

**C'est tout! Le système fonctionne automatiquement maintenant. 🚀**
