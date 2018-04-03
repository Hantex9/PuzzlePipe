//
//  GameViewController.swift
//  Puzzle Pipe
//
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import UIKit
import AVFoundation

public class GameViewController: UIViewController {

  //MARK: - Properties for the UI
  private let backgroundView: UIImageView = {
    let backgroundView = UIImageView()
    backgroundView.contentMode = .scaleAspectFill
    backgroundView.clipsToBounds = true
    backgroundView.image = UIImage(named: "background")
    return backgroundView
  }()
  
  private let statusView: UIView = {
    let statusView = UIView()
    statusView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
    statusView.layer.cornerRadius = 14.0
    return statusView
  }()
  
  private let statusImageView: UIImageView = {
    let statusImageView = UIImageView()
    statusImageView.contentMode = .scaleToFill
    return statusImageView
  }()
  
  private let scoreTextLabel: UILabel = {
    let scoreTextLabel = UILabel()
    scoreTextLabel.text = "Score"
    scoreTextLabel.font = UIFont(name: "TitilliumWeb-Light", size: 19)
    scoreTextLabel.textAlignment = .center
    scoreTextLabel.textColor = .white
    return scoreTextLabel
  }()
  
  private let scoreLabel: UILabel = {
    let scoreLabel = UILabel()
    scoreLabel.textColor = UIColor(red: 0/255.0, green: 199/255.0, blue: 182/255.0, alpha: 1.0)
    scoreLabel.text = "0"
    scoreLabel.sizeToFit()
    scoreLabel.font = UIFont(name: "TitilliumWeb-SemiBold", size: 17)
    scoreLabel.textAlignment = .right
    return scoreLabel
  }()
  
  private let highScoreTextLabel: UILabel = {
    let label = UILabel()
    label.text = "High Score"
    label.font = UIFont(name: "TitilliumWeb-Light", size: 19)
    label.textAlignment = .center
    label.textColor = .white
    return label
  }()
  
