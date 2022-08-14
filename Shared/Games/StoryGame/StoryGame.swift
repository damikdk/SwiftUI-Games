//
//  StoryGame.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 10.07.2021.
//

import SceneKit
import SwiftUI

class StoryGame: Game, Story, ObservableObject {
  
  let name: String
  let description: String
  
  var chapters: [Chapter]
  let iconName = "character.book.closed"

  var scene: SCNScene = SCNScene()

  init(
    name: String,
    description: String,
    chapters: [Chapter]
  ) {
    self.name = name
    self.description = description
    self.chapters = chapters

    // Set backround for Scene
    scene.background.contents = Color.DarkTheme.Violet.background.cgColor
  }

}


class StoryChapter: Chapter, ObservableObject {
  var name: String
  var description: String
  
  var iconName: String = "circlebadge"
  var available: Bool = false
  var finished: Bool = false
  var scene: SCNScene = SCNScene()
  
  init(
    name: String,
    description: String
  ) {
    self.name = name
    self.description = description

    // Set backround for Scene
    scene.background.contents = Color.DarkTheme.Violet.background.cgColor
  }
  
}


protocol Story {
  
  var name: String { get }
  var description: String { get }

  var chapters: [Chapter] { get }

}

protocol Chapter: Game {
  
  var available: Bool { get set }
  
  var finished: Bool { get set }
  
}

