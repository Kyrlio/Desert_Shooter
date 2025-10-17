# 🎯 Guide des Distributions de Spread

## Nouveau système : Distribution Normale

Pour les armes comme le **shotgun**, une distribution normale (gaussienne) garantit que la plupart des balles partent vers le centre, avec une concentration décroissante vers les bords.

## Les deux types de distribution

### 1. Distribution Uniforme (par défaut)
`use_normal_distribution = false`

Toutes les directions dans le cone de spread ont la **même probabilité**.

```
Visualisation (spread = 30°)

      \   |   /
       \  |  /
        \ | /
         \|/
          🎯

Toutes les zones équiprobables
```

**Utilisation** :
- Armes automatiques (Uzi, SMG)
- Rifles avec léger spread
- Pistolets

### 2. Distribution Normale (gaussienne)
`use_normal_distribution = true`

La plupart des balles vont vers le **centre**, peu vont sur les bords.

```
Visualisation (spread = 30°, 8 balles)

       |
      |||
     |||||
      |||
       |
       🎯

Centre très dense, bords rares
```

**Utilisation** :
- **Shotgun** (recommandé !)
- Armes avec beaucoup de projectiles
- Burst fire avec spread

## Configuration dans Godot

### Pour un Shotgun

1. Ouvrez `shotgun.tscn`
2. Dans l'inspecteur :
   ```
   Display Name: "Shotgun"
   Damage: 8
   Fire Rate: 0.8
   Spread: 25.0
   Number Bullets: 8
   Use Normal Distribution: ✓ (coché)  ← Nouveau !
   ```

### Pour un Rifle/Uzi

```
Display Name: "Rifle"
Damage: 10
Fire Rate: 0.2
Spread: 1.0
Number Bullets: 1
Use Normal Distribution: ☐ (décoché)
```

## Comparaison visuelle

### Shotgun avec 8 balles, spread 25°

**Sans distribution normale** (uniforme) :
```
        \  |  /
         \ | /
      \   \|/   /
       \   |   /
        \  |  /
         \ | /
          \|/
           🎯

❌ Problème : Parfois aucune balle au centre !
```

**Avec distribution normale** :
```
           |
          |||
         |||||
          |||
           |
           🎯

✅ Solution : Toujours des balles au centre !
```

## Mathématiques (pour les curieux)

### Distribution Normale

La fonction `_randfn()` utilise l'algorithme **Box-Muller** :

```gdscript
func _randfn(mean: float, std_dev: float) -> float:
    var u1 = randf()
    var u2 = randf()
    var z0 = sqrt(-2.0 * log(u1)) * cos(TAU * u2)
    return mean + z0 * std_dev
```

- **mean** : Centre de la distribution (0° dans notre cas)
- **std_dev** : Écart-type = `spread / 3`
  - ~68% des balles dans ±1σ (±spread/3)
  - ~95% des balles dans ±2σ (±2*spread/3)
  - ~99.7% des balles dans ±3σ (±spread)

### Répartition des balles

Avec `spread = 30°` et distribution normale :

| Zone | Angle | % de balles |
|------|-------|-------------|
| Centre | 0° ± 10° | ~68% |
| Moyen | 10° ± 20° | ~27% |
| Bord | 20° ± 30° | ~5% |

## Exemples de configuration

### Shotgun Standard
```
Damage: 8
Fire Rate: 0.8
Spread: 25.0
Number Bullets: 8
Use Normal Distribution: true

→ Pattern dense au centre, quelques balles sur les côtés
→ Efficace 0-5m
```

### Shotgun Dispersé (combat rapproché)
```
Damage: 6
Fire Rate: 0.6
Spread: 35.0
Number Bullets: 10
Use Normal Distribution: true

→ Pattern large mais centré
→ Efficace 0-3m
```

### Shotgun Précis (choke serré)
```
Damage: 10
Fire Rate: 1.0
Spread: 15.0
Number Bullets: 6
Use Normal Distribution: true

→ Pattern très groupé
→ Efficace 0-8m
```

### Burst Rifle (3 balles)
```
Damage: 8
Fire Rate: 0.4
Spread: 5.0
Number Bullets: 3
Use Normal Distribution: true

→ 3 balles très proches
→ Simule un recoil naturel
```

## Quand utiliser chaque distribution ?

### Distribution Uniforme ☐
- ✅ Une seule balle (spread = précision naturelle)
- ✅ Armes automatiques (Uzi, SMG)
- ✅ Armes avec peu de spread (<10°)
- ✅ Pattern de dispersion large souhaité

### Distribution Normale ✓
- ✅ Shotgun (multiples projectiles)
- ✅ Burst fire
- ✅ Armes avec beaucoup de spread (>15°)
- ✅ Pattern centré souhaité
- ✅ Garantie de toucher la cible au centre

## Test en jeu

Pour comparer les deux distributions :

1. **Créez 2 shotguns identiques**
2. **L'un avec** `use_normal_distribution = true`
3. **L'autre avec** `use_normal_distribution = false`
4. **Tirez sur un mur**
5. **Observez** la différence de pattern !

### Résultat attendu

**Uniforme** : Pattern circulaire, trous possibles au centre
**Normale** : Pattern en cloche, dense au centre

## Conseils

- 💡 Pour shotgun : **TOUJOURS** utiliser la distribution normale
- 💡 Pour armes précises : Distribution uniforme suffit
- 💡 Plus `number_bullets` est élevé, plus la normale est utile
- 💡 Spread + normale = Pattern réaliste et prévisible

---

**Votre shotgun aura maintenant toujours des balles au centre !** 🎯
