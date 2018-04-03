//
//  PathGenerator.swift
//  Puzzle Pipe
//
//  Copyright © 2018 Alessandro Izzo. All rights reserved.
//

import GameplayKit

protocol PathGeneratorDelegate: class {
  
  func pathGenerator(didWin winningPath: [Pipe])
}

public class PathGenerator {
  //MARK: - Properties
  weak var delegate: PathGeneratorDelegate?
  
  public var finalPath = [Pipe]()
  public var emptyPipes: Int = 2
  
  fileprivate var numberOfFixedObstacles = 0
  fileprivate var pathSize = 0
  

  //MARK: Class life cycle
  public init(pathSize: Int) {
    self.pathSize = pathSize
  }
  
  /// Generate a path to travel
  ///
  /// - Parameter completion: It marks if the path is created successfully or not
  public func generatePath(completion: @escaping (Bool) -> ()) {

    self.finalPath = [Pipe]()
    self.numberOfFixedObstacles = 0
    self.emptyPipes = 0
    
    let startPoint = selectRandomPoint(isSpecialPoint: true)
    let nextPointOfStart = (pathSize != 3) ? createPointsInBounds(from: startPoint) : nil
    let startPipe = Pipe(isEmpty: false, point: startPoint, startPoint: nil, endPoint: nextPointOfStart, obstacle: .none, isFirstPoint: true, isLastPoint: false)
    
    let goalPoint = createValidGoalPoint(from: startPoint, diagonalsAllowed: false, excluding: nextPointOfStart)
    let goalPipe = Pipe(isEmpty: false, point: goalPoint, startPoint: createPointsInBounds(from: goalPoint, excluding: [startPoint, startPipe.endPoint], isGoalPoint: true), endPoint: nil, obstacle: .none, isFirstPoint: false, isLastPoint: true)
    
    guard let path = self.findPath(from: startPipe, to: goalPipe) else {
      completion(false)
      return
    }
    
    self.finalPath = path
    
    // Setting the empty pipes randomly and based on the difficulty chosen
    //If the matrix size is 3x3 so there are 3 empty spaces for any difficulty to avoid deadlocks
    if emptyPipes == 0 {
      emptyPipes = (pathSize == 3) ? 3 : Int.random(min: 2, max: 3)
      if GameSettings.difficulty == .veryHard && pathSize != 3 {
        emptyPipes = 1
      } else if GameSettings.difficulty == .hard && pathSize != 3 {
        emptyPipes = 2
      }
    }
    
    for _ in 0..<self.emptyPipes {
      let emptyPoint = self.generateEmptyPoint(from: finalPath)
      let pipe = Pipe(isEmpty: true, point: emptyPoint, startPoint: nil, endPoint: nil)
      self.finalPath.append(pipe)
    }
    completion(true)
  }
  
  /// Generate a random pipe in a position
  ///
  /// - Parameters:
  ///   - pipePoint: The point where to generate the Pipe
  ///   - pointsToAvoid: Array of PipePoint to avoid in the generation
  public func generateRandomPipe(at pipePoint: PipePoint, avoid pointsToAvoid: [PipePoint]) -> Pipe {
    
    var pipe: Pipe!
    let startPoint = self.createPointedPoint(from: pipePoint)
    let endPoint = self.createPointedPoint(from: pipePoint, excluding: [startPoint])
    let obstacle: ObstacleType = self.generateObstacle(at: pipePoint, avoid: pointsToAvoid)
    pipe = Pipe(isEmpty: false, point: pipePoint, startPoint: startPoint, endPoint: endPoint)
    pipe.obstacle = obstacle
    
    return pipe
  }
  
