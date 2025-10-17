# 🎯 Guide Rapide - Dispersion des Armes

## ✅ Ce qui a été ajouté

### Nouvelle propriété dans `Weapon`
- **`spread`** : Dispersion en degrés (0-45°)
  - 0° = Tir précis
  - 45° = Tir très dispersé

### Nouvelle fonction
- **`_apply_spread(direction)`** : Applique la dispersion aléatoire à la direction de tir

## 🎮 Comment configurer vos armes

### Dans l'éditeur Godot

1. Ouvrez votre scène d'arme (ex: `rifle.tscn`, `uzi.tscn`)
2. Sélectionnez le nœud racine (Node2D avec le script Weapon)
3. Dans l'**Inspecteur**, trouvez la propriété **"Spread"**
4. Ajustez avec le slider ou entrez une valeur :
   - **Rifle** : `0.5` à `3.0` (très précis)
   - **Uzi** : `10.0` à `15.0` (dispersé car tire vite)
   - **Pistolet** : `3.0` à `5.0` (précision moyenne)
   - **Shotgun** : `25.0` à `35.0` (très dispersé)

### Par code (si vous créez des armes dynamiquement)

```gdscript
var rifle = rifle_scene.instantiate() as Weapon
rifle.spread = 2.0  # Précis
player.equip_weapon(rifle)

var uzi = uzi_scene.instantiate() as Weapon
uzi.spread = 12.0  # Dispersé
player.equip_weapon(uzi)
```

## 📊 Valeurs recommandées

### Pour équilibrer vos armes

**Règle d'or** : Plus une arme tire vite, plus elle doit avoir de dispersion

| Arme | Fire Rate | Spread recommandé | Caractère |
|------|-----------|-------------------|-----------|
| Rifle | 0.2s | 0.5° - 3° | Précis, longue distance |
| Uzi/SMG | 0.08s | 10° - 15° | Rapide, courte distance |
| Pistolet | 0.3s | 3° - 5° | Équilibré |
| Shotgun | 0.8s | 25° - 35° | Puissant, très près |
| Sniper | 1.5s | 0° - 0.5° | Ultra précis |

## 🔧 Testez vos réglages

1. **Lancez le jeu**
2. **Changez d'arme** avec les touches fléchées (← pour Rifle, → pour Uzi)
3. **Tirez sur un mur** pour voir le pattern de dispersion
4. **Ajustez** les valeurs dans l'éditeur
5. **Recommencez** jusqu'à satisfaction

## 💡 Astuces d'équilibrage

### Pour un Rifle précis
```
Fire Rate: 0.2
Spread: 1.0
Damage: 10
→ Bon pour le combat à distance
```

### Pour un Uzi dispersé mais rapide
```
Fire Rate: 0.08
Spread: 12.0
Damage: 5
→ Doit être près de la cible pour être efficace
```

### Pour un Pistolet polyvalent
```
Fire Rate: 0.3
Spread: 4.0
Damage: 7
→ Bon partout, excellent nulle part
```

## 🎯 Effet visuel de la dispersion

```
Rifle (spread = 1°)
     |
     |    <- Balles très regroupées
     |
    🎯

Uzi (spread = 12°)
   \ | /
    \|/   <- Balles dispersées
    /|\
   / | \
    🎯
```

## 🚀 Prochaines étapes

1. **Configurez vos armes existantes** avec des valeurs de spread
2. **Testez l'équilibrage** en jeu
3. **Créez de nouvelles armes** avec différents niveaux de précision
4. **Ajoutez des effets visuels** pour montrer la dispersion (traceurs, impacts)

## ⚙️ Le code technique (pour info)

La dispersion fonctionne comme ça :
1. Direction de base vers la cible
2. Angle aléatoire entre `-spread` et `+spread`
3. Nouvelle direction = direction de base + angle aléatoire
4. La balle part dans cette direction

C'est totalement aléatoire à chaque tir, donc imprévisible !

Bon équilibrage ! 🎮
