//
//  ContentView.swift
//  Shared
//
//  Created by Damir Minnegalimov on 04.06.2021.
//

import SwiftUI
import SceneKit

let cameraHeight: Float = 40

struct GameView: View {
  @Binding var showing: Bool
  @ObservedObject var game: TBSGame
  
  var sceneRendererDelegate = StupidDelegate()
  
  var cameraNode: SCNNode {
    let cameraNode = SCNNode()
    cameraNode.name = "Camera"
    cameraNode.camera = SCNCamera()
    //cameraNode.eulerAngles = SCNVector3Make(Float.pi / -3, 0, 0)
    cameraNode.camera!.zFar = 200
    cameraNode.position = SCNVector3(x: 0, y: cameraHeight, z: cameraHeight)
    
    let fieldCenter = game.field.center()
    cameraNode.look(at: fieldCenter)
    
    return cameraNode
  }
  
  var body: some View {
    // We can't get touch location with TapGesture, so hack:
    // (https://stackoverflow.com/a/56567649/7996650)
    let tap = DragGesture(minimumDistance: 0, coordinateSpace: .global)
      .onEnded { value in
        let translation = value.translation
        
        if abs(translation.height) < 20,
           abs(translation.width) < 20 {
          
          pick(atPoint: value.location)
        }
      }
    
    ZStack {
      SceneView(
        scene: game.scene,
        pointOfView: cameraNode,
        options: [
          .allowsCameraControl,
          .temporalAntialiasingEnabled
        ],
        delegate: sceneRendererDelegate)
        .ignoresSafeArea()
        .onAppear() {
          game.prepare()
          game.scene.background.contents = Color.DarkTheme.Violet.background.cgColor
        }
        .gesture(tap)
      
      VStack {
        // Top HUD
        
        HStack() {
          // Top left botton
          Button {
            showing.toggle()
          } label: {
            Image(systemName: "xmark")
          }
          .buttonStyle(MaterialButtonStyle())
          
          Spacer()
          
          // Top Right button
          if let currentCell = game.currentFieldCell {
            // Menu for adding new heroes
            // if we have choosen field cell
            
            Menu(content: {
              ForEach(Heroes.all) { hero in
                Button {
                  game.entities?.append(hero)
                  game.field.put(
                    object: hero.node,
                    to: currentCell)
                } label: {
                  Label {
                    Text(hero.name)
                  } icon: {
                    hero.image
                  }
                }
              }
            }, label: {
              Button {} label: {
                Image(systemName: "plus")
              }
              .buttonStyle(MaterialButtonStyle())
            })
          }
        }
        .font(.largeTitle)
        .padding(.horizontal, 5)
        
        Spacer()
        
        // Bottom HUD
        HStack(alignment: .bottom) {

          // Bottom Left buttons

          if let currentHero = game.currentHero {
            Button {
              currentHero.node.highlight(for: 0.2)
            } label: {
              List() {
                // TODO: Fix centered image
                HStack {
                  Spacer()

                  currentHero.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                      width: 70,
                      height: 70)

                  Spacer()
                }
                .padding(5)
                .listRowBackground(Color.clear)

                Text(currentHero.name)
                  .font(.headline)
                  .listRowBackground(Color.clear)
                
                Text("HP")
                  .badge(String(currentHero.HP))
                  .listRowBackground(Color.clear)
              }
              .listStyle(PlainListStyle())
              .font(.body)
              .padding(.horizontal, -12)
              .frame(
                maxWidth: 120,
                maxHeight: 180,
                alignment: .center)
            }
            .buttonStyle(MaterialButtonStyle())
          }

          Spacer()
          
          // Bottom Right buttons
          if let currentHero = game.currentHero {
            // Abilities of current Hero
            ForEach(currentHero.abilities, id: \.name) { ability in
              Button {
                ability.action(game, currentHero)
              } label: {
                ability.icon
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(
                    minWidth: 50,
                    maxWidth: 70,
                    maxHeight: 70)
              }
              .buttonStyle(MaterialButtonStyle())
            }
          }
        }
        .font(.largeTitle)
        .padding(5)
      }
    }
  }
}

extension GameView {
  func pick(atPoint point: CGPoint) {
    print("Pick requested for point: \(point)")
    
    // Find closest node
    if let firstNode = findFirstTouchableNode(atPoint: point) {
      if let materialNode = firstNode as? MaterialNode {
        game.pick(materialNode)
      } else {
        print("Touched node is not material:", firstNode.name ?? "<NO NAME>")
        return
      }
    }
  }
  
  func findFirstNode(atPoint point: CGPoint) -> SCNNode? {
    guard let sceneRenderer = sceneRendererDelegate.renderer else {
      print("There is no SceneRenderer!")
      return nil
    }
    
    let hitResults = sceneRenderer.hitTest(point, options: [:])
    
    if hitResults.count == 0 {
      // check that we clicked on at least one object
      return nil
    }
    
    // retrieved the first clicked object
    let hitResult = hitResults[0]
    
    return hitResult.node
  }
  
  func findFirstTouchableNode(atPoint point: CGPoint) -> SCNNode? {
    guard let sceneRenderer = sceneRendererDelegate.renderer else {
      print("There is no SceneRenderer!")
      return nil
    }
    
    let options: [SCNHitTestOption : Any] = [SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue]
    let hitResults = sceneRenderer.hitTest(point, options: options)
    
    if hitResults.count == 0 {
      // check that we clicked on at least one object
      return nil
    }
    
    // retrieved the first clicked object
    let hitResult = hitResults.first { $0.node.physicsBody != nil }
    
    return hitResult?.node
  }
}
