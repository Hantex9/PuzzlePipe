//
//  ProgressBarView.swift
//  Puzzle Pipe
//
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit

protocol ProgressBarViewDelegate: class {
  
  func didFinish(_ timerBarView: ProgressBarView)
  
}

class ProgressBarView: UIView {
  
  //MARK: - UI Properties
  fileprivate let scoreBonusLabel: UILabel = {
    let scoreBonusLabel = UILabel()
    scoreBonusLabel.font = UIFont(name: "TitilliumWeb-SemiBold", size: 17)
    scoreBonusLabel.adjustsFontSizeToFitWidth = true
    scoreBonusLabel.textColor = UIColor(red: 0/255.0, green: 199/255.0, blue: 182/255.0, alpha: 1.0)
    scoreBonusLabel.numberOfLines = 1
    scoreBonusLabel.textAlignment = .center
    return scoreBonusLabel
  }()
  
  fileprivate let progressView: UIView = {
    let progressView = UIView()
    progressView.backgroundColor = UIColor(red: 78/255, green: 196/255, blue: 182/255, alpha: 1)
    progressView.layer.anchorPoint = CGPoint.zero
    return progressView
  }()
  
  fileprivate let labelBonus: UILabel = {
    let labelBonus = UILabel()
    labelBonus.text = "Bonus"
    labelBonus.sizeToFit()
    labelBonus.font = UIFont(name: "TitilliumWeb-Light", size: 19)
    labelBonus.textColor = .white
    labelBonus.numberOfLines = 1
    labelBonus.adjustsFontSizeToFitWidth = true
    return labelBonus
  }()
  
  //MARK: - General properties
   weak var progressBarDelegate: ProgressBarViewDelegate?
  
  /// It is the bonus score shown on the label
  /// - didSet: to adapt the label to the new text
  public var bonusScore: Int = 0 {
    didSet {
      if bonusScore == -1 {
        scoreBonusLabel.text = ""
      } else {
        scoreBonusLabel.text = "\(bonusScore)"
      }
      scoreBonusLabel.sizeToFit()
      scoreBonusLabel.frame.origin = CGPoint(x: labelBonus.frame.midX - scoreBonusLabel.frame.width/2, y: labelBonus.frame.maxY - scoreBonusLabel.frame.height/4)
    }
  }
  
  public var timer: Timer?
  private var time = 0.0
  private var bonusToDecrease: Int = 0
  
  //MARK: - View Life Cycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  /// Setup the layout of the View
  fileprivate func setup() {
    self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
    
    labelBonus.frame = CGRect(x: 16, y: 0, width: 48, height: 20)

    addSubview(scoreBonusLabel)
    addSubview(labelBonus)
    addSubview(progressView)
  }

  /// Selector repeated each second to decrease the time/bonusScore
  @objc fileprivate func setProgressViewWidth() {

    time -= Double(GameSettings.difficulty.rawValue + 1)
    bonusScore -= self.bonusToDecrease
    
    if (time <= 0) {
      
      self.time = 0
      
      timer?.invalidate()
      timer = nil
      progressBarDelegate?.didFinish(self)
    }
  }
  
  /// Start a timer to decrease the score and start an animation for the ProgressView width decrease
  ///
  /// - Parameter time: The amount of seconds
  func start(_ time: Double) {
    reset()
    
    self.bonusScore = Int(time) * 10 * (GameSettings.difficulty.rawValue + 1)
  
    self.time = time
  
    self.bonusToDecrease = self.bonusScore / (Int(self.time) / (GameSettings.difficulty.rawValue + 1))
  
    let animation = CABasicAnimation(keyPath: "bounds.size.width")
    animation.fromValue = self.progressView.frame.size.width
    animation.toValue = 0
    animation.isRemovedOnCompletion = false
    animation.fillMode = kCAFillModeForwards
    animation.duration = self.time/Double(GameSettings.difficulty.rawValue + 1)
    self.progressView.layer.add(animation, forKey: "reducingWidth")
    
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setProgressViewWidth), userInfo: nil, repeats: true)
  }
  
  /// Reset the properties of the View
  func reset() {
    timer?.invalidate()
    timer = nil
    self.progressView.layer.removeAnimation(forKey: "reducingWidth")
    
    progressView.frame = CGRect(x: 80, y: self.frame.height/2 - 7.5, width: 237, height: 15)
  }
  
}
