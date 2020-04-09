//
//  Puzzle.swift
//  Shape Slide
//
//  Created by 90307332 on 3/11/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import UIKit
import GameKit

class Puzzle : SKNode {
    
    // MARK: Block Types
    // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
    
    public static let EMPTY = 0         // Empty Area
    public static let WALL = 1          // Wall 
    public static let SQUARE_ONE = 2    // Orange Square - Basic unit of the game
    public static let SQUARE_TWO = 3    // Blue Square - Basic unit of the game
    public static let TRIANGLE = 4      // Triangle - Like square but cannot move, defeatable by either color
    public static let CIRCLE = 5        // Circle - Like the triangle but swaps the pieces color when defeated
    
    // MARK: Variables
    // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
    
    private var layout: [[Int]]
    private var spriteGrid = [[SKShapeNode?]]()
    private var background: SKShapeNode?
    private let scale: Double
    
    init(layout: [[Int]], scale: Double) {
        self.layout = layout
        self.scale = scale
        super.init()
        
        background = createBackground()
        loadLevel()
    }
    
    // MARK: Game Logic
    // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
    
    public func moveTile(start: (Int, Int), end: (Int, Int)) {
        if !basicChecks(start: start, end: end) || !tileChecks(start: start, end: end) {
            return // Fails if something that effects all blocks is invalid or tile specific
        }
        
        
        // VVV temp code (have to redo because it will instantly break with more complicated tiles) VVV
        
        let switchColor = layout[end.0][end.1] == Puzzle.CIRCLE
        
        let delete = SKAction.run {
            if self.layout[end.0][end.1] > 1 {
                self.spriteGrid[end.0][end.1]?.removeFromParent()
                self.spriteGrid[end.0][end.1] = self.spriteGrid[start.0][start.1]
                self.spriteGrid[start.0][start.1] = nil
                
                if switchColor {
                    if self.layout[end.0][end.1] == Puzzle.SQUARE_ONE {
                        self.spriteGrid[end.0][end.1]?.fillColor = ColorPallete.SQUARE_ONE
                        self.spriteGrid[end.0][end.1]?.strokeColor = ColorPallete.SQUARE_ONE.darker(by: 50)
                    }else {
                        self.spriteGrid[end.0][end.1]?.fillColor = ColorPallete.SQUARE_TWO
                        self.spriteGrid[end.0][end.1]?.strokeColor = ColorPallete.SQUARE_TWO.darker(by: 50)
                    }
                }
            }
        }
        
        let move = SKAction.move(to: tilePositionOnScreen(x: end.0, y: end.1), duration: 0.1)
        let sequence = SKAction.sequence([move, delete])
        
        spriteGrid[end.0][end.1]?.zPosition = 1
        spriteGrid[start.0][start.1]!.run(sequence)
        
        layout[end.0][end.1] = layout[start.0][start.1]
        layout[start.0][start.1] = 0
        
        if switchColor {
            if layout[end.0][end.1] == Puzzle.SQUARE_ONE {
                layout[end.0][end.1] = Puzzle.SQUARE_TWO
            }else {
                layout[end.0][end.1] = Puzzle.SQUARE_ONE
            }
        }
    }
    
    public func solved() -> Bool {
        var foundTile = false
        for x in 0 ..< layout.count {
            for y in 0 ..< layout[0].count {
                if layout[x][y] > 1 {
                    if foundTile { return false }
                    else { foundTile = true }
                }
            }
        }
        
        return true
    }
    
    // MARK: Basic Checks
    // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
    
    private func basicChecks(start: (Int, Int), end: (Int, Int)) -> Bool {
        return start != end && inBounds(point: start) && inBounds(point: end)
            && (start.0 == end.0 || start.1 == end.1) && layout[start.0][start.1] > 0 && layout[end.0][end.1] > 1
            && clearPath(start: start, end: end)
    }
    
    private func clearPath(start: (Int, Int), end: (Int, Int)) -> Bool {
        var  dir = (start.0 - end.0, start.1 - end.1)
        if dir.0 == 0 {
            dir.1 /= abs(start.1 - end.1)
        }else {
            dir.0 /= abs(start.0 - end.0)
        }
        
        var point =  (start.0 - dir.0, start.1 - dir.1)
        while point != end {
            if layout[point.0][point.1] != 0 {
                return false
            }
            
            point = (point.0 - dir.0, point.1 - dir.1)
        }
        
        return true
    }
    
