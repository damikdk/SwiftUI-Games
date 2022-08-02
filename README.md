
# SwiftUI-Games (WIP)
Collection of simple demos of SwiftUI + SceneKit games

[TestFlight Beta](https://testflight.apple.com/join/52wVoy8Z "TestFlight Beta")

### Design
- Pure `SwiftUI` at any cost. Zero `UIKit` imports
- Full Apple-crossplatform. Playable on `iOS`, `macOS`. (`tvOS` later)
- Only modern APIs, zero legacy support. `iOS 15+` since day one
- Zero dependencies
- Zero projectiles. I hate projectiles

### Goals
- Formulate some clean and simple architecture for Apple-crossplatform `SwiftUI` + `SceneKit` projects
- Collect all the bad hacks in the world

### Why it's so messy?
- I made it
- SwiftUI is young and raw
- APIs and project itself is constantly changing

## MinimalDemo
Simple SCNScene with ball and some SwiftUI overlay

<p float="left">
<img src="https://i.imgur.com/TRA8q3Z.png" alt="MinimalDemo" height="300">
<img src="https://i.imgur.com/YFw4OP9.png" alt="MinimalDemo" height="300">
</p>

## TBSGame (WIP)
Setup for turn based strategy with Field, Teams and Heroes with unique Abilities.

- In-scene tap and drag gesture hack without `UIKit`
- `SceneRendererDelegate` hack without `UIKit`
- Hitscan helper

<p float="left">
<img src="https://i.imgur.com/EmsgJld.png" alt="TBSGame" height="300">
<img src="https://i.imgur.com/Cic7cEa.png" alt="TBSGame" height="300">
</p>

## TogetherGame (WIP)
Simple arcade. Control two nice balls, catch all of bad ones

- `SceneRendererDelegate` hack without `UIKit` for `renderer(renderer, updateAtTime)` (`SceneKit` each-frame-callback similar to `update()` from Unity)
- `SCNPhysicsContactDelegate` hack without `UIKit`
- In-game `Timer` hack
- `GCVirtualController`, each stick moves one ball. Simpliest implementation, check `DarkGame` for cool cross-platform `SuperController` code (WIP)

<p float="left">
<img src="https://i.imgur.com/XEwC2ZD.png" alt="TogetherGame" height="300">
</p>
  
## DarkGame (WIP)
Simple arcade. Control ball, loot and run. The Spirit will light your way 

- `SceneRendererDelegate` hack without `UIKit` for `renderer(renderer, updateAtTime)` (`SceneKit` each-frame-callback similar to `update()` from Unity)
- `SCNPhysicsContactDelegate` hack without `UIKit`
- Keyboard, real gamepad or `GCVirtualController` control in one place called `SuperController` (WIP, not working)

<p float="left">
<img src="https://i.imgur.com/lRe8b1h.png" alt="DarkGame" height="400">
<img src="https://i.imgur.com/AgedV7Q.png" alt="DarkGame" height="400">
</p>

## Roadmap
Current tasks are [here](https://github.com/damikdk/SwiftUI-Games/projects/1)

- Temple Run clone
- Clash of Clans/Warcraft simple clone with some buildings
- Heroes Editor
- Some Battle Royal
- Simple dialog system

## Broken things (by Apple or me)
- Some transitions and animations
