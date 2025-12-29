# 📖 Index Documentation - Système de Kills & Scoring

## 🚀 Commencer Rapidement

**→ Lire d'abord:** [`QUICK_START_FR.md`](QUICK_START_FR.md) (5 min)

Un résumé simple et clair du système en français.

---

## 📚 Documentation Complète

### Pour Comprendre le Système
1. **[IMPLEMENTATION_KILLS_SCORING.md](IMPLEMENTATION_KILLS_SCORING.md)** - Vue d'ensemble
   - Résumé complet du système
   - Fichiers modifiés/créés
   - Code exemple
   - Configuration

2. **[SYSTEM_DIAGRAM.md](SYSTEM_DIAGRAM.md)** - Diagrammes visuels
   - Flux détaillé de chaque étape
   - État des variables
   - Exemple complet sur 3 rounds

3. **[KILL_SCORING_SYSTEM.md](KILL_SCORING_SYSTEM.md)** - Architecture technique
   - Schéma de flux
   - Cas limites
   - Améliorations futures

### Pour Développer / Modifier
4. **[IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)** - Validation
   - Checklist d'implémentation
   - Tests à effectuer
   - Variables à monitorer

---

## 🔧 Fichiers du Système

### Créés (Nouveaux)
```
autoload/
  └─ score_manager.gd ............................ Gestionnaire de scores
  
scenes/ui/
  ├─ score_display.gd ........................... UI affichage scores (optionnel)
  └─ score_display.tscn ......................... Scène correspondante
```

### Modifiés (Existants)
```
scenes/entities/player/
  └─ player.gd .................................. +kill_count, +set_killer()

scenes/component/
  └─ hurtbox_component.gd ........................ Enregistre l'attaquant

scenes/main_scene/
  └─ main.gd .................................... Convertit kills→points, victoire

autoload/
  (pas de modification, utilisation seulement)

project.godot .................................. +ScoreManager autoload
```

---

## 💡 Concepts Clés

### Le Flux en 3 Étapes

| Étape | Quand | Quoi |
|-------|-------|------|
| 1️⃣ **DÉGÂTS** | Pendant la round | `set_killer()` enregistre l'attaquant |
| 2️⃣ **MORT** | Fin d'une vie | `kill_count` incrémenté |
| 3️⃣ **POINTS** | Fin de round | kills convertis en points globaux |

### Les Variables Importantes

```gdscript
# Pendant une round (réinitialisé chaque round)
player.kill_count                  # Nombre de joueurs tués (0-5)
player.killer_player_index         # Qui m'a tué? (-1 si aucun)

# Globalement (persiste entre les rounds)
ScoreManager.player_points[4]      # Points cumulés de chaque joueur
ScoreManager.POINTS_TO_WIN         # Nombre de points pour gagner (10)
```

### Les Signaux

```gdscript
ScoreManager.points_changed.emit(player_index, points)  # Points changés
ScoreManager.victory.emit(player_index)                 # Quelqu'un a gagné!
```

---

## 🎯 Configuration

**Nombre de points pour gagner** → Modifiez dans `score_manager.gd`:
```gdscript
const POINTS_TO_WIN: int = 10  # Changez cette valeur (5, 15, 20, etc.)
```

---

## 🧪 Test Rapide

Pour tester le système:

1. Lancer 1ère round, P1 tue P2 → P1 obtient 1 point
2. Lancer 2ème round, P1 tue P2 → P1 a 2 points
3. Répéter 10 fois → P1 gagne (10 points)
4. Vérifier: "PLAYER 1 WINS THE MATCH!"

---

## ❓ FAQ

**Q: Combien de points par kill?**
A: 1 point par kill (à la fin de la round)

**Q: Les scores se réinitialisent?**
A: Oui, après la victoire globale. Chaque partie commence à 0-0-0-0.

**Q: Qui gagne les points du dernier survivant?**
A: Seulement ses kills. Pas de bonus supplémentaire.

**Q: Peut-on avoir un kill en tombant dans le vide?**
A: Non, pas de tueur identifié.

**Q: Les dégâts environnement comptent?**
A: Non, owner_player_index = -1 n'est pas un kill.

---

## 📝 Résumé des Changements

### Avant
- Jeu: 1 round = 1 vainqueur = fin
- Pas de scoring persistant entre les rounds

### Après
- Jeu: Multiple rounds
- Kills comptabilisés et convertis en points
- Premier à 10 points = maître du match! 🏆

---

## 🚀 Prochaines Étapes (Optionnel)

1. **Afficher score en temps réel** → Intégrer score_display.tscn
2. **Bonus supplémentaires** → +5 points pour survie ultime
3. **Multi-kills** → 3 kills en 10s = double points!
4. **Statistiques** → K/D ratio, best streak, etc.
5. **Persistance** → Sauvegarder meilleur score

---

**Questions? Consultez les fichiers individuels pour plus de détails! 📚**
