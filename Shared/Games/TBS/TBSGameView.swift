//
//  ContentView.swift
//  Shared
//
//  Created by Damir Minnegalimov on 04.06.2021.
//

import SwiftUI
import SceneKit

struct TBSGameView: GameView {
  @Binding var showing: Bool
  @ObservedObject var game: TBSGame
  
  var sceneRendererDelegate = SceneRendererDelegate()
  @State var lastCameraOffset = SCNVector3()
  
  var body: some View {

    // Camera drag
    let drag = DragGesture(coordinateSpace: .global)
      .onChanged({ gesture in
        if let camera = sceneRendererDelegate.renderer?.pointOfView {
          let translation = gesture.translation
          let translationVector = SCNVector3(translation.width * 0.05,
                                             0,
                                             translation.height * 0.05)
          let dVector = lastCameraOffset - translationVector
          
          let action = SCNAction.move(by: dVector, duration: 0.1)
          camera.runAction(action)
          
          lastCameraOffset = translationVector
        }
      })
      .onEnded { gesture in
        lastCameraOffset = SCNVector3()
      }
    
    ZStack {
      SceneView(
        scene: game.scene,
        options: [
          .temporalAntialiasingEnabled
        ],
        delegate: sceneRendererDelegate)
        .ignoresSafeArea()
        .onTapGesture { location in
          pick(atPoint: location)
        }
        .gesture(drag)
      
      VStack {
        // Top HUD
        
        HStack {
          // Top left botton
          Button {
            showing.toggle()
          } label: {
            Image(systemName: "xmark")
          }
          .buttonStyle(MaterialButtonStyle())
          
          Spacer()
          
          HStack {
            ForEach(game.teams) { team in
              Text(team.id)
                .font(team == game.currentTeam ? .title3 : .caption)
                .onTapGesture {
                  for hero in team.heroes {
                    hero.node.highlight()
                  }
                }
            }
          }
          
          Spacer()
          
          // Top Right button
          if let currentCell = game.currentFieldCell {
            // Menu for adding new heroes
            // if we have choosen field cell
            
            Menu(content: {
              ForEach(Heroes.all()) { hero in
                Button {
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
        .padding(.horizontal)
        
        Spacer()
        
        // Bottom HUD
        HStack(alignment: .bottom) {
          // Bottom Left buttons
          VStack(alignment: .leading) {
            
            if let currentHero = game.currentHero {
              // Deselect Hero button
              // TODO: Make it above (zIndex kind of) the Hero panel
              Button {
                game.currentHero = nil
              } label: {
                Image(systemName: "xmark")
              }
              .font(.title3)
              .buttonStyle(MaterialButtonStyle())
              .offset(y: 5)
              
              // Current Hero panel
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
                // Hack for stupid ListRow paddings
                .padding(.horizontal, -12)
                .frame(
                  minWidth: 90,
                  maxWidth: 120,
                  maxHeight: 180,
                  alignment: .center)
              }
              .buttonStyle(MaterialButtonStyle())
            }
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
                    minWidth: 30,
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

extension TBSGameView {
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
