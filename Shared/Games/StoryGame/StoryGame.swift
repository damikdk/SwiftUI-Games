//
//  StoryGame.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 10.07.2021.
//

import SceneKit
import SwiftUI

class StoryGame: Game, ObservableObject {
  let name: String
  let description: String
  let iconName = "character.book.closed"

  var scene: SCNScene = SCNScene()

  init(
    name: String,
    description: String
  ) {
    self.name = name
    self.description = description

    // Set backround for Scene
    scene.background.contents = Color.DarkTheme.Violet.background.cgColor

    // prepareCamera()
  }

}

