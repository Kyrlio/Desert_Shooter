# 🎮 Guide Rapide - Système d'Armes Modulaire

## ✅ Ce qui a été implémenté

### 1. **Système de base dans `player.gd`**
- Une seule arme à la fois (`current_weapon`)
- Méthodes pour équiper/déséquiper des armes
- Système de changement d'arme automatique

### 2. **Amélioration de `weapon.gd`**
- Callbacks `on_equipped()` et `on_unequipped()`
- Gestion automatique du propriétaire

### 3. **Script `weapon_pickup.gd`**
- Armes ramassables dans le monde
- Ramassage automatique ou manuel
- Remplace automatiquement l'arme actuelle

## 🎯 Comment l'utiliser

### Tester maintenant (Debug)
Lancez votre jeu et utilisez :
- **Flèche GAUCHE** ← : Change pour le Rifle
- **Flèche DROITE** → : Change pour l'Uzi

Vous verrez dans la console les messages de changement d'arme !

### Créer une arme ramassable (pour plus tard)

#### Méthode 1 : Depuis l'éditeur Godot
1. Créez une scène `Area2D`
2. Ajoutez le script `scenes/entities/weapon_pickup.gd`
3. Ajoutez un `CollisionShape2D`
4. Configurez :
   - `Weapon Scene` → Glissez votre arme (rifle.tscn, uzi.tscn, etc.)
   - `Weapon Name` → Le nom à afficher
   - `Auto Pickup` → Coché pour ramassage auto
5. Placez dans votre niveau !

#### Méthode 2 : Par code
```gdscript
# Dans votre script de niveau ou de spawn
var pickup = preload("res://scenes/entities/weapon_pickup.tscn").instantiate()
pickup.weapon_scene = rifle_scene  # ou uzi_scene, etc.
pickup.weapon_name = "Super Rifle"
pickup.global_position = Vector2(100, 100)
add_child(pickup)
```

### Créer une nouvelle arme

1. **Dupliquez** une scène d'arme existante (rifle ou uzi)
2. **Modifiez** les propriétés dans l'inspecteur :
   - `Display Name` : Nom de votre arme
   - `Damage` : Dégâts par balle
   - `Fire Rate` : Temps entre chaque tir
3. **Sauvegardez** la scène
4. **Utilisez-la** dans un pickup ou pour l'arme de départ

## 📝 Exemples de code

### Changer l'arme du joueur
```gdscript
# Depuis n'importe quel script qui a accès au joueur
player.change_weapon(rifle_scene)
```

### Vérifier l'arme actuelle
```gdscript
var current = player.get_current_weapon()
if current:
    print("Arme : %s, Dégâts : %s" % [current.display_name, current.damage])
```

### Enlever l'arme du joueur
```gdscript
player.unequip_weapon()
# Le joueur n'a plus d'arme !
```

## 🔍 Points importants

- ✅ L'arme précédente est **automatiquement supprimée** lors du changement
- ✅ Le joueur ne peut avoir **qu'une seule arme** à la fois
- ✅ Les armes sont **attachées au weapon_root** du joueur
- ✅ Le système gère automatiquement les **callbacks** d'équipement

## 🚀 Prochaines étapes suggérées

1. **Testez le système** avec les touches fléchées
2. **Créez 2-3 armes différentes** avec des stats variées
3. **Placez des pickups** dans votre niveau de test
4. **Ajoutez des effets visuels** lors du ramassage (particules, son)
5. **Créez un HUD** qui affiche l'arme actuelle

## 🆘 Problèmes courants

**Le joueur ne tire plus ?**
- Vérifiez que `current_weapon` n'est pas null
- Vérifiez que l'arme a bien un `muzzle_point_path` configuré

**L'arme n'apparaît pas visuellement ?**
- Vérifiez que l'arme a un sprite enfant
- Vérifiez que l'arme est bien ajoutée au `weapon_root`

**Le ramassage ne fonctionne pas ?**
- Vérifiez que l'Area2D a une collision
- Vérifiez que le joueur a bien le layer/mask qui correspond
- Vérifiez que `weapon_scene` est bien assigné dans le pickup

Bon développement ! 🎮
