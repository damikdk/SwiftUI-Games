//
//  Game.swift
//  TBS2 (iOS)
//
//  Created by Damir Minnegalimov on 04.06.2021.
//

import SceneKit

struct GameMode: Hashable {
  let name: String
  let description: String
  let characters: [Character]
  let fieldSize: Int

  let id = UUID()
}

class Game {
  let name: String
  let field: Field
  let characters: [Character]?

  init?(gameMode: GameMode?) {
    guard let gameMode = gameMode else {
      return nil
    }

    name = gameMode.name
    field = Field(size: gameMode.fieldSize)
    characters = gameMode.characters

    return
  }
}

let gameModes = [
  GameMode(
    name: "Default",
    description: "7x7 field with default set of Heroes",
    characters: [],
    fieldSize: 7),

  GameMode(
    name: "Small field",
    description: "3x3 field with a couple of Heroes",
    characters: [],
    fieldSize: 3),

  GameMode(
    name: "Giant field",
    description: "\(FieldConstants.maxFieldSize)x\(FieldConstants.maxFieldSize) field with random set of Heroes",
    characters: [],
    fieldSize: FieldConstants.maxFieldSize),

  GameMode(
    name: "Random",
    description: "Random field size (3x3 to \(FieldConstants.maxFieldSize)x\(FieldConstants.maxFieldSize)) with random set of Heroes",
    characters: [],
    fieldSize: Int.random(in: 3..<FieldConstants.maxFieldSize)),
]