  private let highScoreLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor(red: 0/255.0, green: 199/255.0, blue: 182/255.0, alpha: 1.0)
    label.text = "0"
    label.font = UIFont(name: "TitilliumWeb-SemiBold", size: 17)
    label.textAlignment = .right
    return label
  }()
  
  private let separatorLabel: UILabel = {
    let label = UILabel()
    label.text = "|"
    label.font = UIFont(name: "TitilliumWeb-Light", size: 19)
    label.textColor = .white
    label.textAlignment = .right
    return label
  }()
  
  private let infoLabel: UILabel = {
    let infoLabel = UILabel()
    infoLabel.text = "TIMES UP"
    infoLabel.adjustsFontForContentSizeCategory = true
    infoLabel.font = UIFont(name: "TitilliumWeb-Bold", size: 30)
    infoLabel.textColor = .white
    infoLabel.alpha = 0.0
    return infoLabel
  }()
  
  private let scoreGameOverLabel: UILabel = {
    let label = UILabel()
    label.text = "SCORE:"
    label.numberOfLines = 0
    label.font = UIFont(name: "TitilliumWeb-Light", size: 30)
    label.textColor = .white
    label.textAlignment = .center
    label.alpha = 0.0
    return label
  }()
  
  private let highScoreGameOverLabel: UILabel = {
    let label = UILabel()
    label.text = "HIGH SCORE:\n"
    label.numberOfLines = 0
    label.font = UIFont(name: "TitilliumWeb-Light", size: 30)
    label.textColor = .white
    label.textAlignment = .center
    label.alpha = 0.0
    return label
  }()
  
  private let tapLabel: UILabel = {
    let tapLabel = UILabel()
    tapLabel.text = "TAP TO PLAY AGAIN"
    tapLabel.adjustsFontForContentSizeCategory = true
    tapLabel.textColor = .white
    tapLabel.font = UIFont(name: "TitilliumWeb-ExtraLight", size: 30)
    tapLabel.alpha = 0.0
    tapLabel.textAlignment = .center
    return tapLabel
  }()
  
  //MARK: General properties
  private var audioPlayer: AVAudioPlayer!
  
  private var pipeContainer: PipeContainerView = PipeContainerView()
  
  private let pathGenerator: PathGenerator = PathGenerator(pathSize: GameSettings.matrixSize)
  
  private let progressView: ProgressBarView = ProgressBarView()
  
  /// didSet: update the label and readapt the UI
  public var highScore: Int = 0 {
    didSet {
      highScoreLabel.text = "\(highScore)"
      updateStatusViewLayout()
    }
  }
  
  /// didSet: update the label and readapt the UI
  private var playerScore = 0 {
    didSet {
      scoreLabel.text = "\(playerScore)"
      updateStatusViewLayout()
    }
  }

  private lazy var isChangingScene = false
  
  
  //MARK: - View Life Cycle
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    self.view.addSubview(backgroundView)
    
    pathGenerator.delegate = self
    
    self.preloadSound()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.loadLayout()
    
    if pipeContainer.pipesView.count == 0 {
      DispatchQueue.main.async {
        self.createPath(isFirstTime: true)
      }
    }
  }
  
  //Used for readacting the view when it changes
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    updateStatusViewLayout()
    
    backgroundView.frame.size = self.view.frame.size
    backgroundView.center = self.view.center
    
    if !isChangingScene {
      statusView.frame.origin = CGPoint(x: self.view.frame.midX - 170.0, y: self.view.frame.midY - 310.0)
      progressView.frame.origin = CGPoint(x: self.view.frame.midX - 165.0, y: self.view.frame.midY - 224)
    }
    self.pipeContainer.frame.origin = CGPoint(x: self.view.frame.midX - 170.0, y: self.view.frame.midY - 170.0)
    
    self.statusImageView.frame = (CGRect(x: self.view.frame.midX - 50, y: self.view.frame.midY - 245, width: 100, height: 100))
    
    updateLayoutGameOverScene()
  }
  
  /// Load the layout for the view
  private func loadLayout() {
    
    self.backgroundView.frame.size = self.view.frame.size
    self.backgroundView.center = self.view.center
    
    statusView.frame = CGRect(x: self.view.frame.midX - 170.0, y: self.view.frame.midY - 310.0, width: 340, height: 29)
    updateStatusViewLayout()
    
    highScoreTextLabel.frame = CGRect(x: 20.0, y: -1, width: 76, height: 27)
    highScoreTextLabel.sizeToFit()
    
    highScoreLabel.text = "\(highScore)"
    
    infoLabel.frame = CGRect(x: self.view.frame.midX, y: self.view.frame.midY - 100, width: 110, height: 110)
    infoLabel.sizeToFit()
    
    tapLabel.frame = CGRect(x: self.view.frame.midX, y: self.infoLabel.frame.origin.y + self.infoLabel.frame.height, width: 110, height: 110)
    
    statusView.addSubview(scoreTextLabel)
    statusView.addSubview(scoreLabel)
    statusView.addSubview(highScoreTextLabel)
    statusView.addSubview(highScoreLabel)
    statusView.addSubview(separatorLabel)
    
    progressView.frame = CGRect(x: self.view.frame.midX - 165.0, y: self.view.frame.midY - (224), width: 330, height: 38)
    progressView.progressBarDelegate = self
  
    self.view.addSubview(progressView)
    self.view.addSubview(pipeContainer)
    self.view.addSubview(statusView)
    
    //Game Over scene views
    scoreGameOverLabel.frame.size = CGSize(width: self.view.frame.size.width, height: 100)
    highScoreGameOverLabel.frame.size = CGSize(width: self.view.frame.width, height: 100)
    
    self.view.addSubview(scoreGameOverLabel)
    self.view.addSubview(highScoreGameOverLabel)
    self.view.addSubview(infoLabel)
    self.view.addSubview(tapLabel)

  }
  
  /// Update the game over scene layout
  fileprivate func updateLayoutGameOverScene() {
    self.infoLabel.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY - 230)
    
    self.tapLabel.frame.origin = CGPoint(x: self.view.frame.midX - 118, y: self.view.frame.midY + 145)
    
    self.scoreGameOverLabel.frame.origin = CGPoint(x: self.view.frame.midX - self.scoreGameOverLabel.frame.size.width/2, y: self.infoLabel.frame.origin.y + (self.infoLabel.frame.size.height) + 25)
    
    self.highScoreGameOverLabel.frame.origin = CGPoint(x: self.view.frame.midX - self.highScoreGameOverLabel.frame.size.width/2, y: self.scoreGameOverLabel.frame.origin.y + (self.scoreGameOverLabel.frame.size.height) + 25)
  }
  
  /// Update the status view (view on the top) layout
  fileprivate func updateStatusViewLayout() {
    scoreLabel.sizeToFit()
    scoreLabel.frame = CGRect(x: statusView.frame.width - scoreLabel.frame.width - 20.0, y: 0, width: scoreLabel.frame.width, height: statusView.frame.height)
    
    scoreTextLabel.frame = CGRect(x: scoreLabel.frame.minX - scoreTextLabel.frame.width - 10.0, y: 0, width: 38, height:  statusView.frame.height)
    scoreTextLabel.sizeToFit()
    
    separatorLabel.sizeToFit()
    separatorLabel.frame = CGRect(x: scoreTextLabel.frame.minX - 20, y: -1.5, width: 3, height: statusView.frame.height)
    
    highScoreLabel.sizeToFit()
    highScoreLabel.frame = CGRect(x: separatorLabel.frame.minX - highScoreLabel.frame.width - 5, y: 0, width: highScoreLabel.frame.width, height: statusView.frame.height)
  }
  
  /// Preload the check mark sound
  fileprivate func preloadSound() {
    
    do {
      let url = Bundle.main.url(forResource: "checkSound", withExtension: "mp3")
      audioPlayer = try AVAudioPlayer(contentsOf: url!)
      audioPlayer.prepareToPlay()
    } catch {
      print("Error while loading the sound")
    }
  }
  
  /// Play the check mark sound
  fileprivate func playSound() {
    let url = Bundle.main.url(forResource: "checkSound", withExtension: "mp3")
    
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: url!)
      audioPlayer.play()
    } catch {
      print("Error while playing the sound")
    }
  }
  
  /// Start the path creation and animate the Matrix container with a transaction
  ///
  /// - Parameter isFirstTime: boolean value that mark if is the first time that runs the application
  fileprivate func createPath(isFirstTime: Bool) {
    progressView.reset()
    
    //If is not the first time generate the transaction animation with the old container
    if !isFirstTime {
      let oldPipeContainer = self.pipeContainer
      self.pipeContainer = PipeContainerView()
      UIView.animate(withDuration: 0.5, animations: {
        oldPipeContainer.frame.origin = CGPoint(x: -self.view.frame.maxX, y: self.view.frame.midY - 170.0)
      }) { (success) in
        self.isChangingScene = false
        oldPipeContainer.removeFromSuperview()
      }
    }
    
    //Setting the new container out of the screen to start the animation
    pipeContainer.frame = CGRect(x: view.frame.maxX + 20.0, y: self.view.frame.midY - 170.0, width: 340.0, height: 340.0)
    pipeContainer.delegate = self
    pipeContainer.pathGenerator = self.pathGenerator
    
    self.view.addSubview(self.pipeContainer)
    
    UIView.animate(withDuration: 0.5, animations: {
      self.pipeContainer.frame.origin = CGPoint(x: self.view.frame.midX - 170.0, y: self.view.frame.midY - 170.0)
    }) { _ in
      let time: Double = Double(GameSettings.matrixSize * 30)
      self.progressView.start(time)
    }
    
    //Generate the path, if it has success start to create the UI of the pipes
    pathGenerator.generatePath { success in
      guard success == true else {
        return self.createPath(isFirstTime: false)
      }
      
      self.pipeContainer.createPipes(size: GameSettings.matrixSize)
    }
  }
}

