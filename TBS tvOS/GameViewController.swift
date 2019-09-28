//
//  GameViewController.swift
//  TBS tvOS
//
//  Created by Damik Minnegalimov on 19/05/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    var gameView: SCNView {
        return self.view as! SCNView
    }
    
    var gameController: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameController = Game(sceneRenderer: gameView)
        
        // Show statistics such as fps and timing information
        self.gameView.showsStatistics = true
                
        // Add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        var gestureRecognizers = gameView.gestureRecognizers ?? []
        gestureRecognizers.insert(tapGesture, at: 0)
        self.gameView.gestureRecognizers = gestureRecognizers
    }
    
    @objc
    func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        // Highlight the tapped nodes
        let point = gestureRecognizer.location(in: gameView)
        gameController.tap(atPoint: point)
    }
    
}
