//
//  Game.swift
//  TBS2 (iOS)
//
//  Created by Damir Minnegalimov on 04.06.2021.
//

import SceneKit
import SwiftUI

class TBSGame: Game, ObservableObject {
  let name: String
  let description: String

  let iconName = "checkerboard.rectangle"
  
  var scene: SCNScene = SCNScene()
  var field: Field
  
  private let cameraHeight: Float = 40
  
  @Published var currentTeam: Team? = nil
  @Published var teams: [Team] = []
  
  @Published var currentHero: Hero?
  @Published var currentFieldCell: FieldCell?
  @Published var gameLogger = GameLogger()

  var onHeroPress: ((TBSGame, Hero) -> Void) = defaultOnHeroPress
  var onFieldPress: ((TBSGame, FieldCell) -> Void) = defaultOnFieldPress
  
  init(
    name: String,
    description: String,
    field: Field
  ) {
    self.name = name
    self.description = description
    self.field = field
    
    // Add Field node
    scene.rootNode.addChildNode(field.node)
    
    // Set backround for Scene
    scene.background.contents = Color.DarkTheme.Violet.background.cgColor
    
    prepareCamera()
    prepareLight()
    prepareTeams()
    prepareDebugStuff()
  }
  
  // MARK: - Touch / Pick node
  
  func pick(_ materialNode: MaterialNode) {
    switch materialNode.type {
    case .field:
      let fieldCell = field.cells.first(where: { $0.gameID == materialNode.gameID })
      
      if let fieldCell = fieldCell {
        onFieldPress(self, fieldCell)
        gameLogger.post(newMessage: "Picked cell: \(fieldCell.gameID)")
      } else {
        gameLogger.post(newMessage: "Can't find \(materialNode) in Field")
      }
      
      break;
    case .hero:
      if let hero = materialNode.host {
        onHeroPress(self, hero)
        gameLogger.post(newMessage: "Picked Hero: \(hero.gameID)")
      }
      
      break;
    case .shield:
      if let host = materialNode.host {
        // If shield have a host, pick it
        onHeroPress(self, host)
        
        gameLogger.post(newMessage: "Picked Hero: \(host)")
      } else {
        gameLogger.post(newMessage: "Shield without host was touched")
      }
      break;
    case .platform:
      break;
    }
  }
  
}

// MARK: - Preparing

private extension TBSGame {
  
  func prepareLight() {
    let fieldCenter = field.center()
    let spotlight = defaultLightNode(mode: .spot)
    spotlight.position = fieldCenter + SCNVector3(0, cameraHeight, 20)
    spotlight.look(at: fieldCenter)
    
    scene.rootNode.addChildNode(spotlight)
    scene.rootNode.addChildNode(defaultLightNode(mode: .ambient))
  }
  
  func prepareCamera() {
    // Setup camera
    let cameraNode = SCNNode()
    cameraNode.name = "CameraHuyamera"
    cameraNode.camera = SCNCamera()
    cameraNode.eulerAngles = SCNVector3(Float.pi / -3, 0, 0)
    cameraNode.camera?.fieldOfView = 40
    cameraNode.camera?.automaticallyAdjustsZRange = true
    
    // Place camera
    let fieldCenter = field.center()
    cameraNode.position = fieldCenter + SCNVector3(0, cameraHeight, cameraHeight / 2)
    cameraNode.look(at: fieldCenter)
    
    //    let centerConstraint = SCNLookAtConstraint(target: field.centerCell().node)
    //    cameraNode.constraints = [centerConstraint]
    
    scene.rootNode.addChildNode(cameraNode)
  }
  
  func prepareRandomTeams() {
    let team1 = Team()
    let team2 = Team()
    let team3 = Team()
    
    teams = [team1, team2, team3]
    currentTeam = team1
    
    // Add random Hero on each cell except edges
    for row in 1..<(field.size - 1) {
      for column in 1..<(field.size - 1) {
        let hero = Heroes.all().randomElement()!
        let fieldCell = field.cells[row + field.size * column]
        field.put(object: hero.node, to: fieldCell)
        
        let randomTeam = teams.randomElement()!
        randomTeam.heroes.append(hero)
      }
    }
  }
  
  func prepareTeams() {
    let team1 = Team()
    let team2 = Team()
    
    teams = [team1, team2]
    currentTeam = team1

    // First team (close to camera)
    // Random Heroes
    for column in 1..<(field.size - 1) {
      let hero = Heroes.all().randomElement()!
      let fieldCell = field.fieldCell(in: 1, column: column)!
      field.put(object: hero.node, to: fieldCell)

      teams[1].heroes.append(hero)
    }

    // Second team (far from camera)
    // Random Heroes
    for column in 1..<(field.size - 1) {
      let hero = Heroes.all().randomElement()!
      let fieldCell = field.fieldCell(in: field.size - 2, column: column)!
      field.put(object: hero.node, to: fieldCell)

      teams[0].heroes.append(hero)
    }
  }
  
  func prepareDebugStuff() {
    // Debug sphere in the center of the Field
    let sphereGeometry = SCNSphere(radius: 0.2)
    sphereGeometry.firstMaterial?.diffuse.contents = Color.darkRed.cgColor
    let sphereNode = SCNNode(geometry: sphereGeometry)
    sphereNode.position = field.center()
    
    scene.rootNode.addChildNode(sphereNode)
  }
  
}

// MARK: - Teams managament

extension TBSGame {
  
  func switchTeam() {
    let currentTeamIndex = teams.firstIndex(where: { $0 == currentTeam })
    
    if let currentTeamIndex {
      let nextIndex = currentTeamIndex + 1
      
      if nextIndex < teams.count {
        currentTeam = teams[nextIndex]
      } else {
        currentTeam = teams.first
      }
      
      gameLogger.post(newMessage: "\(currentTeam?.id ?? "<NIL>")'s move")
      highlight(team: currentTeam)
    } else {
      gameLogger.post(newMessage: "Strange, there is no current team. Or it's not in TeamManager array: \(currentTeam?.id ?? "<NIL>")")

      currentTeam = teams.first
    }
    
    currentHero = nil
  }
  
  func highlight(team: Team?) {
    // Highlight all Heroes of Team
    if let team = team {
      for hero in team.heroes {
        hero.node.highlight()
      }
    }
  }
  
}

// MARK: - Mocks

extension TBSGame {
  
  static let defaultOnHeroPress: ((TBSGame, Hero) -> Void) = { game, hero in
    var game = game

    if let inCurrentTeamHero = game.currentTeam?.heroes.first(where: { $0 == hero }) {
      // Pressed hero is in current team
      game.currentHero = hero
      hero.node.highlight()
    } else {
      // Hero is not allowed to be picked, it's another team's turn
      hero.node.highlight(with: .red, for: 0.1)
    }
  }
  
  static let defaultOnFieldPress: ((TBSGame, FieldCell) -> Void) = { game, cell in
    var game = game
    
    cell.node.highlight()
    game.currentFieldCell = cell
    
    if let hero = game.currentHero {
      game.field.move(node: hero.node, to: cell)
    }
  }
  
  static let defaultAbilityAction: ((TBSGame, Character) -> Void) = { game, charater in
    print("defaultAbilityAction")
  }
  
}