//MARK: - Pipe View Delegate
extension GameViewController: PipeViewDelegate {

  /// Delegate method that marks the creation of a pipe
  ///
  /// - Parameters:
  ///   - pipeContainer: a view that marks the pipe container which call this method
  ///   - pipeView: the pipe view created in the pipe container
  ///   - pipePoint: the point where the pipe view is created
  /// - Returns: the new PipeView setted
  func pipeView (_ pipeContainer: PipeContainerView, didCreate pipeView: PipeView, at pipePoint: PipePoint) -> PipeView {
    
    pipeView.delegate = self
    
    //If the pipe created is one of the pipe that is used for the right path, so set it with the right properties
    for pipe in pathGenerator.finalPath {
      if pipe.point == pipePoint {
        pipeView.pipe = pipe
        return pipeView
      }
    }
    //Else generate a random pipe with random properties
    pipeView.pipe = pathGenerator.generateRandomPipe(at: pipePoint, avoid: [pathGenerator.finalPath.first!.point, pathGenerator.finalPath[pathGenerator.finalPath.count - pathGenerator.emptyPipes - 1].point])

    return pipeView
  }
  
  /// Delegate method that is called before the pipe is moving to another point
  ///
  /// - Parameters:
  ///   - pipeView: the pipe view that should be moved
  ///   - direction: direction point that marks where it should moving
  /// - Returns: boolean value that marks if the pipe view can be moved or not
  func pipeView(_ pipeView: PipeView, shouldMove direction: Direction) -> Bool {
    
    guard direction != .none, pipeView.pipe.isValidToMove(), !isChangingScene else {
      return false
    }

    let pipePosition = pipeView.pipe.point
    //Check where should be moved, if the direction where is moving is an empty block so move it, else don't move
    switch direction {
    case .left:
      let row = pipePosition.row
      let col = pipePosition.col - 1
      if col >= 0 && pipeContainer.pipesView[row][col].pipe.isEmpty {
        return true
      }
      break
    case .right:
      let row = pipePosition.row
      let col = pipePosition.col + 1
      if col < GameSettings.matrixSize && pipeContainer.pipesView[row][col].pipe.isEmpty {
        return true
      }
      break
    case .up:
      let row = pipePosition.row - 1
      let col = pipePosition.col
      if row >= 0 && pipeContainer.pipesView[row][col].pipe.isEmpty {
        return true
      }
      break
    case .down:
      let row = pipePosition.row + 1
      let col = pipePosition.col
      if row < GameSettings.matrixSize && pipeContainer.pipesView[row][col].pipe.isEmpty {
        return true
      }
      break
    default:
      break
    }
    return false
  }
  
