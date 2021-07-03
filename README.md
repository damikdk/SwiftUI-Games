# SwiftUI-Games (WIP)

Collection of simple demos of SwiftUI + SceneKit games

### Design
- Pure Swift
- Pure SwiftUI at all cost. Zero UIKit imports and OS-specific code
- Only modern APIs, zero legacy support. iOS 15+ since day one
- Zero dependencies
- Zero projectiles. I hate projectiles

### Goals
- Formulate some clear architecture for SwiftUI + SceneKit projects
- Deep dive into new APIs

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
Setup for turn based strategy with Field and Heroes with unique Abilities.

<p float="left">
<img src="https://i.imgur.com/EmsgJld.png" alt="TBSGame" height="300">
<img src="https://i.imgur.com/Cic7cEa.png" alt="TBSGame" height="300">
</p>

## TogetherGame (WIP)
Simple arcade with GCVirtualController. Control two nice balls, capture all bad cubes

<p float="left">
<img src="https://i.imgur.com/XEwC2ZD.png" alt="TogetherGame" height="300">
</p>

## Roadmap
- Temple Run clone
- Clash of Clans/Warcraft simple clone with some buildings
- Heroes Editor
- Some Battle Royal
- Simple dialog system

## Broken things (by Apple or me)
- Safe Area Insets. And some in-game Taps because of it
- Some transitions and animations
