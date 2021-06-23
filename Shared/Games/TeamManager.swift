//
//  TeamManager.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 24.06.2021.
//

import SwiftUI

class Team: Identifiable, Equatable {
  let id: String = "Team-" + UUID.short()
  var heroes: [Hero] = []
  
  static func == (lhs: Team, rhs: Team) -> Bool {
    return lhs.id == rhs.id
  }
}

class TeamManager: ObservableObject {
  @Published var currentTeam: Team? = nil
  var teams: [Team] = []
  
  func nextTeam() {
    let currentTeamIndex = teams.firstIndex(where: { $0 == currentTeam })
    
    if let currentTeamIndex = currentTeamIndex {
      let nextIndex = currentTeamIndex + 1
      
      if nextIndex < teams.count {
        currentTeam = teams[nextIndex]
      } else {
        currentTeam = teams.first
      }
    } else {
      print("Strange, there is no current team. Or it's not in TeamManager array: \(currentTeam?.id ?? "<NIL>")")
      currentTeam = teams.first
    }
  }
}
