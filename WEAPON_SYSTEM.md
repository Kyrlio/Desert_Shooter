# 🔫 Système d'Armes Modulaire - Desert Shooter

## Vue d'ensemble

Ce système permet au joueur de n'avoir qu'une seule arme à la fois et de la changer dynamiquement durant le jeu.

## Architecture

### 1. **Classe `Weapon` (scripts/weapon.gd)**
Classe de base pour toutes les armes.

**Nouvelles méthodes :**
- `on_equipped(new_owner: Player)` - Appelée automatiquement quand l'arme est équipée
- `on_unequipped()` - Appelée automatiquement quand l'arme est déséquipée

### 2. **Player (scenes/entities/player/player.gd)**

**Variable principale :**
- `current_weapon: Weapon` - L'arme actuellement équipée (une seule à la fois)

**Méthodes du système d'armes :**

#### `equip_weapon(weapon_instance: Weapon) -> void`
Équipe une nouvelle arme. Déséquipe automatiquement l'arme précédente.
```gdscript
var rifle = rifle_scene.instantiate() as Weapon
player.equip_weapon(rifle)
```

#### `unequip_weapon() -> void`
Déséquipe l'arme actuelle et la supprime.
```gdscript
player.unequip_weapon()
```

#### `change_weapon(weapon_scene: PackedScene) -> void`
Change l'arme actuelle par une nouvelle (depuis une PackedScene).
```gdscript
player.change_weapon(rifle_scene)
```

#### `get_current_weapon() -> Weapon`
Retourne l'arme actuellement équipée.
```gdscript
var current = player.get_current_weapon()
if current:
    print("Arme actuelle : %s" % current.display_name)
```

## Utilisation

### Tester le système (Debug)

Actuellement, vous pouvez tester le changement d'armes avec les touches directionnelles :
- **← (ui_left)** : Équiper le Rifle
- **→ (ui_right)** : Équiper l'Uzi
- **↑ (ui_up)** : Changer de skin (suivant)
- **↓ (ui_down)** : Changer de skin (précédent)

### Créer une arme ramassable

1. **Créer une scène avec le script `WeaponPickup`**
   ```
   Area2D (weapon_pickup.gd)
   ├── CollisionShape2D
   ├── Sprite2D (optionnel - visuel de l'arme)
   └── Label (optionnel - nom de l'arme)
   ```

2. **Configurer les paramètres**
   - `weapon_scene` : La PackedScene de l'arme à donner (ex: rifle_scene, uzi_scene)
   - `weapon_name` : Le nom affiché
   - `auto_pickup` : true = ramassage automatique, false = avec touche d'interaction

3. **Placer dans le niveau**
   Quand le joueur touche l'Area2D, l'arme est automatiquement équipée !

### Exemple : Créer une nouvelle arme

1. **Créer une scène d'arme** qui hérite de `Weapon`
2. **Configurer les propriétés** :
   ```gdscript
   display_name = "Ma Nouvelle Arme"
   damage = 10.0
   fire_rate = 0.5
   ```
3. **Créer une PackedScene** et l'assigner au joueur ou à un pickup

## Flux de travail pour ramasser une arme

```
Joueur touche WeaponPickup
    ↓
WeaponPickup._pickup_weapon() appelée
    ↓
player.change_weapon(weapon_scene)
    ↓
player.unequip_weapon() (si arme précédente)
    ↓
Ancienne arme supprimée
    ↓
player.equip_weapon(nouvelle_arme)
    ↓
Nouvelle arme ajoutée au weapon_root
    ↓
current_weapon.on_equipped(player)
    ↓
Arme prête à être utilisée !
```

## Notes importantes

- ✅ Le joueur ne peut avoir qu'**une seule arme** à la fois
- ✅ Changer d'arme **supprime** l'ancienne automatiquement
- ✅ Les armes sont ajoutées comme enfants de `weapon_root`
- ✅ Le système appelle automatiquement `on_equipped()` et `on_unequipped()`

## Prochaines étapes

- [ ] Créer plus de types d'armes
- [ ] Ajouter un système d'inventaire pour stocker plusieurs armes
- [ ] Ajouter des animations de changement d'arme
- [ ] Créer un système de munitions
- [ ] Ajouter des effets visuels lors du ramassage
- [ ] Système de rareté/qualité des armes
