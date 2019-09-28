//
//  GameViewController.swift
//  TBS macOS
//
//  Created by Damik Minnegalimov on 19/05/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import Cocoa
import SceneKit

class GameViewController: NSViewController {
    
    var gameView: SCNView {
        return self.view as! SCNView
    }
    
    var gameController: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameController = Game(sceneRenderer: gameView)
        
        // Show statistics such as fps and timing information
        self.gameView.showsStatistics = true
                
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = gameView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        self.gameView.gestureRecognizers = gestureRecognizers
    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // Highlight the clicked nodes
        let point = gestureRecognizer.location(in: gameView)
        gameController.tap(atPoint: point)
    }
    
}