    private func inBounds(point: (Int, Int)) -> Bool {
        return point.0 >= 0 && point.1 >= 0 && point.0 < layout.count && point.1 < layout[0].count
    }
    
    // MARK: Tile Checks
    // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
    
    private func tileChecks(start: (Int, Int), end: (Int, Int)) -> Bool {
        return (layout[start.0][start.1] == Puzzle.WALL && wallChecks())
            || (layout[start.0][start.1] == Puzzle.SQUARE_ONE && squareOneChecks(start: start, end: end))
            || (layout[start.0][start.1] == Puzzle.SQUARE_TWO && squareTwoChecks(start: start, end: end))
            || (layout[start.0][start.1] == Puzzle.TRIANGLE && triangleChecks())
            || (layout[start.0][start.1] == Puzzle.CIRCLE && circleChecks())
    }
    
    private func wallChecks() -> Bool {
        return false // Can never move
    }
    
    private func squareOneChecks(start: (Int, Int), end: (Int, Int)) -> Bool {
        return layout[start.0][start.1] != layout[end.0][end.1]
    }
    
    private func squareTwoChecks(start: (Int, Int), end: (Int, Int)) -> Bool {
        return layout[start.0][start.1] != layout[end.0][end.1]
    }
    
    private func triangleChecks() -> Bool {
        return false // Can never move
    }
    
    private func circleChecks() -> Bool {
        return false // Can never move
    }
    
    // MARK: Level Loading
    // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
    
    private func loadLevel() {
        for x in 0 ..< layout.count {
            var row = [SKShapeNode?]()
            for y in 0 ..< layout[x].count {
                switch layout[x][y] {
                    
                    case Puzzle.WALL:
                        row.append(createWall(x: x, y: y))
                        break
                        
                    case Puzzle.SQUARE_ONE:
                        row.append(createSquareOne(x: x, y: y))
                        break
                    
                    case Puzzle.SQUARE_TWO:
                        row.append(createSquareTwo(x: x, y: y))
                        break
                    
                    case Puzzle.TRIANGLE:
                        row.append(createTriangle(x: x, y: y))
                        break
                    
                    case Puzzle.CIRCLE:
                        row.append(createCircle(x: x, y: y))
                        break
                    
                    default:
                        row.append(nil)
                        break
                }
            }
            
            spriteGrid.append(row)
        }
    }
    
    // MARK: Sprite Creation
    // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
    
    private func createBackground() -> SKShapeNode {
        let background = SKShapeNode(rectOf: CGSize(width: Double(layout.count)*scale, height: Double(layout[0].count)*scale), cornerRadius: 25)
        background.fillColor = ColorPallete.PUZZLE_BACK
        background.strokeColor = ColorPallete.PUZZLE_BACK.lighter(by: 50)
        addChild(background)
        
        // TODO: Grid
        return background
    }
    
    private func createWall(x: Int, y: Int) -> SKShapeNode {
        let wall = SKShapeNode(rectOf: CGSize(width: scale*0.9, height: scale*0.9), cornerRadius: 25)
        wall.position = tilePositionOnScreen(x: x, y: y)
        wall.fillColor = ColorPallete.WALL
        wall.strokeColor = ColorPallete.WALL
        self.addChild(wall)
        return wall
    }
       
    private func createSquareOne(x: Int, y: Int) -> SKShapeNode {
        let square = SKShapeNode(rectOf: CGSize(width: scale/2, height: scale/2), cornerRadius: 10)
        square.position = tilePositionOnScreen(x: x, y: y)
        square.fillColor = ColorPallete.SQUARE_ONE
        square.strokeColor = ColorPallete.SQUARE_ONE.darker(by: 50)
        self.addChild(square)
        return square
    }
       
    private func createSquareTwo(x: Int, y: Int) -> SKShapeNode {
        let square = SKShapeNode(rectOf: CGSize(width: scale/2, height: scale/2), cornerRadius: 10)
        square.position = tilePositionOnScreen(x: x, y: y)
        square.fillColor = ColorPallete.SQUARE_TWO
        square.strokeColor = ColorPallete.SQUARE_TWO.darker(by: 50)
        self.addChild(square)
        return square
    }
    
