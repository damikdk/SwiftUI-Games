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
