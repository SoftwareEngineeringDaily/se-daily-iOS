//
//  PlaybackSpeed.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 16/07/2019.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import Foundation

enum PlaybackSpeed: Float {
  case _1x = 1.0
  case _1_2x = 1.2
  case _1_4x = 1.4
  case _1_6x = 1.6
  case _1_8x = 1.8
  case _2x = 2.0
  case _2_5x = 2.5
  case _3x = 3.0
  
  var title: String {
    switch self {
    case ._1x:
      return "1x (Normal Speed)"
    case ._1_2x:
      return "1.2x"
    case ._1_4x:
      return "1.4x"
    case ._1_6x:
      return "1.6x"
    case ._1_8x:
      return "1.8x"
    case ._2x:
      return "⏩ 2x ⏩"
    case ._2_5x:
      return "2.5x"
    case ._3x:
      return "🔥 3x 🔥"
    }
  }
  
  var shortTitle: String {
    switch self {
    case ._1x:
      return "1x"
    case ._1_2x:
      return "1.2x"
    case ._1_4x:
      return "1.4x"
    case ._1_6x:
      return "1.6x"
    case ._1_8x:
      return "1.8x"
    case ._2x:
      return "2x"
    case ._2_5x:
      return "2.5x"
    case ._3x:
      return "3x"
    }
  }
}
