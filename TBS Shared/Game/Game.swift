//
//  GameController.swift
//  TBS Shared
//
//  Created by Damik Minnegalimov on 19/05/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import SceneKit

enum BodyType: Int {
    case field = 1
    case material = 2
}

let defaultOnCharacterPress: ((Game, Character) -> Void) = { gameVC, charater in gameVC.currentCharacter = charater }
let defaultOnFieldPress: ((Game, MaterialNode, Int, Int) -> Void) = { game, cellNode, row, column in
    game.currentField.move(node: game.currentCharacter!.node, toRow: row, column: column)
}

class Game: NSObject, SCNSceneRendererDelegate {
    var cameraNode: SCNNode!
    var lightNode: SCNNode!
    var scene: SCNScene!
    let sceneRenderer: SCNSceneRenderer!
    var cameraHeight: CGFloat = FieldConstants.defaultCellSize * 7
    
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
                                            y: fieldCenter.y + cameraHeight.universal(),
                                            z: fieldCenter.z + cameraHeight.universal())
            
            let moveCamera = SCNAction.move(to: cameraPosition, duration: 0);
            
            cameraNode.runAction(moveCamera) {
                self.cameraNode.look(at: fieldCenter)
                self.lightNode.position = SCNVector3(x: fieldCenter.x,
                                                     y: fieldCenter.y + FieldConstants.defaultCellSize.universal() * 5,
                                                     z: fieldCenter.z)
                self.lightNode.look(at: fieldCenter)
                self.lastScale = 1 / (self.cameraNode.camera?.fieldOfView)!
            }
        }
    }
    
    var onCharacterPress: ((Game, Character) -> Void)!
    var onFieldPress: ((Game, MaterialNode, Int, Int) -> Void)!

    init(sceneRenderer renderer: SCNSceneRenderer) {
        sceneRenderer = renderer
        
        // create a new scene
        scene = SCNScene()

        super.init()
        
        sceneRenderer.delegate = self
        scene.physicsWorld.contactDelegate = self
        
        // set up the camera
        cameraNode = SCNNode()
        cameraNode.name = "Camera"
        cameraNode.camera = SCNCamera()
        cameraNode.eulerAngles = SCNVector3Make(Float.pi.universal() / -3, 0, 0)
        cameraNode.camera!.zFar = 200
        
        scene.rootNode.addChildNode(cameraNode)
        
        // set the scene to the view
        let scnView = sceneRenderer as! SCNView
        scnView.scene = scene
        scnView.backgroundColor = SCNColor.black
        
        // set up overlay
        let overlayScene = OverlayHUD(size: scnView.bounds.size)
        overlayScene.backgroundColor = SCNColor.lightBlue
        overlayScene.scaleMode = .resizeFill
        scnView.overlaySKScene = overlayScene
        overlay = overlayScene
        
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
        ambientLightNode.light!.color = SCNColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        defer {
            // set up field and characters
            currentField = Field(in: SCNVector3())
            createCharacters(random: false)
            onCharacterPress = defaultOnCharacterPress
            onFieldPress = defaultOnFieldPress
        }
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

    func tap(atPoint point: CGPoint) {
        let hitResults = self.sceneRenderer.hitTest(point, options: [:])

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
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Called before each frame is rendered
    }
}

extension Game: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("contact")
    }
}
