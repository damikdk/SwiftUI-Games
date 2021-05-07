//
//  GameViewController.swift
//  TBS iOS
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
        var gestureRecognizers = gameView.gestureRecognizers ?? []

        /// Add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        gestureRecognizers.append(tapGesture)
        
        /// Add a double tap gesture recognizer
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        
        /// Add a long press gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        gestureRecognizers.append(longPressGesture)
        
        self.gameView.gestureRecognizers = gestureRecognizers
    }
    
    @objc
    func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: gameView)
        print("Tap detected at point: \(point)")
        gameController.pick(atPoint: point)
    }
    
    @objc
    func handleDoubleTap(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: gameView)
        print("Double tap detected at point: \(point)")
    }
    
    @objc
    func handleLongPress(_ gestureRecognizer: UIGestureRecognizer) {
        if (gestureRecognizer.state == .began) {
            print("Long press detected")

            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()

            let point = gestureRecognizer.location(in: gameView)
            gameController.pick(atPoint: point)
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
