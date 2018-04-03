//
//  PipePoint.swift
//  Puzzle Pipe
//
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import Foundation

public enum Direction {
  case none
  case up
  case down
  case left
  case right
}

public enum ObstacleType: Int {
  case none
  case movable
  case fixed
}

public enum Position {
  case none
  case yAxis
  case xAxis
}

public enum Difficulty: Int {
  case normal
  case hard
  case veryHard
}

public struct PipePoint: Equatable {
  public var row: Int
  public var col: Int
  
  //Init with -1 to mark a empty point
  public init(row: Int = -1, col: Int = -1) {
    self.row = row
    self.col = col
  }
  
  public static func ==(lhs: PipePoint, rhs: PipePoint) -> Bool {
    return (lhs.row == rhs.row) && (lhs.col == rhs.col)
  }
  
  /// Helper to check if the point already exists in a path
  ///
  /// - Parameter path: array of pipe which is the path where is checking
  /// - Returns: a boolean value to mark if it already exists or not
  public func alreadyExists(in path: [Pipe]) -> Bool {
    for pipe in path {
      if pipe.point != PipePoint(row: -1, col: -1) && pipe.point == self {
        return true
      }
    }
    return false
  }
  
  /// Helper to check if the point has at least a point out of bounds
  ///
  /// - Parameter size: The max size of the matrix
  /// - Returns: boolean value to mark if it has or not a point out of bounds
  public func hasPointOutOfBounds(size: Int) -> Bool {
    return (self.row < 0 || self.row >= size) || (self.col < 0 || self.col >= size)
  }
  
  /// Helper to check if the point in one of the corner
  ///
  /// - Parameter size: The max size of the matrix
  /// - Returns: boolean value to mark if it has or not a point on one corner
  public func isOnTheCorner(of size: Int) -> Bool{
    return (self.row == 0 && self.col == 0) || (self.row == 0 && self.col == size - 1) || (self.row == size - 1 && self.col == 0) || (self.row == size - 1 && self.col == size - 1)
  }
  
  /// Calculate the new points when it is moved in another direction
  ///
  /// - Parameter direction: The direction where the point is moving to
  mutating public func calculateNewPoints(from direction: Direction) {

    switch direction {
      
    case .none:
      break
    case .up:
      self.row -= 1
      break
    case .down:
      self.row += 1
      break
    case .left:
      self.col -= 1
      break
    case .right:
      self.col += 1
      break
    }
  }
  
  /// Helper to check if the point is on diagonal of another point
  ///
  /// - Parameter point: The other point where to check
  /// - Returns: boolean value if it is on the diagonal or not of the point
  public func isOnDiagonal(of point: PipePoint) -> Bool {
    if((self.row == point.row - 1) && (self.col == point.col - 1)) || ((self.row == point.row + 1) && (self.col == point.col - 1)) || ((self.row == point.row - 1) && (self.col == point.col + 1)) || ((self.row == point.row + 1) && (self.col == point.col + 1)) {
      
      //Is not a valid goal point, so create another point
      return true
    }
    return false
  }

  /// Helper to check if the point is in a dead position that can obstacolate the path
  ///
  /// - Parameters:
  ///   - point: The other point to do this check
  ///   - pathSize: The maximum size of the matrix
  /// - Returns: boolean value to mark if this point is in a dead position
  public func isOnDeadPoint(of point: PipePoint, in pathSize: Int) -> Bool {
    
    if ((self.col == 1 && point.col == 1) || (self.col == pathSize-1 && point.col == pathSize-1)) && (self.row+1 == point.row || self.row-1 == point.row) {
        return true
    } else if ((self.row == 1 && point.row == 1) || (self.row == pathSize-1 && point.col == pathSize-1)) || (self.col+1 == point.col || self.col-1 == point.col) {
        return true
    }
    return false
  }

}
