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

enum BodyType: Int {
    case field = 1
    case material = 2
}

class GameVC: UIViewController, SCNPhysicsContactDelegate {
    var cameraNode: SCNNode!
    var scene: SCNScene!
    var cameraHeight: Float = 30
    var startScale: CGFloat = 0
    var lastScale: CGFloat = 1
    var currentCharacter: Character?
    var currentField: Field! {
        didSet {
            scene.rootNode.addChildNode(currentField.node)
            
            let fieldCenter = currentField.centerOfCell(row: (currentField.size / 2),
                                                        column: (currentField.size / 2))
            
            let cameraPosition = SCNVector3(x: fieldCenter.x,
                                            y: fieldCenter.y + cameraHeight,
                                            z: fieldCenter.z)
            
            let moveTo = SCNAction.move(to: cameraPosition, duration: 0);
            
            cameraNode.runAction(moveTo) {
                self.cameraNode.look(at: fieldCenter)
                self.lastScale = 1 / (self.cameraNode.camera?.fieldOfView)!
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        scene = SCNScene()
        scene.physicsWorld.contactDelegate = self

        // set up the camera
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: cameraHeight, z: 15)
        cameraNode.eulerAngles = SCNVector3Make(Float.pi / -3, 0, 0)
        cameraNode.camera!.zFar = 200

        scene.rootNode.addChildNode(cameraNode)
        
        // set up field and characters
        currentField = Field(in: SCNVector3(), cellSize: 10)
        currentCharacter = createCharacter(role: .dps, row: 1, column: 2)
        currentCharacter = createCharacter(role: .tank, row: 2, column: 1)
        currentCharacter = createCharacter(role: .support, row: 2, column: 2)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 20, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // set the scene to the view
        let scnView = self.view as! SCNView
        scnView.scene = scene
        scnView.backgroundColor = UIColor.white
        
        // allows the user to manipulate the camera
        // scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
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
    
    func createCharacter(role: CharacterRole, row: Int, column: Int) -> Character {
        let newCharacter = Character(role: role)
        currentField.put(object: newCharacter.node, row: row, column: column)
        
        return newCharacter
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    }
    
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
            let fieldIndexes = materialNode?.gameID!
                .components(separatedBy: FieldConstants.indexSeparator)
                .map { Int($0)!}
            
            currentField.move(node: currentCharacter!.node, toRow: fieldIndexes![0], column: fieldIndexes![1])
        } else if (materialNode!.type == .material) {
            
        }
    }
    
    @objc
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if sender.numberOfTouches == 2 {
            let zoom = sender.scale
            let fov = 1 / (startScale * zoom)

            if (sender.state == .began) {
                startScale = lastScale
            } else if (sender.state == .changed && fov < 180) {

                cameraNode.camera?.fieldOfView = CGFloat(fov)
                lastScale = startScale * zoom
            }
        }
    }

    var previousTranslateX:CGFloat = 0.0
    var previousTranslateZ:CGFloat = 0.0

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
    
    
    
    
    
    
    
    
    

    func updatePositionAndOrientationOf(_ node: SCNNode, withPosition position: SCNVector3, relativeTo referenceNode: SCNNode) {
        let referenceNodeTransform = matrix_float4x4(referenceNode.transform)
        
        // Setup a translation matrix with the desired position
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.x = position.x
        translationMatrix.columns.3.y = position.y
        translationMatrix.columns.3.z = position.z
        
        // Combine the configured translation matrix with the referenceNode's transform to get the desired position AND orientation
        let updatedTransform = matrix_multiply(referenceNodeTransform, translationMatrix)
        node.transform = SCNMatrix4(updatedTransform)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}
