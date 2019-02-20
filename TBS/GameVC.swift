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
import ARKit

enum GameRenderMode: Int {
    case regular = 1
    case ar = 2
}

enum BodyType: Int {
    case field = 1
    case ship = 2
}

var cameraHeight: Float = 100
var startScale: CGFloat = 0
var lastScale: CGFloat = 1

class GameVC: UIViewController, SCNPhysicsContactDelegate {
    var sceneView: ARSCNView!
    var cameraNode: SCNNode!
    var scene: SCNScene!
    var currentCharacter: Character?
    var currentField: Field! {
        didSet {
//            scene.rootNode.addChildNode(currentField.node)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = ARSCNView()
        self.view = sceneView
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.showsStatistics = true
        
        // Create a new scene
        scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene

        scene.physicsWorld.contactDelegate = self

        // create and add a camera to the scene
//        cameraNode = SCNNode()
//        cameraNode.camera = SCNCamera()
//        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
//        cameraNode.position = SCNVector3(x: 0, y: cameraHeight, z: 15)
//        cameraNode.eulerAngles = SCNVector3Make(Float.pi / -3, 0, 0)
//        cameraNode.camera!.zFar = 200
        // cameraNode.look(at: SCNVector3(0, 0, 0))
        
        // retrieve the ship node
//        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
//        ship.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
//        ship.physicsBody?.categoryBitMask = BodyType.ship.rawValue
//        ship.physicsBody?.collisionBitMask = BodyType.field.rawValue
//        ship.physicsBody?.contactTestBitMask = BodyType.field.rawValue
        
        // animate the 3d object
        // ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        // add a pinch gesture recognizer
//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//        sceneView.addGestureRecognizer(pinchGesture)

        // add a pan gesture recognizer
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        view.addGestureRecognizer(pan)
    }
    
    func createField(in position: SCNVector3 = SCNVector3(0, 0, 0)) -> Field {
        let newField = Field(in: position)
        
//        let newCameraCenter = SCNVector3(Float((newField.cellSize / 2) * (newField.size + 1)), cameraHeight, Float((newField.cellSize / 2) * (newField.size + 1)))
//        let moveTo = SCNAction.move(to: newCameraCenter, duration: 0);
//
//        cameraNode.runAction(moveTo) {
//            self.cameraNode.look(at: newField.center)
//            self.lastScale = 1 / (self.cameraNode.camera?.fieldOfView)!
//        }
        
        return newField
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("contact!")
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // check what nodes are tapped
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.clear
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            SCNTransaction.commit()
        }
    }
    
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if sender.numberOfTouches == 2 {
            let zoom = sender.scale
            print("startScale:", startScale, "lastScale", lastScale, "zoom", zoom)

            if (sender.state == .began){
                startScale = lastScale
            } else if (sender.state == .changed){
                let fov = 1 / (startScale * zoom)
                print("fov:", fov)

//                cameraNode.camera?.fieldOfView = CGFloat(fov)
                lastScale = startScale * zoom
            }
        }
    }

    var previousTranslateX:CGFloat = 0.0
    var previousTranslateZ:CGFloat = 0.0

    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        let currentTranslateX = sender.translation(in: view!).x
        let currentTranslateZ = sender.translation(in: view!).y
        
        print(currentTranslateX, currentTranslateZ)

        // calculate translation since last measurement
        let translateX = (currentTranslateX - previousTranslateX) / 25
        let translateZ = (currentTranslateZ - previousTranslateZ) / 25

        let oldPosition = cameraNode.position
        
        let newCamPosition = SCNVector3(oldPosition.x - Float(translateX), oldPosition.y, oldPosition.z - Float(translateZ))
//        cameraNode.position = newCamPosition
        
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

// MARK: - ARSCNViewDelegate

extension GameVC: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        
        currentField = createField(in: SCNVector3(x, y, z))
        node.addChildNode(currentField.node)
        
        let newCharacter = Character(role: .dps, in: currentField.node.position)
        node.addChildNode(newCharacter.node)

        currentCharacter = newCharacter
    }

    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        guard let planeAnchor = anchor as?  ARPlaneAnchor,
//            let planeNode = node.childNodes.first,
//            let plane = planeNode.geometry as? SCNPlane
//            else { return }
//
//        let width = CGFloat(planeAnchor.extent.x)
//        let height = CGFloat(planeAnchor.extent.z)
//        plane.width = width
//        plane.height = height
//
//        let x = CGFloat(planeAnchor.center.x)
//        let y = CGFloat(planeAnchor.center.y)
//        let z = CGFloat(planeAnchor.center.z)
//        planeNode.position = SCNVector3(x, y, z)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