  /// Delegate method that is called after that the pipe view is moved
  ///
  /// - Parameters:
  ///   - pipeView: the pipe view that moved
  ///   - direction: direction point that marks where it moved
  /// - Returns: optional Pipe value that marks the new value of his point in the matrix
  func pipeView(_ pipeView: PipeView, didMove direction: Direction) -> Pipe? {
    
    let oldPoint = pipeView.pipe.point
    var newPoint: PipePoint!
    
    switch direction {
    case .left:
      newPoint = PipePoint(row: oldPoint.row, col: oldPoint.col - 1)
      break
    case .right:
      newPoint = PipePoint(row: oldPoint.row, col: oldPoint.col + 1)
      break
    case .up:
      newPoint = PipePoint(row: oldPoint.row - 1, col: oldPoint.col)
      break
    case .down:
      newPoint = PipePoint(row: oldPoint.row + 1, col: oldPoint.col)
      break
    default:
      print("moved away")
    }
    guard !newPoint.hasPointOutOfBounds(size: GameSettings.matrixSize) && pipeContainer.pipesView[newPoint.row][newPoint.col].pipe.isEmpty else {
      print("Error while moving the pipe")
      return nil
    }
    pipeContainer.move(oldPoint, to: newPoint, direction: direction)
    let _ = pathGenerator.checkWin(of: self.pipeContainer.pipesView)
    
    return pipeView.pipe
  }
}

//MARK: - Path Generator Delegate
extension GameViewController: PathGeneratorDelegate {
  
  /// Delegate method called when the user find the right path and wins.
  func pathGenerator(didWin winningPath: [Pipe]) {
    isChangingScene = true
    self.win(winningPath: winningPath)
  }
  
  /// Start the win phase proceding to the next round and starting the win animation
  ///
  /// - Parameter winningPath: array of pipes which mark the winning path traveled
  fileprivate func win(winningPath: [Pipe]) {
    playerScore += progressView.bonusScore
    progressView.timer?.invalidate()
    
    highScore = (playerScore > highScore) ? playerScore : highScore
    
    //Start the animations when the user wins the round illuminating the path traveled and on his completion start presenting the check mark and increasing the score animations
    self.pipeContainer.winEffect(with: winningPath) {
      
      self.statusImageView.image = UIImage(named: "successIcon")
      
      self.view.addSubview(self.statusImageView)
      
      //Setting the label for the score gained used for an animation
      let scoreGainedLabel = UILabel()
      scoreGainedLabel.text = "+\(self.progressView.bonusScore)"
      scoreGainedLabel.textAlignment = .right
      scoreGainedLabel.textColor = UIColor(red: 171/255, green: 227/255, blue: 70/255, alpha: 1.0)
      scoreGainedLabel.font = self.scoreLabel.font
      scoreGainedLabel.sizeToFit()
      scoreGainedLabel.center = CGPoint(x: self.scoreLabel.center.x - 2.5, y: self.scoreLabel.center.y + 60)
      self.statusView.addSubview(scoreGainedLabel)
      
      self.playSound()
      
      //Increasing the size of the score label for the animation 
      let oldTransform = self.scoreLabel.transform
      self.scoreLabel.transform = self.scoreLabel.transform.scaledBy(x: 1.4, y: 1.4)
      
      UIView.animate(withDuration: 0.5, animations: {
        self.scoreLabel.transform = oldTransform
        
        scoreGainedLabel.center.y = self.scoreLabel.center.y + 15
        
        //Animate the reset of the progress view
        self.progressView.reset()
      }) { success in
        scoreGainedLabel.removeFromSuperview()
        self.statusImageView.removeFromSuperview()
        
        self.createPath(isFirstTime: false)
      }
    }
  }
}

