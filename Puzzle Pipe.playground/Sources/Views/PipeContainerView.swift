//
//  PipeContainerView.swift
//  Puzzle Pipe
//
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

protocol PipeViewDelegate: class {

  func pipeView (_ pipeContainer: PipeContainerView, didCreate pipeView: PipeView, at pipePoint: PipePoint) -> PipeView
  func pipeView (_ pipeView: PipeView, didMove direction: Direction) -> Pipe?
  func pipeView (_ pipeView: PipeView, shouldMove direction: Direction) -> Bool
}


public class PipeContainerView: UIView {

  weak var delegate: PipeViewDelegate?
  
  public var pipesView = [[PipeView]]()
  public var pathGenerator: PathGenerator = PathGenerator(pathSize: GameSettings.matrixSize)
  
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
    self.isUserInteractionEnabled = true
    
  }
  
  /// Create a cell of a grid (the borders)
  ///
  /// - Parameters:
  ///   - row: The row of the cell
  ///   - col: The col o the cell
  ///   - cellSize: The size of the cell
  fileprivate func createCellGrid(row: Int, col: Int, cellSize: CGFloat) {
    let gridView = UIView(frame: CGRect(x: cellSize * CGFloat(row), y: cellSize * CGFloat(col) , width: cellSize, height: cellSize))
    gridView.backgroundColor = .clear
    gridView.layer.borderWidth = UI.cellPadding
    gridView.isUserInteractionEnabled = false
    gridView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.30).cgColor
    self.insertSubview(gridView, at: 1)
  }
  
  /// Create the pipes view on the matrix
  ///
  /// - Parameter size: The max size of the matrix
  public func createPipes(size: Int) {

    //Calculate the cellSize
    let cellSize = ((self.frame.width) / CGFloat(size))

    pipesView = [[PipeView]]()
    for i in 0..<size {
      var rowPipesView = [(PipeView)]()
      for j in 0..<size {
        //Start to create a PipeView in this position
        
        self.createCellGrid(row: i, col: j, cellSize: cellSize)
        
        let pipeView = PipeView(frame: CGRect(x: 0, y: 0, width: cellSize, height: cellSize) )
        let pipePoint = PipePoint(row: i, col: j)
        
        //Calls the delegate method to get the properties of this PipeView at this Point
        if let pipeView = self.delegate?.pipeView(self, didCreate: pipeView, at: pipePoint) {
          
          rowPipesView.append(pipeView)
          
          if !pipeView.pipe.isEmpty {
            self.addSubview(pipeView)
          } else {
            pipeView.removeFromSuperview()
          }
        }
      }
      pipesView.append(rowPipesView)
    }
    
    //After created the Views, show them setting the UI properties
    for pipes in pipesView {
      for pipeView in pipes {
        pipeView.show(isFirstTime: true)
      }
    }
    
    if GameSettings.shuffled {
      // When the matrix is shuffled can happen that creates already a right path, to avoid that shuffle again until the path shuffled is not the right one
      repeat {
        self.pipesView.shufflePipes()
      } while self.pathGenerator.checkWin(of: self.pipesView, isShufflingCheck: true)
    }
    
    self.updateLayout(of: self.pipesView)
  }
  
  /// Update the Pipes View layout
  ///
  /// - Parameter pipesView: array of PipeView to update
  private func updateLayout(of pipesView: [[PipeView]]) {
    
    for pipesViewCollection in pipesView {
      for pipeView in pipesViewCollection {
        pipeView.show(isFirstTime: false)
      }
    }
  }
  
  /// Create the lighting effect on the path traveled
  ///
  /// - Parameters:
  ///   - path: The path traveled
  ///   - completion: Marks when the effect ends
  public func winEffect(with path: [Pipe], completion: @escaping () -> ()) {

    let aPath = UIBezierPath()
    
    let cellSize = self.frame.width / CGFloat(GameSettings.matrixSize)
    aPath.move(to: CGPoint(x: cellSize*CGFloat(path[0].point.col) + (cellSize/2), y: cellSize*CGFloat(path[0].point.row) + (cellSize/2)))
    for singlePath in path {
        aPath.addLine(to: CGPoint(x: cellSize*CGFloat(singlePath.point.col) + cellSize/2, y: cellSize*CGFloat(singlePath.point.row) + cellSize/2))
    }

    let shapeLayer = CAShapeLayer()
    shapeLayer.lineCap = CAShapeLayerLineCap.round
    shapeLayer.lineJoin = CAShapeLayerLineJoin.round
    shapeLayer.path = aPath.cgPath
    shapeLayer.strokeColor = UIColor.white.cgColor
    
    shapeLayer.lineWidth =  20 * cellSize / 76
    shapeLayer.fillColor = UIColor.clear.cgColor
    
    let shadowLayer = CALayer()
    shadowLayer.shadowColor = UIColor.white.cgColor
    shadowLayer.shadowOffset = CGSize.zero
    shadowLayer.shadowRadius = 10.0
    shadowLayer.shadowOpacity = 0.8
    shadowLayer.backgroundColor = UIColor.clear.cgColor
    shadowLayer.addSublayer(shapeLayer)
    
    self.layer.addSublayer(shadowLayer)
    
    CATransaction.begin()
    CATransaction.setCompletionBlock({
      completion()
    })
    
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.fromValue = 0
    animation.duration = 0.5
    shapeLayer.add(animation, forKey: "linePathAnimation")
    CATransaction.commit()
  }
  
  /// Helper to move a pipe point in another point calculating the new pointed point
  ///
  /// - Parameters:
  ///   - oldPoint: The PipePoint to move
  ///   - point: The new Point where the PipePoint moves
  ///   - direction: The Direction where is moving this point
  public func move(_ oldPoint: PipePoint, to point: PipePoint, direction: Direction) {
    
    pipesView[point.row][point.col].pipe.point = PipePoint(row: oldPoint.row, col: oldPoint.col)
    pipesView[oldPoint.row][oldPoint.col].pipe.startPoint?.calculateNewPoints(from: direction)
    pipesView[oldPoint.row][oldPoint.col].pipe.endPoint?.calculateNewPoints(from: direction)
    
    pipesView[oldPoint.row][oldPoint.col].pipe.point = PipePoint(row: point.row, col: point.col)
    
    let tmp = pipesView[oldPoint.row][oldPoint.col]
    pipesView[oldPoint.row][oldPoint.col] = pipesView[point.row][point.col]
    pipesView[point.row][point.col] = tmp
  }
}
