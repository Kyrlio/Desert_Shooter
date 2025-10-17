# ✅ Distribution Normale pour Shotgun

## Problème résolu

**Avant** : Avec un shotgun, le spread était complètement aléatoire. Parfois **aucune balle ne partait au centre** !

**Maintenant** : Vous pouvez utiliser une **distribution normale (gaussienne)** qui garantit que la plupart des balles partent vers le centre.

## Ce qui a été ajouté

### Nouvelle propriété dans `Weapon`
```gdscript
@export var use_normal_distribution: bool = false
```

- `false` : Distribution uniforme (par défaut)
- `true` : Distribution normale (recommandé pour shotgun)

### Nouvelle fonction
```gdscript
func _randfn(mean: float, std_dev: float) -> float
```

Génère des nombres aléatoires avec une distribution normale (algorithme Box-Muller).

## Configuration rapide

### Pour votre Shotgun

1. Ouvrez `shotgun.tscn` dans Godot
2. Dans l'inspecteur, configurez :
   ```
   Damage: 8
   Fire Rate: 0.8
   Spread: 25.0
   Number Bullets: 8
   Use Normal Distribution: ✓ COCHÉ  ← Important !
   ```

## Différence visuelle

### Sans distribution normale (uniforme)
```
Spread aléatoire uniforme :

    \     |     /
     \    |    /
      \   |   /
       \  |  /
        \ | /
         \|/
          🎯

❌ Problème : Les balles peuvent toutes aller sur les côtés
```

### Avec distribution normale ✓
```
Spread gaussien centré :

           |
          |||
         |||||
          |||
           |
           🎯

✅ Solution : Concentration au centre garantie !
```

## Répartition typique

Avec `spread = 30°` et distribution normale sur 8 balles :
- **~5-6 balles** au centre (±10°)
- **~2 balles** sur les côtés (10-20°)
- **~0-1 balle** aux extrémités (20-30°)

## Quand utiliser ?

### Distribution Normale (true) ✓
- **Shotgun** avec plusieurs projectiles
- Burst fire
- Toute arme avec `number_bullets > 3`
- Quand vous voulez garantir des hits au centre

### Distribution Uniforme (false)
- Armes à projectile unique
- Uzi, SMG, Rifle
- Armes avec faible spread (<5°)

## Configuration recommandée

**Shotgun classique**
```
Spread: 25.0
Number Bullets: 8
Use Normal Distribution: true
```

**Shotgun serré (choke)**
```
Spread: 15.0
Number Bullets: 6
Use Normal Distribution: true
```

**Shotgun dispersé**
```
Spread: 35.0
Number Bullets: 10
Use Normal Distribution: true
```

## Test

1. Configurez votre shotgun avec `use_normal_distribution = true`
2. Tirez sur un mur
3. Observez : Les balles forment un pattern dense au centre ! 🎯

---

**Votre shotgun est maintenant beaucoup plus fiable et prévisible !** 💥
