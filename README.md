# TBS (EXTREMELY RAW)
Turn-based strategy template written on pure Swift with SceneKit.

Interaction of characters is based on physics, not on cells. In other words, the damage is caused by the fact that the bullet flew into the object, and not instantly at the meta level (but you can do so). So you can use this code without field or turns. 

![overview](https://i.imgur.com/RCiIHZQ.jpg)

## Features
- Field generation
- Characters
  - HP
  - Classes
  - Abilities API
- Apple-crossplatform (almost)
  - iOS, MacOS tested
  - tvOS runnable, but without control
  - watchOS disabled
- AR-ready (almost)
  
## Field
```
Field(in position: SCNVector3, size: Int, cellSize: CGFloat)

node: SCNNode, 
size: Int /// Field is squared for now, default is 9 row, 9 columns
cellSize: CGFloat /// Size in meteres (AR ready)
``` 

Don't forget to add ``Field.node`` to your ``scene.rootNode``. For now I do it in ``Game.currentField.didSet`` method

## Characters
```
enum CharacterRole: Int {
    case tank = 1
    case support = 2
    case dps = 3
}

HP: Int
node: SCNNode /// For physics
role: CharacterRole /// For initialization, actions and abilities
gameID: String /// For search through SCNNodes tree
abilities = [Ability]()
``` 

Don't forget to add ``Character.node`` to your ``currentField`` with 
```
currentField.put(object: newCharacter.node, row: 3, column: 3)
```

## Abilities
```
struct Ability {
    let name: String!
    let icon: SCNImage!    
    let action: ((Game, Character) -> Void)!
}

Ability(name: "Heal AOE",
        icon: SCNImage(named: "christ-power"),
        action: { game, charater in
           game.onCharacterPress = { game, charater in
               charater.heal(amount: 2)
               game.onCharacterPress = defaultOnCharacterPress
           }
})
```

Most important thing about abilities is API itself. I tried make it as free as possible, so in ``Ability.action`` you have ``Game`` instance and character that use this ability. So you can do whatever you want.

## Apple-crossplatform
It's zero-dependency project with pure Swift code (SceneKit, SpriteKit for UI  overlay). I used default XCode crossplatform game template, so it's super clear architecture in this sense:

```
- TBS Shared (Game and SceneKit logic)
- TBS iOS (OS-specific gesture handlers, SCNView initialization)
  - AppDelegate
  - GameViewController
  ...
- TBS macOS (OS-specific gesture handlers, SCNView initialization)
- TBS tvOS (There is no controls for now, I don't know tvOS API)
...
```

There is some abstract [helpers](https://github.com/damikdk/TBS/blob/master/TBS%20Shared/Helpers/GraphicsHelper.swift) for crossplatform Colors and Images, but overall it's super flat and simple.

## AR
You can run this project in AR, but you need to change some code. I tried to make switcher for Regular/AR modes, but I don't have time to figure out how to beautifully combine these two modes in code. It's messy for now.

But estimate for this task is 2-8 hours.

### TODO
- More cool abilities
- Animatiins for abilities
- Movements cell-by-cell
- "Turn" logic
- Friend-or-foe/teams system
- "Round" logic
- Playground
