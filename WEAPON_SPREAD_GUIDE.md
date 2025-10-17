# 🎯 Guide du Système de Dispersion (Spread)

## Vue d'ensemble

Le système de dispersion permet de rendre certaines armes plus ou moins précises. Les balles sont déviées aléatoirement selon l'angle de dispersion configuré.

## Fonctionnement

### Propriété `spread`

La propriété `spread` dans la classe `Weapon` contrôle la dispersion :

- **Valeur** : 0.0 à 45.0 degrés
- **0.0** = Tir parfaitement précis (pas de dispersion)
- **5.0** = Légère dispersion (bon pour rifles)
- **15.0** = Dispersion moyenne (SMG, fusils automatiques)
- **30.0+** = Grosse dispersion (shotguns, armes automatiques rapides)

### Comment ça marche ?

1. Quand l'arme tire, la direction de base est calculée (vers la souris)
2. Un angle aléatoire entre `-spread` et `+spread` est généré
3. Cet angle est ajouté à la direction de base
4. La balle part dans cette nouvelle direction

## Configuration des armes

### Rifle (précis)
```gdscript
display_name = "Rifle"
fire_rate = 0.2
spread = 0.5  # Très précis
```

### Uzi (dispersé)
```gdscript
display_name = "Uzi"
fire_rate = 0.08  # Tire très vite
spread = 12.0  # Bonne dispersion pour compenser
```

### Shotgun (exemple)
```gdscript
display_name = "Shotgun"
fire_rate = 0.8
spread = 25.0  # Grosse dispersion
```

### Pistolet (exemple)
```gdscript
display_name = "Pistol"
fire_rate = 0.3
spread = 3.0  # Légère dispersion
```

## Configurer dans l'éditeur Godot

1. Sélectionnez votre scène d'arme (rifle.tscn, uzi.tscn, etc.)
2. Dans l'inspecteur, trouvez la propriété **"Spread"**
3. Ajustez la valeur avec le slider (0-45 degrés)
4. Testez dans le jeu pour trouver le bon équilibre

## Équilibrage suggéré

### Principe général
Plus une arme tire vite, plus elle devrait avoir de dispersion pour l'équilibrer.

| Type d'arme | Fire Rate | Spread suggéré |
|-------------|-----------|----------------|
| Sniper      | 1.0-2.0s  | 0.0-1.0°       |
| Rifle       | 0.15-0.3s | 0.5-3.0°       |
| Pistolet    | 0.25-0.4s | 2.0-5.0°       |
| SMG/Uzi     | 0.05-0.1s | 8.0-15.0°      |
| Shotgun     | 0.6-1.0s  | 20.0-35.0°     |
| Minigun     | 0.03-0.05s| 15.0-25.0°     |

## Visualisation

```
spread = 0° (Précis)
     |
     ↓
    🎯

spread = 15° (Moyen)
   \ | /
    \|/
     ↓
    🎯

spread = 30° (Dispersé)
  \  |  /
   \ | /
    \|/
     ↓
    🎯
```

## Code technique

La fonction `_apply_spread()` dans `weapon.gd` :

```gdscript
func _apply_spread(direction: Vector2) -> Vector2:
    if spread <= 0.0:
        return direction.normalized()
    
    var spread_radians = deg_to_rad(spread)
    var random_angle = randf_range(-spread_radians, spread_radians)
    var base_angle = direction.angle()
    var final_angle = base_angle + random_angle
    
    return Vector2(cos(final_angle), sin(final_angle))
```

## Conseils d'équilibrage

1. **Commencez petit** : Testez avec des petites valeurs et augmentez progressivement
2. **Compensez la cadence** : Armes rapides = plus de spread
3. **Testez en jeu** : La dispersion se ressent mieux en jouant
4. **Considérez la distance** : Plus de spread = moins efficace à longue distance
5. **Variété** : Donnez à chaque arme une identité unique

## Exemples de situations

### Combat rapproché
- Spread élevé acceptable
- L'Uzi excelle ici avec son fire rate élevé

### Combat à distance
- Spread faible nécessaire
- Le Rifle est roi avec sa précision

### Combat moyen
- Spread moyen recommandé
- Pistolet ou fusil d'assaut

## Modifications futures possibles

- [ ] Dispersion qui augmente avec le tir continu (recoil)
- [ ] Dispersion réduite en mode visée
- [ ] Différents patterns de dispersion (circulaire, horizontal, etc.)
- [ ] Affichage visuel du cone de dispersion
- [ ] Armes avec dispersion dynamique selon le mouvement

Bon équilibrage ! 🎮