  /// Check if a path is a winning path
  ///
  /// - Parameters:
  ///   - pipesView: Matrix of PipeView that is the current path to check
  ///   - isShufflingCheck: Boolean value to mark if is a check when is shuffling the matrix or not
  /// - Returns: True if the path is a winning path, False if not
  public func checkWin(of pipesView: [[PipeView]], isShufflingCheck: Bool = false) -> Bool {
    var winningPath = [Pipe]()
    
    guard var nextPoint = finalPath[0].endPoint else {
      return false
    }
    var currentPipe = finalPath[0]
    var nextPipe = pipesView[nextPoint.row][nextPoint.col].pipe
    
    //Execute the while until there is a right path or if the path has not all the connected points
    repeat {

      winningPath.append(currentPipe)
      //If the nextPipe is the goal Point and this is pointing to the current Pipe, so the path is right
      if nextPipe.isLastPoint && nextPipe.startPoint != nil && nextPipe.startPoint == currentPipe.point {
        winningPath.append(nextPipe)
        if !isShufflingCheck {
          self.delegate?.pathGenerator(didWin: winningPath)
        }
        return true
      } else {
        //Else get the nextPipe pointed and repeat the check
        if nextPipe.endPoint != currentPipe.point && nextPipe.startPoint != currentPipe.point || nextPipe.obstacle != .none {
          break
        } else if nextPipe.endPoint == currentPipe.point {
          guard let point = nextPipe.startPoint else {
            break
          }
          nextPoint = point
        } else {
          guard let point = nextPipe.endPoint else {
            break
          }
          nextPoint = point
        }
        
        //If the nextPoint has points out of bounds so break the cycle
        guard nextPoint.hasPointOutOfBounds(size: pathSize) != true else {
          break
        }
        currentPipe = nextPipe
        nextPipe = pipesView[nextPoint.row][nextPoint.col].pipe
      }
    } while true
    
    return false
  }
}

