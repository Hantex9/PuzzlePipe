//
//  GameSettings.swift
//  Puzzle Pipe
//
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

// General settings of the game
public class GameSettings {
  static public var matrixSize = 3
  static public var difficulty: Difficulty = .normal
  static public var shuffled: Bool = true
}

//UI constants
public enum UI {
  static public let cellPadding: CGFloat = 3.0 / CGFloat(GameSettings.matrixSize) * 2.0
}
