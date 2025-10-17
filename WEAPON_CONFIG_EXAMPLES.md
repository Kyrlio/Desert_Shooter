# 🎯 Configuration Spread - Exemples Pratiques

## Configuration rapide pour vos armes actuelles

### Rifle (rifle.tscn)
**Dans l'inspecteur Godot :**
- Display Name: `Rifle`
- Damage: `10.0`
- Fire Rate: `0.2`
- **Spread: `1.0`** ← Nouvelle propriété !
- Muzzle Point Path: `BarrelPosition`

**Caractère :** Arme de précision, efficace à longue distance

---

### Uzi (uzi.tscn)
**Dans l'inspecteur Godot :**
- Display Name: `Uzi`
- Damage: `5.0`
- Fire Rate: `0.08`
- **Spread: `12.0`** ← Nouvelle propriété !
- Muzzle Point Path: `BarrelPosition`

**Caractère :** Arme automatique rapide, efficace à courte distance

---

## Test immédiat

1. **Lancez votre jeu**
2. **Testez le Rifle** (touche ← si pas équipé)
   - Les balles devraient être très regroupées
   - Précis même à distance
3. **Testez l'Uzi** (touche →)
   - Les balles devraient être dispersées
   - Moins efficace à distance mais dévastation rapprochée

## Visualisation du comportement

### Rifle avec spread = 1.0°
```
Distance courte (efficace)    Distance longue (efficace)
        |                              |
        |                              |
        🎯                            🎯
```

### Uzi avec spread = 12.0°
```
Distance courte (efficace)    Distance longue (moins efficace)
      \ | /                        \     |     /
       \|/                          \    |    /
        🎯                           \   |   /
                                      \  |  /
                                       \ | /
                                        🎯
```

## Modifications suggérées

Si vous voulez ajuster l'équilibrage :

### Rendre le Rifle encore plus précis
- Spread: `0.3` - `0.5` (sniper-like)
- Fire Rate: `0.25` (un peu plus lent)

### Rendre l'Uzi encore plus chaotique
- Spread: `18.0` - `20.0`
- Fire Rate: `0.06` (encore plus rapide)
- Damage: `4.0` (compenser par le volume de feu)

### Créer un Pistolet équilibré
- Spread: `4.0`
- Fire Rate: `0.3`
- Damage: `7.0`

## Comment modifier dans Godot

1. **Ouvrez la scène de l'arme** (ex: `res://scenes/entities/weapons/rifle.tscn`)
2. **Sélectionnez le nœud racine** (celui avec le script Weapon.gd)
3. **Dans l'Inspecteur**, descendez jusqu'à voir "Spread"
4. **Ajustez la valeur** avec le slider ou tapez directement
5. **Sauvegardez** (Ctrl+S)
6. **Testez en jeu !**

## Tableaux de valeurs testées

### Armes de précision
| Nom | Fire Rate | Spread | Damage | Portée |
|-----|-----------|--------|--------|--------|
| Sniper | 1.5 | 0.0 | 50 | Très longue |
| Rifle | 0.2 | 1.0 | 10 | Longue |
| Pistolet | 0.3 | 4.0 | 7 | Moyenne |

### Armes automatiques
| Nom | Fire Rate | Spread | Damage | Portée |
|-----|-----------|--------|--------|--------|
| Uzi | 0.08 | 12.0 | 5 | Courte |
| SMG | 0.1 | 10.0 | 6 | Courte-Moyenne |
| Assault Rifle | 0.15 | 5.0 | 8 | Moyenne |

### Armes spéciales
| Nom | Fire Rate | Spread | Damage | Portée |
|-----|-----------|--------|--------|--------|
| Shotgun | 0.8 | 30.0 | 3x8 | Très courte |
| Revolver | 0.4 | 2.0 | 15 | Moyenne |
| Minigun | 0.04 | 20.0 | 4 | Courte |

Bon jeu ! 🎮