    private func createTriangle(x: Int, y: Int) -> SKShapeNode {
        let triangle = SKShapeNode(path: roundedPolygonPath(size: scale/2.5, lineWidth: 5, sides: 3, cornerRadius: 10))
        triangle.position = tilePositionOnScreen(x: x, y: y)
        triangle.fillColor = ColorPallete.TRIANGLE
        triangle.strokeColor = ColorPallete.TRIANGLE.darker(by: 50)
        self.addChild(triangle)
        return triangle
    }
    
    private func createCircle(x: Int, y: Int) -> SKShapeNode {
        let circle = SKShapeNode(circleOfRadius: CGFloat(scale/4))
        circle.position = tilePositionOnScreen(x: x, y: y)
        circle.fillColor = ColorPallete.CIRCLE
        circle.strokeColor = ColorPallete.CIRCLE.darker(by: 50)
        self.addChild(circle)
        return circle
    }
    
    // MARK: Helper Functions
    // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
    
    // Assuming that puzzle was solved
    public func getFinalSprite() -> SKShapeNode? {
        // puzzle can only end with a square
        for x in 0 ..< layout.count {
            for y in 0 ..< layout[x].count {
                if spriteGrid[x][y] != nil && layout[x][y] == Puzzle.EMPTY {
                    return spriteGrid[x][y]
                }
            }
        }
        
        return nil
    }
    
    public func calcEndTile(start: (Int, Int), dir: (Int, Int)) -> (Int, Int) {
        var point = (start.0 + dir.0, start.1 + dir.1)
        while inBounds(point: point) {
            if layout[point.0][point.1] > 0 {
                return point
            }
            point = (point.0 + dir.0, point.1 + dir.1)
        }
        
        return (-1, -1)
    }
    
    public func tilePositionFromScreen(x: Double, y: Double) -> (Int, Int) {
        let x = Int(x/scale + Double(layout.count)/2)
        let y = Int(y/scale + Double(layout[0].count)/2)
        return (x, y)
    }
    
    private func tilePositionOnScreen(x: Int, y: Int) -> CGPoint {
        let dx = (Double(x) - Double(layout.count)/2 + 0.5) * scale
        let dy = (Double(y) - Double(layout[0].count)/2 + 0.5) * scale
        return CGPoint(x: dx, y: dy)
    }
    
    func roundedPolygonPath(size: Double, lineWidth: Double, sides: Int, cornerRadius: Double) -> CGPath {
        let path = UIBezierPath()
        let theta = 2.0 * Double.pi / Double(sides)
        let offset = cornerRadius * tan(theta / 2.0)
        
        var length = size/10// - lineWidth
        if sides % 4 != 0 {
            length *= cos(theta / 2.0) + offset/2.0
        }
        
        let sideLength = length * tan(theta / 2.0)
        var point = CGPoint(x: size / 20.0 + sideLength / 2.0 - offset, y: size/10 - (size/10 - length) / 2.0)
        var angle = Double.pi
        path.move(to: point)
        
        for _ in 0 ..< sides {
            point = CGPoint(x: Double(point.x) + (sideLength - offset * 2.0) * cos(angle), y: Double(point.y) + (sideLength - offset * 2.0) * sin(angle))
            path.addLine(to: point)
            let center = CGPoint(x: Double(point.x) + cornerRadius * cos(angle + Double.pi / 2), y: Double(point.y) + cornerRadius * sin(angle + Double.pi / 2))
                
            path.addArc(withCenter: center, radius: CGFloat(cornerRadius), startAngle: CGFloat(angle - Double.pi / 2), endAngle: CGFloat(angle + theta - Double.pi / 2), clockwise: true)
                
            point = path.currentPoint
            angle += theta
        }
        
        
        path.close()
        path.apply(CGAffineTransform(rotationAngle: CGFloat(Double.pi)))
        return path.cgPath
    }
    
    func getSpriteGrid() -> [[SKShapeNode?]] {
        return spriteGrid
    }
    
    // MARK: Random Crap
    // ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- //
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
