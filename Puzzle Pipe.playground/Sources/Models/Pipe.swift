//
//  Pipe.swift
//  Puzzle Pipe
//
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit
import Foundation

public struct Pipe {
  
  public var image: UIImage = UIImage()
  public var isEmpty: Bool = false 
  public var startPoint: PipePoint?
  public var endPoint: PipePoint?
  public var point: PipePoint
  public var obstacle: ObstacleType
  public var isFirstPoint: Bool
  public var isLastPoint: Bool!
  
  public init(isEmpty: Bool = false, point: PipePoint = PipePoint() , startPoint: PipePoint? = nil, endPoint: PipePoint? = nil, obstacle: ObstacleType = .none, isFirstPoint: Bool = false, isLastPoint: Bool = false) {
    self.isEmpty = isEmpty
    self.point = point
    self.startPoint = startPoint
    self.endPoint = endPoint
    self.obstacle = obstacle
    self.isFirstPoint = isFirstPoint
    self.isLastPoint = isLastPoint
  }
  
  /// Check if the pipe is valid to move in another point
  ///
  /// - Returns: Boolean value that marks if it can be moved or not
  public func isValidToMove() -> Bool {
    return !self.isSpecialPoint() && self.obstacle != .fixed
  }
  
  /// Check if the pipe is the start point or the goal point
  ///
  /// - Returns: Boolean value that marks if it is or not a special point
  public func isSpecialPoint() -> Bool {
    return self.isFirstPoint || self.isLastPoint
  }
  
  /// Helper to generate an image and his orientation based on the points where the pipe is pointing
  ///
  /// - Returns: tuple of the image and his rotate orientation
  public func generateImage() -> (image: UIImage, rotation: CGFloat){
    
    let actualRow = self.point.row
    let actualCol = self.point.col
    let fromRow = self.startPoint?.row
    let fromCol = self.startPoint?.col
    let toRow = self.endPoint?.row
    let toCol = self.endPoint?.col
    
    var image = UIImage()
    var rotation: CGFloat = 0.0
    
    if self.obstacle == .fixed {
      return (image: UIImage(named: "fixedObstacle")!, rotation: 0.0)
    } else if self.obstacle == .movable {
      return (image: UIImage(named: "movableObstacle")!, rotation: 0.0)
    }
    
    //Here I'm calculating where the pipes are pointing, this to create the right rotate orientation
    if let toCol = toCol, let toRow = toRow, let fromCol = fromCol, let fromRow = fromRow {
      //It is a normal pipe
      let straightImage = UIImage(named: "straightPipe")!
      let cornerImage = UIImage(named: "cornerPipe")!
      
      if (fromCol == toCol) && (toRow < actualRow || fromRow < actualRow) {
        // from up/down to down/up
        image = straightImage
        rotation = 0.0
      } else if (fromRow == toRow) && (toCol < actualCol || fromCol < actualCol) {
        // from left/right to right/left
        image = straightImage
        rotation = CGFloat.pi / 2
      } else if (fromCol < actualCol || toCol < actualCol) && (toRow > actualRow || fromRow > actualRow) {
        // from right/down to down/right
        image = cornerImage
        rotation = -CGFloat.pi
      } else if (fromRow > actualRow || toRow > actualRow) && (toCol > actualCol || fromCol > actualCol) {
        // from right/down to down/right
        image = cornerImage
        rotation = CGFloat.pi / 2
      } else if (fromCol < actualCol || toCol < actualCol) && (toRow < actualRow || fromRow < actualRow) {
        // from right/up to up/right
        image = cornerImage
        rotation = -(CGFloat.pi / 2)
      } else if (fromCol > actualCol || toCol > actualCol) && (toRow < actualRow || fromRow < actualRow ) {
        // from up/down to down/up
        image = cornerImage
        rotation = 0.0
      }
    } else if let toCol = toCol, let toRow = toRow {
      //It is a special pipe
      image = UIImage(named: "specialPipe")!
      
      if toRow < actualRow {
        rotation = -(CGFloat.pi/2)
      } else if toRow > actualRow {
        rotation = (CGFloat.pi/2)
      } else if toCol < actualCol {
        rotation = CGFloat.pi
      } else if toCol > actualCol {
        rotation = 0.0
      }
      
    } else if let fromCol = fromCol, let fromRow = fromRow {
      //It is a special pipe
      image = UIImage(named: "specialPipe")!
      
      if fromRow < actualRow {
        rotation = -(CGFloat.pi/2)
      } else if fromRow > actualRow {
        rotation = CGFloat.pi/2
      } else if fromCol < actualCol {
        rotation = CGFloat.pi
      } else if fromCol > actualCol {
        rotation = 0.0
      }
    }
    return (image: image, rotation: rotation)
  }
  
}
