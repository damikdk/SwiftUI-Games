//
//  GameView.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 16.06.2021.
//

import SceneKit
import SwiftUI

protocol GameView: View {
  associatedtype Game

  var showing: Bool { get }
  var game: Game { get }
}
