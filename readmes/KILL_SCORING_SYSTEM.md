# Système de Comptage de Kills et Scoring Global

## Vue d'ensemble

Ce système permet de :
1. **Compter les kills** pendant chaque round
2. **Convertir les kills en points** à la fin de chaque round
3. **Tracker les points globaux** d'une partie complète
4. **Déclarer un gagnant** quand un joueur atteint 10 points

## Comment ça fonctionne ?

### 1. Comptage des Kills (Player.gd)
- Chaque joueur possède une variable `kill_count` qui démarre à 0 à chaque round
- Quand un joueur subit des dégâts, on enregistre l'index du joueur qui l'a blessé via `killer_player_index`
- Quand un joueur meurt, on incrémente le `kill_count` du tueur

```gdscript
# Dans player.gd._on_died()
if killer_player_index != -1 and killer_player_index != player_index:
    var killer = ControllerManager.player_nodes.get(killer_player_index)
    if killer and is_instance_valid(killer):
        killer.kill_count += 1
```

### 2. Conversion Kills → Points (main.gd)
À la fin d'un round, quand un seul joueur reste en vie :
- On parcourt tous les joueurs et récupère leur `kill_count`
- On ajoute ces points au `ScoreManager` avec `add_points(player_index, kill_count)`

```gdscript
# Dans main.gd.end_round()
for player in all_players:
    if is_instance_valid(player) and player is Player:
        var kill_count = player.get_kill_count()
        if kill_count > 0:
            ScoreManager.add_points(player.player_index, kill_count)
```

### 3. Tracking des Points Globaux (score_manager.gd)
Le `ScoreManager` est un autoload qui :
- Maintient un tableau `player_points[4]` avec les points de chaque joueur
- Émet un signal `points_changed` quand un joueur gagne des points
- Émet un signal `victory` quand un joueur atteint 10 points

```gdscript
# Utilisation
ScoreManager.add_points(player_index, points)  # Ajouter des points
ScoreManager.get_points(player_index)  # Obtenir les points d'un joueur
ScoreManager.reset_all_scores()  # Réinitialiser
```

### 4. Affichage des Scores (score_display.gd)
Un composant optionnel qui affiche les scores de tous les joueurs en temps réel

### 5. Victoire Globale (main.gd)
Quand `ScoreManager` émet le signal `victory`, `main.gd` :
- Affiche "PLAYER X WINS THE MATCH!"
- Attend 5 secondes
- Réinitialise les scores
- Lance un nouveau round

## Schéma de flux

```
DÉGÂTS REÇUS
    ↓
HurtboxComponent._handle_hit()
    ↓
set_killer(attacker_index)
    ↓
Joueur MEURT
    ↓
_on_died()
    ↓
kill_count += 1 (du tueur)
    ↓
FIN DU ROUND (1 survivant)
    ↓
end_round()
    ↓
ScoreManager.add_points(player_index, kill_count)
    ↓
victory_check: points >= 10?
    ↓
_on_global_victory() ou prochain round
```

## Configuration

- **Points pour gagner** : 10 (défini dans `ScoreManager.POINTS_TO_WIN`)
- **Points par kill** : 1 (chaque kill = 1 point)
- **Max joueurs** : 4

## Cas limites

- **Mort au vide** : Le joueur qui est tombé dans le vide n'a pas de killer (killer_player_index = -1), donc pas de kill compté
- **Dégâts environnement** : owner_player_index = -1, donc pas de killer identifié
- **Self-kill** : Si un joueur se tue lui-même (dégâts circulaires), on ne compte pas le kill
- **Derniers survivants** : Le dernier joueur en vie ne gagne pas de points supplémentaires (sauf pour ses kills)

## À améliorer

1. **Ajouter une UI Score Display** dans les scènes de jeu pour voir les points en temps réel
2. **Bonus supplémentaire** : Points bonus pour être le dernier survivant
3. **Statistiques** : Tracker K/D ratio, multi-kills, etc.
4. **Persistance** : Sauvegarder les meilleurs scores
