//
//  GameScene.swift
//  DotPuzzle
//
//  Created by 90307332 on 3/10/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private let gridSize = 8
    private let startingDots = 0.25
    private let dotsPerMove = 3
    private let dotsToScore = 4
    private let dotTypes = 3
    
    private let scale = 60
    private let colors: [UIColor] = [.red, .blue, .green, .orange, .yellow]
    private let dirs = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
    
    private var grid = [[Int]]()
    private var gridSprites = [[SKShapeNode?]]()
    private var nextDots = [Int]()
    private var nextDotsSprites = [SKShapeNode]()
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
    
    override func didMove(to view: SKView) {
        let back = SKShapeNode(rect: CGRect(x: -scale*(gridSize-1)/2, y: -scale*(gridSize-1)/2, width: scale*gridSize, height: scale*gridSize), cornerRadius: 25)
        back.fillColor = .white
        addChild(back)
        
        
        for x in 0 ..< 8 {
            var row = [Int]()
            var rowSprite = [SKShapeNode?]()
            for y in 0 ..< 8 {
                rowSprite.append(nil)
                row.append(Double.random(in: 0...1) < startingDots ? Int.random(in: 1...dotTypes) : 0);
                
                if row[y] > 0 {
                    let circle = SKShapeNode(circleOfRadius: 20)
                    circle.fillColor = colors[row[y]-1]
                    circle.position = CGPoint(x: gridSize*scale/2-scale*x, y: gridSize*scale/2-scale*y)
                    rowSprite[y] = circle
                    addChild(circle)
                }
            }
            
            grid.append(row)
            gridSprites.append(rowSprite)
        }
        
        let rect = SKShapeNode(rect: CGRect(x: -scale*(dotsPerMove-1)/2, y: scale*(gridSize+2)/2, width: scale*dotsPerMove, height: scale), cornerRadius: 25)
        rect.fillColor = .white
        addChild(rect)
        
        for i in 0 ..< dotsPerMove  {
            nextDots.append(Int.random(in: 1...dotTypes))
            let circle = SKShapeNode(circleOfRadius: 20)
            circle.fillColor = colors[nextDots[i]-1]
            circle.position = CGPoint(x: dotsPerMove*scale/2-scale*i, y: scale*(gridSize+3)/2)
            nextDotsSprites.append(circle)
            addChild(circle)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        placeNextDots()
        removeScoringDots()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
    
    private func placeNextDots() {
        if gameOver() {
            return
        }
        
        var newPos = [CGPoint]()
        while newPos.count < dotsPerMove {
            let x = Int.random(in: 0 ..< gridSize)
            let y = Int.random(in: 0 ..< gridSize)
            if grid[x][y] == 0 {
                grid[x][y] = nextDots[newPos.count]
                newPos.append(CGPoint(x: x, y: y))
                
                if gameOver() {
                    break
                }
            }
        }
        
        for i in 0 ..< dotsPerMove  {
            if i == newPos.count {
                break
            }
            
            let x = Int(newPos[i].x)
            let y = Int(newPos[i].y)
            
            gridSprites[x][y] = nextDotsSprites[i]
            nextDotsSprites[i].run(SKAction.move(to: CGPoint(x: gridSize*scale/2-scale*x, y: gridSize*scale/2-scale*y), duration: 0.2))
            
            nextDots[i] = Int.random(in: 1...dotTypes)
            let circle = SKShapeNode(circleOfRadius: 20)
            circle.fillColor = colors[nextDots[i]-1]
            circle.position = CGPoint(x: dotsPerMove*scale/2-scale*i, y: scale*(gridSize+3)/2)
            nextDotsSprites[i] = circle
            addChild(circle)
        }
    }
    
    private func removeScoringDots() {
        for x in 0 ..< gridSize {
            for y in 0 ..< gridSize {
                for dir in dirs {
                    if grid[x][y] == 0 {
                        continue
                    }
                    
                    var dx = x, dy = y
                    var scoringDots = [(Int, Int)]()
                    while true {
                        if dx >= 0 && dy >= 0 && dx < gridSize && dy < gridSize && grid[x][y] == grid[dx][dy] {
                            scoringDots.append((dx, dy))
                            
                            dx += dir.0
                            dy += dir.1
                        }else {
                            break
                        }
                    }
                    
                    if scoringDots.count >= dotsToScore {
                        for dot in scoringDots {
                            grid[dot.0][dot.1] = 0
                            gridSprites[dot.0][dot.1]?.run(SKAction.sequence([SKAction.scale(to: 0, duration: 0.5), SKAction.removeFromParent()]))
                        }
                    }
                }
            }
        }
    }
    
    private func gameOver() -> Bool {
        for x in 0 ..< gridSize {
            for y in 0 ..< gridSize {
                if grid[x][y] == 0 {
                    return false
                }
            }
        }
        
        return true
    }
}
