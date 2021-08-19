//
//  Game.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 16.06.2021.
//

import SceneKit

protocol Game {
  var name: String { get }
  var description: String { get }

  var iconName: String { get }
  var scene: SCNScene { get }
}

let Games: [Game] = [
  MinimalDemo(
    name: "Minimal Demo",
    description: "Simple SceneKit and SwiftUI overlay"),
  
  TBSGame(
    name: "TBSGame [WIP]",
    description: "Turn based strategy with 2 random teams on 7x7 Field",
    field: Field(size: 7)),

  TogetherGame(
    name: "TogetherGame [WIP]",
    description: "Simple game with virtual gamepad",
    field: Field(size: 15)),

  DarkGame(
    name: "DarkGame [WIP]",
    description: "Survive the darkness",
    field: Field(size: 30))
]