//MARK: - Progressbar View Delegate
extension GameViewController: ProgressBarViewDelegate {
  
  /// Delegate method called when the time of the progressbar reach 0
  func didFinish(_ timerBarView: ProgressBarView) {
    isChangingScene = true
    self.gameOver()
  }
  
  /// Start the Game Over phase with animations.
  fileprivate func gameOver() {
    
    statusImageView.image = UIImage(named: "gameOverIcon")
    
    self.view.addSubview(statusImageView)
  
    //Execute the animation after 1.5 seconds.
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      
      UIView.animate(withDuration: 0.5, animations: {
        self.pipeContainer.frame.origin.y = self.view.frame.size.height + 200
        self.statusView.frame.origin.y = -self.view.frame.size.height + 100
        self.progressView.frame.origin.y = -self.view.frame.size.height + 100
      }) { _ in
        //When the animation ends, start to show the game over scene
        self.showGameOverScene()
      }
    }
  }
  
  /// Shows the game over scene with all the high score and the score done.
  fileprivate func showGameOverScene() {
    pipeContainer.removeFromSuperview()
    
    //Preparing the elements for the animation
    infoLabel.center = self.view.center
    tapLabel.center = self.view.center
    scoreGameOverLabel.center = self.view.center
    highScoreGameOverLabel.center = self.view.center
    
    //Set the tap gesture to restart the game
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandle))
    view.addGestureRecognizer(tapGesture)
    
    if self.playerScore != 0 && self.playerScore >= self.highScore {
      self.scoreGameOverLabel.text = "NEW RECORD!\n\(self.playerScore)"
      self.highScoreGameOverLabel.text = ""
    } else {
      self.scoreGameOverLabel.text = "SCORE\n\(self.playerScore)"
      self.highScoreGameOverLabel.text = "HIGH SCORE\n\(self.highScore)"
    }
    
    UIView.animate(withDuration: 0.1, animations: {
      
      self.updateLayoutGameOverScene()

      self.infoLabel.sizeToFit()
      self.infoLabel.alpha = 1.0
      
      self.tapLabel.sizeToFit()
      self.tapLabel.alpha = 1.0
      
      self.scoreGameOverLabel.alpha = 1.0

      self.highScoreGameOverLabel.alpha = 1.0
      
    }) { _ in
      self.statusImageView.removeFromSuperview()
      
      //Animating the tap label with fadeIn and fadeOut effect
      UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse], animations: {
        self.tapLabel.alpha = 0.4
      })
    }
  }
  
  /// Tap handler managing the tap on the game over scene to restart the game.
  @objc fileprivate func tapHandle(_ sender: UITapGestureRecognizer) {
    self.view.removeGestureRecognizer(sender)
    
    self.tapLabel.layer.removeAllAnimations()
    
    self.progressView.bonusScore = -1
    
    //Start the animation for the restart game replacing every view in the right position
    UIView.animate(withDuration: 0.3, animations: {
      self.infoLabel.center = self.view.center
      self.tapLabel.center = self.view.center
      self.scoreGameOverLabel.center = self.view.center
      self.highScoreGameOverLabel.center = self.view.center
      
      self.statusView.frame.origin = CGPoint(x: self.view.frame.midX - 170.0, y: self.view.frame.midY - 310.0)
      self.progressView.frame.origin = CGPoint(x: self.view.frame.midX - 165.0, y: self.view.frame.midY - (224))
      
      self.infoLabel.alpha = 0
      self.tapLabel.alpha = 0
      self.highScoreGameOverLabel.alpha = 0
      self.scoreGameOverLabel.alpha = 0
      
      self.playerScore = 0
    }) { _ in
      //On his completion create a new path
      self.createPath(isFirstTime: false)
    }
  }
  
}
