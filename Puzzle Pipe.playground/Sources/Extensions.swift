//
//  Extensions.swift
//  Puzzle Pipe
//
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

extension UIPanGestureRecognizer {
  
  /// Reset the pan gesture
  func resetGesture() {
    self.isEnabled = false
    self.isEnabled = true
  }
}

extension Int
{
  /// Generate a random number contained in a range
  static func random(min: Int, max: Int)-> Int {
    return Int(arc4random_uniform(UInt32(max-min+1)) + UInt32(min));
  }
}

extension Array where Element == [PipeView] {
  
  /// Shuffle the pipes contained in a matrix of pipes view
  mutating func shufflePipes() {
    for row in (0..<self.count).reversed() {
      for col in (0..<self.count).reversed() {
        
        if self.isEmpty {
          return
        }
        let pipesView = self
        let randomRow = Int(arc4random_uniform(UInt32(row + 1)))
        let randomCol = Int(arc4random_uniform(UInt32(col + 1)))
        
        if pipesView[row][col].pipe.isValidToMove() && pipesView[randomRow][randomCol].pipe.isValidToMove() {
          //When the array of pipes is shuffling, not all the attributes of the element must be shuffled, so I'm setting again the previous value of these attributes to accomplish this task
          let firstPipe = pipesView[row][col]
          let secondPipe = pipesView[randomRow][randomCol]
          
          //Here I'm calculating the new points where the pipes are pointing after the shuffle
          if firstPipe.pipe.endPoint != nil {
            var offset = PipePoint()
            offset.row = firstPipe.pipe.endPoint!.row - firstPipe.pipe.point.row
            offset.col = firstPipe.pipe.endPoint!.col - firstPipe.pipe.point.col
            pipesView[row][col].pipe.endPoint = PipePoint(row: randomRow + offset.row, col: randomCol + offset.col)
          }
          
          if firstPipe.pipe.startPoint != nil {
            var offset = PipePoint()
            offset.row = firstPipe.pipe.startPoint!.row - firstPipe.pipe.point.row
            offset.col = firstPipe.pipe.startPoint!.col - firstPipe.pipe.point.col
            pipesView[row][col].pipe.startPoint = PipePoint(row: randomRow + offset.row, col: randomCol + offset.col)
          }
          
          if secondPipe.pipe.endPoint != nil {
            var offset = PipePoint()
            offset.row = secondPipe.pipe.endPoint!.row - secondPipe.pipe.point.row
            offset.col = secondPipe.pipe.endPoint!.col - secondPipe.pipe.point.col
            pipesView[randomRow][randomCol].pipe.endPoint = PipePoint(row: row + offset.row, col: col + offset.col)
          }
          
          if secondPipe.pipe.startPoint != nil {
            var offset = PipePoint()
            offset.row = secondPipe.pipe.startPoint!.row - secondPipe.pipe.point.row
            offset.col = secondPipe.pipe.startPoint!.col - secondPipe.pipe.point.col
            pipesView[randomRow][randomCol].pipe.startPoint = PipePoint(row: row + offset.row, col: col + offset.col)
          }
          
          pipesView[randomRow][randomCol].pipe.point = PipePoint(row: row, col: col)
          pipesView[row][col].pipe.point = PipePoint(row: randomRow, col: randomCol)

          //When all the old attributes interested are setted in the correct position, swap the elements
          self[row][col] = pipesView[randomRow][randomCol]
          self[randomRow][randomCol] = pipesView[row][col]

        }
      }
    }
  }
}
