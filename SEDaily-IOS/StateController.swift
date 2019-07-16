//
//  StateController.swift
//  ExpandableOverlay
//
//  Created by Dawid Cedrych on 6/18/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import Foundation

class StateController {
  
	var isFirstLoad = true
  
  var isOverlayShowing = false
  
  private var currentlyPlayingId: String = ""
  
  func setCurrentlyPlaying(id: String) {
    currentlyPlayingId = id
  }
  
  func getCurrentlyPlayingId()-> String {
    return currentlyPlayingId
  }
}
