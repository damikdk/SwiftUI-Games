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
        
        var gestureRecognizers = gameView.gestureRecognizers

        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        gestureRecognizers.append(clickGesture)
        
        let doubleClickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleDoubleClick(_:)))
        doubleClickGesture.numberOfClicksRequired = 2
        gestureRecognizers.append(doubleClickGesture)

        self.gameView.gestureRecognizers = gestureRecognizers
    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // Highlight the clicked nodes
        let point = gestureRecognizer.location(in: gameView)
        gameController.preview(atPoint: point)
    }
    
    @objc
    func handleDoubleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // Highlight the clicked nodes
        let point = gestureRecognizer.location(in: gameView)
        gameController.pick(atPoint: point)
    }
}
