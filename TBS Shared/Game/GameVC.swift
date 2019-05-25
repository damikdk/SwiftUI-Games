//
//  GameViewController.swift
//  TBS
//
//  Created by Damik Minnegalimov on 22/11/2018.
//  Copyright © 2018 Damirka. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit


enum BodyType: Int {
    case field = 1
    case material = 2
}

let defaultOnCharacterPress: ((GameVC, Character) -> Void) = { gameVC, charater in gameVC.currentCharacter = charater }
let defaultOnFieldPress: ((GameVC, MaterialNode, Int, Int) -> Void) = { gameVC, cellNode, row, column in
    gameVC.currentField.move(node: gameVC.currentCharacter!.node, toRow: row, column: column)
}

class GameVC: UIViewController {
    var cameraNode: SCNNode!
    var lightNode: SCNNode!
    var scene: SCNScene!
    var cameraHeight: Float = FieldConstants.defaultCellSize * 7
 
    var startScale: CGFloat = 0
    var lastScale: CGFloat = 1
    var previousTranslateX:CGFloat = 0.0
    var previousTranslateZ:CGFloat = 0.0
    
    var overlay: OverlayHUD!
    var currentCharacter: Character? {
        didSet {
            overlay.setupUI(character: currentCharacter!)
        }
    }
    var characters: [Character] = []
    var currentField: Field! {
        didSet {
            scene.rootNode.addChildNode(currentField.node)
            
            let fieldCenter = currentField.centerOfCell(row: (currentField.size / 2),
                                                        column: (currentField.size / 2))
            
            let cameraPosition = SCNVector3(x: fieldCenter.x,
                                            y: fieldCenter.y + cameraHeight,
                                            z: fieldCenter.z + cameraHeight)
            
            let moveCamera = SCNAction.move(to: cameraPosition, duration: 0);
            
            cameraNode.runAction(moveCamera) {
                self.cameraNode.look(at: fieldCenter)
                self.lightNode.position = SCNVector3(x: fieldCenter.x,
                                                     y: fieldCenter.y + FieldConstants.defaultCellSize * 5,
                                                     z: fieldCenter.z)
                self.lightNode.look(at: fieldCenter)
                self.lastScale = 1 / (self.cameraNode.camera?.fieldOfView)!
            }
        }
    }
    
    var onCharacterPress: ((GameVC, Character) -> Void)!
    var onFieldPress: ((GameVC, MaterialNode, Int, Int) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        scene = SCNScene()
        scene.physicsWorld.contactDelegate = self

        // set up the camera
        cameraNode = SCNNode()
        cameraNode.name = "Camera"
        cameraNode.camera = SCNCamera()
        cameraNode.eulerAngles = SCNVector3Make(Float.pi / -3, 0, 0)
        cameraNode.camera!.zFar = 200

        scene.rootNode.addChildNode(cameraNode)
        
        // set the scene to the view
        let scnView = self.view as! SCNView
        scnView.scene = scene
        scnView.backgroundColor = UIColor.black
        
        // set up overlay
        let overlayScene = OverlayHUD(size: view.frame.size)
        overlayScene.backgroundColor = UIColor.lightBlue
        overlayScene.scaleMode = .resizeFill
        scnView.overlaySKScene = overlayScene
        overlay = overlayScene
        
        // set up field and characters
        currentField = Field(in: SCNVector3())
        createCharacters(random: false)
        onCharacterPress = defaultOnCharacterPress
        onFieldPress = defaultOnFieldPress

        // create and add a light to the scene
        let light = SCNLight()
        lightNode = SCNNode()
        lightNode.name = "Light"

        light.type = .spot
        light.castsShadow = true
        light.spotOuterAngle = 100
        light.shadowMode = .deferred
        light.shadowSampleCount = 32

        lightNode.light = light
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // allows the user to manipulate the camera
        // scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        // scnView.showsStatistics = true
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        // add a pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        scnView.addGestureRecognizer(pinchGesture)

        // add a pan gesture recognizer
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(pan)
    }
        
    func createCharacters(random: Bool) {
        if (random) {
            var squadsCount = 7
            
            while squadsCount > 0 {
                createCharacter(role: .dps)
                createCharacter(role: .tank)
                createCharacter(role: .support)
                
                squadsCount -= 1
            }

            return
        }
        
        for row in 2...(currentField.size - 2) {
            createCharacter(role: .tank, row: row, column: 3)
            createCharacter(role: .dps, row: row, column: 2)
            createCharacter(role: .support, row: row, column: 1)
            
            let rightSideColumn = currentField.size - 2
            
            createCharacter(role: .tank, row: row, column: rightSideColumn - 2)
            createCharacter(role: .dps, row: row, column: rightSideColumn - 1)
            createCharacter(role: .support, row: row, column: rightSideColumn)
        }
    }
    
    func createCharacter(role: CharacterRole, row: Int? = nil, column: Int? = nil) -> Void {
        let newCharacter = Character(role: role)
        
        if (row != nil && column != nil) {
            currentField.put(object: newCharacter.node, row: row!, column: column!)
        } else {
            currentField.put(object: newCharacter.node)
        }
        
        characters.append(newCharacter)
    }
    
    func findCharacter(by gameID: String!) -> Character? {
        for character in characters {
            if character.gameID == gameID {
                return character
            }
        }
        
        return nil
    }
}

extension GameVC: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("contact")
    }
}

extension GameVC {
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        
        if hitResults.count == 0 {
            // check that we clicked on at least one object
            return;
        }
        
        // retrieved the first clicked object
        let result = hitResults[0]
        
        // highlight node
        highlight(node: result.node)
        
        // check if it material object
        let materialNode = result.node as? MaterialNode
        
        if materialNode == nil {
            print("Touched node is not material")
            return
        }
        
        if (materialNode!.type == .field && currentCharacter != nil) {
            let fieldIndexes = materialNode!.gameID!
                .components(separatedBy: FieldConstants.indexSeparator)
                .map { Int($0)!}
            
            onFieldPress(self, materialNode!, fieldIndexes[0], fieldIndexes[1])
        } else if (materialNode!.type == .material) {
            if let tappedCharacter = findCharacter(by: materialNode!.gameID!) {
                onCharacterPress(self, tappedCharacter)
            }
        }
    }
    
    @objc
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if sender.numberOfTouches == 2 {
            let zoom = sender.scale
            let fov = 1 / (startScale * zoom)
            
            if (sender.state == .began) {
                startScale = lastScale
            } else if (sender.state == .changed && fov < 95) {
                
                cameraNode.camera?.fieldOfView = CGFloat(fov)
                lastScale = startScale * zoom
            }
        }
    }
    
    @objc
    func handlePan(_ sender: UIPanGestureRecognizer) {
        let currentTranslateX = sender.translation(in: view!).x
        let currentTranslateZ = sender.translation(in: view!).y
        
        print(currentTranslateX, currentTranslateZ)
        
        // calculate translation since last measurement
        let translateX = (currentTranslateX - previousTranslateX) / 25
        let translateZ = (currentTranslateZ - previousTranslateZ) / 25
        
        let oldPosition = cameraNode.position
        
        let newCamPosition = SCNVector3(oldPosition.x - Float(translateX), oldPosition.y, oldPosition.z - Float(translateZ))
        cameraNode.position = newCamPosition
        
        // (re-)set previous measurement
        if sender.state == .ended {
            previousTranslateX = 0
            previousTranslateZ = 0
        } else {
            previousTranslateX = currentTranslateX
            previousTranslateZ = currentTranslateZ
        }
    }
}

extension GameVC {
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
