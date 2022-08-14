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
    field: Field(size: 50)),
  
  JumpGame(
    name: "JumpGame",
    description: "Doodle jump, but much worse"),
  
  StoryGame(
    name: "StoryGame [WIP]",
    description: "Adventure with map",
    chapters: [
      StoryChapter(name: "Awakening", description: "You are"),
      StoryChapter(name: "First sense", description: "How are you?"),
      StoryChapter(name: "Try again", description: "Don't be shy"),
      StoryChapter(name: "I need more chapters", description: "Just for layout reasons"),
      StoryChapter(name: "Like 8 will be enough", description: "For most devices"),
      StoryChapter(name: "Nah", description: "It's good")
    ])
]