//MARK: - Private
fileprivate extension PathGenerator {
  
  /// Helper to find a path giving a start Pipe and a goal Pipe
  ///
  /// - Parameters:
  ///   - startPipe: The pipe where to start
  ///   - goalPipe: The pipe where to end
  /// - Returns: Array of Pipe which is the path found, nil if the path is not been found
  fileprivate func findPath(from startPipe: Pipe, to goalPipe: Pipe) -> [Pipe]? {
    
    var calculatedPath = [Pipe]()
    var mainPoints = [int2]()
    
    // Check if the matrixsize is not 3x3, this is a check to avoid dead points, if is not 3x3 matrix so insert this point as main point and this point doesn't not be used to find the final path
    if pathSize != 3 {
      mainPoints.append(int2(Int32(startPipe.point.row), Int32(startPipe.point.col)))
    }
    // The same here but for the goal point we don't have to check if is not a 3x3 matrix these two points are not used to find a path, in this case we have a more random path
    mainPoints.append(int2(Int32(goalPipe.point.row), Int32(goalPipe.point.col)))
    
    let graph = GKGridGraph(fromGridStartingAt: int2(0,0), width: Int32(pathSize), height: Int32(pathSize), diagonalsAllowed: false)
    
    // I'm setting the points to start the pathfinding
    let startPoint = (startPipe.endPoint == nil) ? (startPipe.point) : (startPipe.endPoint!)
    
    let start = graph.node(atGridPosition: int2(Int32(startPoint.row), Int32(startPoint.col)))!
    let end = graph.node(atGridPosition: int2(Int32(goalPipe.startPoint!.row), Int32(goalPipe.startPoint!.col)))!
    
    for point in mainPoints {
      //I'm removing the start and end points to have a more random path and not a linear path
      graph.remove([graph.node(atGridPosition: point)!])
    }
    
    var path = graph.findPath(from: start, to: end)
    
    //To avoid deadlocks if the path is too long and the matrixsize is less or equal than 4x4, create more empty points
    if path.count >= 5 && pathSize <= 4 {
      self.emptyPipes = 3
    }
    
    if pathSize != 3 {
      path.insert(GKGridGraphNode(gridPosition: mainPoints[0]), at: 0)
      path.append(GKGridGraphNode(gridPosition: mainPoints[1]))
    } else {
      path.append(GKGridGraphNode(gridPosition: mainPoints[0]))
    }
    
    guard let gridPath = path as? [GKGridGraphNode] else { return nil }
    
    //Now that I have the path found, convert every cell of the grid in a PipePoint and then create the Pipe
    for (i, element) in gridPath.enumerated() {
      
      let pipePoint = PipePoint(row: Int(element.gridPosition.x), col: Int(element.gridPosition.y))
      let isFirstPoint = (pipePoint == startPipe.point) ? (true) : (false)
      let isLastPoint = (pipePoint == goalPipe.point) ? (true) : (false)
      
      let nextPoint = (!isLastPoint) ? PipePoint(row: Int(gridPath[i+1].gridPosition.x), col: Int(gridPath[i+1].gridPosition.y)) : nil
      let previousPoint = (!isFirstPoint) ? PipePoint(row: Int(gridPath[i-1].gridPosition.x), col: Int(gridPath[i-1].gridPosition.y)) : nil
      
      let pipe = Pipe(isEmpty: false, point: pipePoint, startPoint: previousPoint, endPoint: nextPoint, obstacle: .none, isFirstPoint: isFirstPoint, isLastPoint: isLastPoint)
      calculatedPath.append(pipe)
    }
    
    return calculatedPath
  }
  
  /// Create a valid goal point avoid the deadlocks
  ///
  /// - Parameters:
  ///   - startPoint: The start Point
  ///   - diagonalsAllowed: If the diagonals are allowd in the matrix
  ///   - excludedPoint
  fileprivate func createValidGoalPoint(from startPoint: PipePoint, diagonalsAllowed: Bool, excluding excludedPoint: PipePoint?) -> PipePoint{
    
    let goalPoint = self.selectRandomPoint(isSpecialPoint: true, excluding: [startPoint, excludedPoint])
    //If diagonals points are not allowed
    if !diagonalsAllowed && (goalPoint.isOnDiagonal(of: startPoint) || goalPoint.isOnDeadPoint(of: startPoint, in: pathSize)) {
      
      //Is not a valid goal point, so create another point
      return createValidGoalPoint(from: startPoint, diagonalsAllowed: diagonalsAllowed, excluding: excludedPoint)
    }
    return goalPoint
  }
  
  /// Generate empty Points in a path
  ///
  /// - Parameters:
  ///   - path: The path where to generate the empty point
  /// - Returns: A PipePoint where is created the empty Point
  fileprivate func generateEmptyPoint(from path: [Pipe]) -> PipePoint {
    let row = Int.random(min: 0, max: pathSize - 1)
    let col = Int.random(min: 0, max: pathSize - 1)
    let pipePoint = PipePoint(row: row, col: col)
    
    if pipePoint.alreadyExists(in: path) {
      return generateEmptyPoint(from: path)
    }
    return pipePoint
  }
  
  /// Create a point where the Pipe is pointing
  ///
  /// - Parameters:
  ///   - pipePoint: The current point of the Pipe
  ///   - excludedPoints: The points to avoid
  /// - Returns: PipePoint pointed
  fileprivate func createPointedPoint(from pipePoint: PipePoint, excluding excludedPoints: [PipePoint?]? = nil) -> PipePoint {
    var pointsAvailables: [PipePoint] = [PipePoint]()
    let upPoint = PipePoint(row: pipePoint.row - 1, col: pipePoint.col)
    let downPoint = PipePoint(row: pipePoint.row + 1, col: pipePoint.col)
    let leftPoint = PipePoint(row: pipePoint.row, col: pipePoint.col - 1)
    let rightPoint = PipePoint(row: pipePoint.row, col: pipePoint.col + 1)
    
    if let excludedPoints = excludedPoints {
      
      if !excludedPoints.contains(where: { $0 != nil && $0 == upPoint}) {
        pointsAvailables.append(upPoint)
      }
      if !excludedPoints.contains(where: { $0 != nil && $0 == downPoint}) {
        pointsAvailables.append(downPoint)
      }
      
      if !excludedPoints.contains(where: { $0 != nil && $0 == leftPoint}) {
        pointsAvailables.append(leftPoint)
      }
      if !excludedPoints.contains(where: { $0 != nil && $0 == rightPoint}) {
        pointsAvailables.append(rightPoint)
      }
    } else {
      pointsAvailables.append(upPoint)
      pointsAvailables.append(downPoint)
      pointsAvailables.append(leftPoint)
      pointsAvailables.append(rightPoint)
    }
    
    let randomPoint = Int.random(min: 0, max: pointsAvailables.count - 1)
    return pointsAvailables[randomPoint]
  }
  
  /// Create a point which is in the bounds of the matrix
  ///
  /// - Parameters:
  ///   - pipePoint: Current position of the Pipe
  ///   - excludedPoints: Points to exclude
  ///   - isGoalPoint: It marks if the point is the goal point or not
  /// - Returns: A PipePoint which is in bounds
  fileprivate func createPointsInBounds(from pipePoint: PipePoint, excluding excludedPoints: [PipePoint?]? = nil, isGoalPoint: Bool = false) -> PipePoint {
    
    let selectedPoint = createPointedPoint(from: pipePoint, excluding: excludedPoints)
    
    if selectedPoint.hasPointOutOfBounds(size: pathSize) {
      return createPointsInBounds(from: pipePoint, excluding: excludedPoints, isGoalPoint: isGoalPoint)
    }
    
    if isGoalPoint && selectedPoint.isOnTheCorner(of: pathSize) {
      if let excludedPoint = excludedPoints![1] {
        if excludedPoint.isOnTheCorner(of: pathSize) {
          return createPointsInBounds(from: pipePoint, excluding: excludedPoints, isGoalPoint: isGoalPoint)
        }
      }
      return createPointsInBounds(from: pipePoint, excluding: excludedPoints, isGoalPoint: isGoalPoint)
    }
    
    return selectedPoint
  }
  
  /// Select a random Point in the matrix
  ///
  /// - Parameters:
  ///   - isSpecialPoint: Boolean value that marks if it is a specialPoint
  ///   - excludedPoints: Points to exclude during the selection
  /// - Returns: PipePoint selected
  fileprivate func selectRandomPoint(isSpecialPoint: Bool = false, excluding excludedPoints: [PipePoint?]? = nil) -> PipePoint {
    let row = Int.random(min: 0, max: pathSize - 1)
    let col = Int.random(min: 0, max: pathSize - 1)
    let pipePoint = PipePoint(row: row, col: col)
    
    //If the point selected is the last or start point
    //Check if the matrixsize is 3x3, to avoid dead points don't create point at center of the 2d array
    if isSpecialPoint && pathSize == 3 && row == (pathSize / 2) && col == (pathSize / 2) {
      return selectRandomPoint(isSpecialPoint: isSpecialPoint, excluding: excludedPoints)
    }
    if let excludedPoints = excludedPoints {
      if excludedPoints.contains(where: { $0 != nil && $0 == pipePoint}) {
        return selectRandomPoint(isSpecialPoint: isSpecialPoint, excluding: excludedPoints)
      }
    }
    return pipePoint
  }

  /// Generate an obstacle at a Point
  ///
  /// - Parameters:
  ///   - pipePoint: The point where to create the obstacle
  ///   - avoid points: Points used for checking if the point is in a good position to be placed
  /// - Returns: Type of an Obstacle created
  fileprivate func generateObstacle(at pipePoint: PipePoint, avoid points: [PipePoint]) -> ObstacleType {
    
    var randomSelection: ObstacleType = ObstacleType(rawValue: Int.random(min: 0, max: 1))!
    
    if (GameSettings.difficulty == .hard || GameSettings.difficulty == .veryHard) && pipePoint.isOnTheCorner(of: pathSize) && numberOfFixedObstacles == 0 {
      for pointToAvoid in points {
        if pointToAvoid.isOnDiagonal(of: pipePoint) {
          randomSelection = .movable
          return randomSelection
        }
      }
      randomSelection = .fixed
      numberOfFixedObstacles += 1
    }
    return randomSelection
  }
}
