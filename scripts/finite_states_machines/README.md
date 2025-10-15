# State Machine - Version Légère

## 📁 Fichiers

- **`state.gd`** - Classe de base pour les états
- **`state_machine.gd`** - Gestionnaire de la state machine
- **`player/idle_state.gd`** - État Idle
- **`player/running_state.gd`** - État Running

## 🔧 Configuration dans player.tscn

```
Player (CharacterBody2D)
└── StateMachine (Node) [state_machine.gd]
    ├── IdleState (Node) [idle_state.gd]
    └── RunningState (Node) [running_state.gd]
```

### Étapes :
1. Ajouter un node `StateMachine` (type: Node) sous Player
2. Attacher le script `state_machine.gd`
3. Ajouter un node `IdleState` sous StateMachine avec script `idle_state.gd`
4. Ajouter un node `RunningState` sous StateMachine avec script `running_state.gd`

**C'est tout !** Le premier état enfant sera automatiquement activé.

## 🎯 Fonctionnement

- **Idle → Running** : Quand le joueur bouge (`movement_vector > 0`)
- **Running → Idle** : Quand le joueur s'arrête (`movement_vector == 0`)

Les états gèrent eux-mêmes le mouvement avec `move_and_slide()`.

## ➕ Ajouter un état

1. Créer `mon_etat.gd` qui hérite de `State`
2. Implémenter `enter()` et `physics_update()`
3. Ajouter un node du nom exact sous StateMachine
4. Utiliser `get_parent().change_state("MonEtat")` pour y accéder
