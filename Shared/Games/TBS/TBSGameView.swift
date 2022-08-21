//
//  ContentView.swift
//  Shared
//
//  Created by Damir Minnegalimov on 04.06.2021.
//

import SwiftUI
import SceneKit

struct TBSGameView: GameView {
  @ObservedObject var game: TBSGame
  @Binding var showing: Bool
  
  var sceneRendererDelegate = SceneRendererDelegate()
  @State var lastCameraOffset = SCNVector3()
  
  var body: some View {

    // Camera drag
    let drag = DragGesture()
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
        .onTapGesture { location in
          pick(atPoint: location)
        }
        .gesture(drag)
        // Make sure ignoresSafeArea is after touch handlers
        // Otherwise, location will be wrong
        .ignoresSafeArea()
      
      VStack(alignment: .leading) {
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
            Button {
              if let currentTeam = game.currentTeam {
                for hero in currentTeam.heroes {
                  hero.node.highlight()
                }
              }
            } label: {
              HStack {
                ForEach(game.teams) { team in
                  Text(team.id)
                    .font(team == game.currentTeam ? .title3 : .caption)
                    .foregroundColor(team == game.currentTeam ? .primary : .secondary)
                }
              }
            }
            .buttonStyle(MaterialButtonStyle())

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
                  
                  game.currentTeam?.heroes.append(hero)
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
        .padding(.horizontal)
        
        Spacer()
        
        // Logger above bottom panels
        
        if game.gameLogger.messages.count > 0 {
          List() {
            ForEach(game.gameLogger.messages.reversed(), id: \.self) { message in
              Text(message)
                .font(.caption2)
                .listRowBackground(Color.clear)
            }
          }
          .scrollContentBackground(.hidden)
          // Hack for stupid ListRow paddings
          .padding(.horizontal, -20)
          .frame(
            minWidth: 90,
            maxWidth: 200,
            maxHeight: 200,
            alignment: .leading)
        }

        // Bottom HUD
        
        if let currentHero = game.currentHero {

          HStack(alignment: .bottom) {
            
            // Bottom Left buttons
            
            VStack(alignment: .leading) {
              
              // Deselect Hero button
              Button {
                withAnimation {
                  game.currentHero = nil
                }
              } label: {
                Image(systemName: "xmark")
              }
              .font(.caption)
              .buttonStyle(MaterialButtonStyle())
              .offset(y: 15)
              
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
                  .padding(0)
                  .listRowBackground(Color.clear)
                  
                  Text(currentHero.name)
                    .font(.headline)
                    .listRowBackground(Color.clear)
                  
                  Text("HP")
                    .badge(String(currentHero.HP))
                    .listRowBackground(Color.clear)
                }
                .disabled(true)
                .listStyle(PlainListStyle())
                // Hack for stupid ListRow paddings
                .padding(.horizontal, -20)
                .scrollContentBackground(.hidden)
                .font(.body)
                .frame(
                  minWidth: 80,
                  maxWidth: 115,
                  maxHeight: 180,
                  alignment: .center)
              }
              .buttonStyle(MaterialButtonStyle())
              
            }
            
            // Abilities of current Hero
            
            ForEach(currentHero.abilities, id: \.name) { ability in
              Button {
                withAnimation {
                  game.gameLogger.post(newMessage: "\(ability.name): \(ability.description)")
                }
                
                ability.action(game, currentHero)
              } label: {
                ability.icon
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(
                    minHeight: 70,
                    maxHeight: 70)
              }
              .padding(3)
              .buttonStyle(MaterialButtonStyle())
              
              // Doesn't work
              .help(ability.description)
              
              // Works
              .contextMenu {
                Text(ability.description)
                  .fixedSize(horizontal: false, vertical: true)
                
                Button {
                  withAnimation {
                    game.gameLogger.post(newMessage: "\(ability.name): \(ability.description)")
                  }
                  
                  ability.action(game, currentHero)
                } label: {
                  Text("Choose")
                }
                
                Button(role: .destructive) {
                } label: {
                  Text("Cancel")
                }
                
              }
              
            }
            
            Spacer()
          }
        }
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
        withAnimation {
          game.pick(materialNode)
        }
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
