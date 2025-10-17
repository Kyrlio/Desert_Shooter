# 💥 Guide du Système de Dégâts

## Problème résolu

Auparavant, toutes les armes faisaient le même dégât (1) car c'était géré par le `HitboxComponent` de la balle.

**Maintenant**, chaque arme transmet ses propres dégâts à ses balles ! 🎯

## Comment ça fonctionne

### 1. L'arme définit ses dégâts
Dans `weapon.gd`, la propriété `damage` contrôle les dégâts :
```gdscript
@export var damage: float = 5.0
```

### 2. L'arme transmet les dégâts à la balle
Lors du tir, la méthode `fire()` appelle :
```gdscript
bullet.set_damage(damage)
```

### 3. La balle configure son hitbox
La méthode `set_damage()` dans `bullet.gd` applique les dégâts au `HitboxComponent` :
```gdscript
func set_damage(dmg: float) -> void:
    hitbox_component.damage = int(dmg)
```

## Configuration dans l'éditeur Godot

### Pour configurer une arme

1. Ouvrez votre scène d'arme (ex: `rifle.tscn`, `uzi.tscn`)
2. Sélectionnez le nœud racine (Node2D avec le script Weapon)
3. Dans l'**Inspecteur**, modifiez la propriété **"Damage"**
4. Sauvegardez !

### Valeurs recommandées

Voici des suggestions d'équilibrage basées sur le fire rate et le spread :

#### Rifle (précis, cadence moyenne)
```
Damage: 10.0
Fire Rate: 0.2
Spread: 1.0
→ Bon DPS, précis à distance
```

#### Uzi (dispersé, cadence rapide)
```
Damage: 5.0
Fire Rate: 0.08
Spread: 12.0
→ DPS élevé mais seulement au corps-à-corps
```

#### Pistolet (équilibré)
```
Damage: 7.0
Fire Rate: 0.3
Spread: 4.0
→ Polyvalent
```

#### Sniper (très précis, lent)
```
Damage: 50.0
Fire Rate: 1.5
Spread: 0.0
→ One-shot puissant mais lent
```

#### Shotgun (dispersé, puissant, lent)
```
Damage: 8.0 (par balle, x8 balles = 64 total)
Fire Rate: 0.8
Spread: 30.0
→ Dévastateur à bout portant
```

## Calcul du DPS (Dégâts Par Seconde)

Pour équilibrer vos armes, calculez le DPS :

```
DPS = Damage / Fire_Rate
```

### Exemples

| Arme | Damage | Fire Rate | DPS | Portée Efficace |
|------|--------|-----------|-----|-----------------|
| Rifle | 10 | 0.2 | **50** | Longue |
| Uzi | 5 | 0.08 | **62.5** | Courte |
| Pistolet | 7 | 0.3 | **23** | Moyenne |
| Sniper | 50 | 1.5 | **33** | Très longue |

**Note** : L'Uzi a un DPS plus élevé que le Rifle, mais la dispersion le rend moins efficace à distance, ce qui équilibre les deux armes !

## Équilibrage avancé

### Principe général

**DPS élevé + Spread élevé = Arme de corps-à-corps**
- Exemple : Uzi (62.5 DPS, 12° spread)

**DPS moyen + Spread faible = Arme de distance**
- Exemple : Rifle (50 DPS, 1° spread)

**DPS faible + Alpha damage élevé = Arme de burst**
- Exemple : Sniper (33 DPS, 50 damage/tir)

### Formule d'équilibrage suggérée

Pour rendre une arme rapide moins dominante :
```
Si Fire_Rate < 0.1:
    → Augmenter Spread (10-20°)
    → Réduire Damage
    → Résultat : Efficace seulement au contact
```

Pour rendre une arme lente viable :
```
Si Fire_Rate > 1.0:
    → Réduire Spread (0-2°)
    → Augmenter Damage significativement
    → Résultat : One-shot potential, sniper role
```

## Configuration par code

Si vous créez des armes dynamiquement :

```gdscript
var rifle = rifle_scene.instantiate() as Weapon
rifle.damage = 10.0
rifle.fire_rate = 0.2
rifle.spread = 1.0
player.equip_weapon(rifle)
```

## Test d'équilibrage

### Comment tester vos dégâts

1. **Créez un ennemi de test** avec beaucoup de HP (ex: 100 HP)
2. **Comptez les tirs nécessaires** pour le tuer
3. **Chronométrez le temps** pour le tuer
4. **Calculez le DPS réel** : `HP_Ennemi / Temps_Elimination`
5. **Ajustez** selon vos besoins

### Checklist d'équilibrage

- [ ] Le Rifle tue en 10 tirs un ennemi standard ?
- [ ] L'Uzi tue plus vite au corps-à-corps ?
- [ ] Le Rifle est plus efficace à distance ?
- [ ] Chaque arme a une niche claire ?
- [ ] Aucune arme n'est strictement meilleure ?

## Modifications futures possibles

- [ ] Dégâts critiques (headshot)
- [ ] Dégâts augmentés/réduits selon la distance
- [ ] Pénétration d'armure différente par arme
- [ ] Dégâts sur zone (explosions)
- [ ] Dégâts de statut (poison, feu, etc.)

## Exemples de configurations complètes

### Build Équilibré Standard

**Rifle** (Arme principale)
- Damage: 10, Fire Rate: 0.2, Spread: 1.0
- DPS: 50, Role: Engagement moyen-longue portée

**Pistolet** (Arme secondaire)
- Damage: 7, Fire Rate: 0.3, Spread: 4.0
- DPS: 23, Role: Backup, économie de munitions

### Build Rushdown Agressif

**Uzi** (Arme principale)
- Damage: 5, Fire Rate: 0.08, Spread: 12.0
- DPS: 62.5, Role: Combat rapproché agressif

**Shotgun** (Burst damage)
- Damage: 8x8, Fire Rate: 0.8, Spread: 30.0
- DPS: 80, Role: Finisher, entrée en combat

### Build Sniper Tactique

**Sniper** (Arme principale)
- Damage: 50, Fire Rate: 1.5, Spread: 0.0
- DPS: 33, Role: Picks à longue distance

**SMG** (Auto-défense)
- Damage: 6, Fire Rate: 0.1, Spread: 8.0
- DPS: 60, Role: Protection rapprochée d'urgence

---

**Les dégâts sont maintenant correctement transmis de l'arme aux balles !** 💥
