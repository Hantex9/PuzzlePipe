//
//  PipeView.swift
//  Puzzle Pipe
//
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

public class PipeView: UIView {
  
  //MARK: - UI Properties
  public let buttonPipe: UIButton = {
    let buttonPipe = UIButton(type: .custom)
    buttonPipe.imageView?.contentMode = .scaleAspectFill
    buttonPipe.isUserInteractionEnabled = false
    return buttonPipe
  }()
  
  //MARK: - General Properties
  weak var delegate: PipeViewDelegate?
  
  public lazy var startingPoint: CGPoint = CGPoint()
  public var pipe: Pipe = Pipe()
  
  fileprivate var positionMoving: Position = .none
  fileprivate var isFirstTouch: Bool = false
  
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    let pan = UIPanGestureRecognizer(target: self, action: #selector(PipeView.handlePan(_:)))
    self.addGestureRecognizer(pan)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    buttonPipe.frame = CGRect(x: 0, y: 0, width: self.frame.width - UI.cellPadding*2, height: self.frame.height - UI.cellPadding*2)
    
    self.addSubview(buttonPipe)
  }
  
  /// Pan handler applied on the PipeView, it recognize where is moving and if the position where the user is trying to go is a valid position (so it is moving toward an empty block)
  @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
    
    let translation = recognizer.translation(in: self)
    
    switch recognizer.state {
    case .began:
      self.isFirstTouch = true
    
    case .changed:
      
      if self.isFirstTouch {
        //Recognize if the finger is moving in horizzontally or vertically and then check if is moving left/right or up/down
        let velocity = recognizer.velocity(in: self)
        var position: Direction = .none
        self.isFirstTouch = false
        if fabs(velocity.x) > fabs(velocity.y) {
          self.positionMoving = .xAxis
          position = (velocity.x < 0) ? .left : .right
        } else if fabs(velocity.y) > fabs(velocity.x) {
          self.positionMoving = .yAxis
          position = (velocity.y < 0) ? .up : .down
        }
        
        // Calls the delegate method to wait the Controller that tells if this pipeView can be moved or not in this new position
        if self.delegate?.pipeView(self, shouldMove: position) == false {
          recognizer.resetGesture()
          recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
          return
        }
      }
      
      //Move the view following the pan
      if self.positionMoving == .xAxis {
        self.center.x += translation.x
      } else if self.positionMoving == .yAxis {
        self.center.y += translation.y
      }
      recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
      
      //If it reach the 1/5 of the View position, so move it to this point
      if self.center.x > self.startingPoint.x + (self.frame.size.width/5) {
        self.move(to: .right)
        recognizer.resetGesture()
      } else if self.center.x < self.startingPoint.x - (self.frame.size.width/5) {
        self.move(to: .left)
        recognizer.resetGesture()
      } else if self.center.y > self.startingPoint.y + (self.frame.size.width/5) {
        self.move(to: .down)
        recognizer.resetGesture()
      } else if self.center.y < self.startingPoint.y - (self.frame.size.width/5) {
        self.move(to: .up)
        recognizer.resetGesture()
      }
        
    case .ended :
      //Reset the position to the starting one
      UIView.animate(withDuration: 0.1) {
        self.center = self.startingPoint
        self.positionMoving = .none
      }
    default:
      break
    }
  }
  
  /// Move a View in a direction
  ///
  /// - Parameter direction: The direction where is moving to
  fileprivate func move(to direction: Direction) {
    
    //Calls the delegate method to check if is moving in a good direction or not
    guard let pipe = self.delegate?.pipeView(self, didMove: direction) else {
      self.center = self.startingPoint
      return
    }
    self.pipe = pipe
    
    //If it is moving in a good direction, set the new point of the View with an animation
    switch direction {
    case .right:
      UIView.animate(withDuration: 0.05){
        self.center.x = self.startingPoint.x + self.frame.width
        self.startingPoint.x = self.center.x
      }
      break
    case .left:
      UIView.animate(withDuration: 0.05){
        self.center.x = self.startingPoint.x - self.frame.width
        self.startingPoint.x = self.center.x
      }
      break
    case .up:
      UIView.animate(withDuration: 0.05){
        self.center.y = self.startingPoint.y - self.frame.width
        self.startingPoint.y = self.center.y
        }
      break
    case .down:
      UIView.animate(withDuration: 0.05){
        self.center.y = self.startingPoint.y + self.frame.width
        self.startingPoint.y = self.center.y
      }
      break
    case .none:
      break
    }
    
  }
  
  /// Shows the PipeView with his attributes
  ///
  /// - Parameter isFirstTime: Bool value that marks if is the first time that the PipeView is shown
  public func show(isFirstTime: Bool) {
  
    self.isUserInteractionEnabled = true
    self.frame.origin = CGPoint(x: self.frame.width * CGFloat(self.pipe.point.col) + UI.cellPadding, y: self.frame.width * CGFloat(self.pipe.point.row) + UI.cellPadding)
    self.startingPoint = self.center
    
    //If is the first time, generate an image and set his rotate orientation
    if isFirstTime {
      let generatedImage = self.pipe.generateImage()
      self.buttonPipe.setBackgroundImage(generatedImage.image, for: .normal)
      self.buttonPipe.transform = CGAffineTransform(rotationAngle: generatedImage.rotation)
    }
    
  }
  
}

