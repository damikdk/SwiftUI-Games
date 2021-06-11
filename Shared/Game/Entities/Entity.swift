//
//  Entity.swift
//  TBS3 (iOS)
//
//  Created by Damir Minnegalimov on 11.06.2021.
//

import Foundation

protocol Entity {
  var gameID: String { get }
  
  var node: MaterialNode { get }
}

enum EntityType: Int {
  case field = 1
  case hero
  case shield
}
