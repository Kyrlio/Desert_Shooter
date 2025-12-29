# 🎮 SYSTÈME KILLS & SCORING - TLDR (Too Long; Didn't Read)

## En 30 secondes ⚡

**Vous demandez:** Comment compter les kills et avoir 10 points = victoire?

**Réponse:** C'est fait! ✅

```
Tuez quelqu'un = +1 kill = +1 point
Accumule 10 points = GG tu gagnes! 🏆
```

---

## En 2 minutes 🚀

### Qu'est-ce qui change?
- Avant: 1 round = 1 gagnant = fin
- Après: Multiple rounds → Points s'accumulent → Gagnant à 10 points

### Code affecté (4 fichiers)
```
✏️  player.gd                    +kill_count variable
✏️  hurtbox_component.gd         +set_killer() call
✏️  main.gd                      +ScoreManager.add_points()
✏️  project.godot                +ScoreManager autoload
```

### Nouveau fichier important
```
✨ score_manager.gd              Gère les points globaux
```

### Fichier optionnel
```
✨ score_display.gd              Affiche les scores en jeu
```

---

## Le Système en ASCII Art 🎨

```
ROUND 1:        ROUND 2:        ROUND N:
P1: 2 kills  → P1: 1 kill    → P1: 3 kills
P2: 0 kills  → P2: 3 kills   → P2: 2 kills
P3: 1 kill   → P3: 0 kills   → P3: 0 kills

   SCORES:       SCORES:        SCORES:
   P1: 2/10      P1: 3/10       P1: 6/10
   P2: 0/10      P2: 3/10       P2: 5/10
   P3: 1/10      P3: 0/10       P3: 0/10
   
                                    ...
                                    
                               ROUND FINAL:
                               P1: 4 kills
                               
                               SCORES:
                               P1: 10/10 ✅
                               
                               🏆 PLAYER 1 WINS! 🏆
```

---

## Modifier le système 🔧

**Changer "10" en "5" pour gagner plus tôt:**
```
Ouvrez: autoload/score_manager.gd
Ligne:  const POINTS_TO_WIN: int = 10
Change: const POINTS_TO_WIN: int = 5
Voilà!
```

---

## Documentation

```
START_HERE.md              ← Lisez ça d'abord!
│
├─ README_KILLS_SYSTEM.md  (Complet)
├─ QUICK_START_FR.md       (5 min)
├─ INDEX.md                (Navigation)
├─ SYSTEM_DIAGRAM.md       (Diagrammes)
└─ Autres fichiers         (Détails)
```

---

## ✅ Prêt à tester?

1. Lancez le jeu
2. Joue 10 rounds
3. Observe les points s'accumuler
4. Le premier à 10 gagne! 🏆

---

**C'est tout ce que vous devez savoir pour commencer!** 🎉

Pour les détails → Lisez [START_HERE.md](START_HERE.md)
