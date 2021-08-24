//
//  VirtualController.swift
//  VirtualController
//
//  Created by Damir Minnegalimov on 24.08.2021.
//

import GameController


class SuperController {
  
  var virtualController: GCVirtualController? = nil
  
  var handleLeftPad: GCControllerDirectionPadValueChangedHandler? = nil {
    didSet {
      // TODO: Handle cases when keyboard or gamepad is available
      
      if let leftPad = virtualController?.controller?.extendedGamepad?.leftThumbstick {
        leftPad.valueChangedHandler = handleLeftPad
      }
    }
  }
  
  var handleRightPad: GCControllerDirectionPadValueChangedHandler? = nil {
    didSet {
      // TODO: Handle cases when keyboard or gamepad is available

      if let rightPad = virtualController?.controller?.extendedGamepad?.rightThumbstick {
        rightPad.valueChangedHandler = handleRightPad
      }
    }
  }
  
  init(elements: Set<String>) {
    // TODO: Handle cases when keyboard or gamepad is available
    
    let isKeyboardConnected = GCKeyboard.coalesced != nil
    
    if isKeyboardConnected {
      print("Keyboard is connected")
    }
    
    let isGamepadConnected = GCController.controllers().count > 0

    if isGamepadConnected {
      print("Gamepad is connected")
    }
    
    if !isKeyboardConnected && !isGamepadConnected {
      print("There is no keyboard or gamepad so just create Virtual one")
      
      virtualController = createVirtualController(elements)
    }
  }
  
  func connect() {
    if let virtualController = virtualController {
      virtualController.connect()
    }
  }
  
  func disconnect() {
    if let virtualController = virtualController {
      virtualController.disconnect()
    }
  }
}


let createVirtualController = { (elements: Set<String>) -> GCVirtualController in

  // Earlier I used `fullScreenCover` for games in MenuScreen,
  // but GCVirtualController was BELOW it.
  // So keep GCVirtualController in View, not Overlay/Modal/Sheet containers
  // https://developer.apple.com/forums/thread/682138

  let virtualConfiguration = GCVirtualController.Configuration()
  virtualConfiguration.elements = [GCInputLeftThumbstick, GCInputRightThumbstick]

  let virtualController = GCVirtualController(configuration: virtualConfiguration)
    
  return virtualController
}
