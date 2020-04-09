//
//  GameScene.swift
//  Marble-Maze
//
//  Created by 90307332 on 2/24/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    
    private let mazeSize = 9
    private let mazeScale = 20
    private let intersectionHeight = 5
    private let stageDifficulty = 2 // make sure this is even otherwise break :(
    
    private let sensitivity = 25.0
    
    private let marble = Marble(radius: 5)
    private var mazeGen = MazeGenerator()
    private var motionManager: CMMotionManager!
    
    private var mazeSections = [SKNode]()
    private var stage = 1
    
    private var fastMode = false
    private var gameSpeed = CGFloat(0.1)
    private var gameSpeedFast = CGFloat(5)
    
    // MARK: Override Methods
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        //marble.position = CGPoint(x: size.width/2-100, y: size.height / 2 - 250)
        marble.position = CGPoint(x: 0, y: size.height / 2 - 325)
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 0
        self.physicsBody = border
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        let start = createStart(width: mazeSize, scale: mazeScale)
        start.position.y = CGFloat((mazeSize+stageDifficulty+(intersectionHeight*2))*mazeScale)
        mazeSections.append(start)
        addChild(start)
        
        let intersection = createIntersection(stage: 1, width: mazeSize, height: 5, scale: mazeScale)
        intersection.position = CGPoint(x: 0, y: (mazeSize+stageDifficulty)*mazeScale)
        mazeSections.append(intersection)
        addChild(intersection)
        
        let mazeBody = createMaze(width: mazeSize, height: mazeSize+stageDifficulty, scale: mazeScale)
        mazeSections.append(mazeBody)
        addChild(mazeBody)
        
        addChild(marble)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let gyro = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: gyro.acceleration.x * sensitivity, dy: gyro.acceleration.y * sensitivity)
        }
        
        manageMazeScollingAndGrowth()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fastMode = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fastMode = false
    }
    
    // MARK: Maze Generation / Growth
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
    
    private func manageMazeScollingAndGrowth() {
        for section in mazeSections {
            if marble.position.y > 0 {
                section.position.y += fastMode ? gameSpeedFast : gameSpeed
            }else {
                section.position.y += (fastMode ? gameSpeedFast : gameSpeed)*2
            }
        }
        
        if (mazeSections.first?.position.y)! > size.height {
            mazeSections.removeFirst().removeFromParent()
        }
        
        let lastSection = mazeSections.last!
        if lastSection.position.y > -size.height/2 {
            var yPos = Int(lastSection.position.y) - 5*mazeScale
            yPos -= (mazeSize+stageDifficulty*stage+intersectionHeight)*mazeScale
            if lastSection.name == "Maze" {
                stage += 1
                gameSpeed *= 1.5
                let node = createIntersection(stage: stage, width: mazeSize, height: 5, scale: mazeScale)
                node.position.y = CGFloat(yPos)
                mazeSections.append(node)
                addChild(node)
            }else {
                yPos += (intersectionHeight*2)*mazeScale
                let node = createMaze(width: mazeSize, height: mazeSize+stageDifficulty*stage, scale: mazeScale)
                node.position.y = CGFloat(yPos)
                mazeSections.append(node)
                addChild(node)
            }
        }
    }
    
    // MARK: Maze Sprite Creation
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
    
    private func createMaze(width: Int, height: Int, scale: Int) -> SKNode {
        let mazeLayout = mazeGen.generateMaze(width: width, height: height, startX: 1, startY: 1)
        let maze = SKNode()
        maze.position = CGPoint(x: 0, y: 0)
        maze.name = "Maze"
        
        createMazeBlocks(root: maze, layout: mazeLayout, scale: scale)
        return maze
    }
    
    private func createMazeBlocks(root: SKNode, layout: [[Bool]], scale: Int) {
        var points = [(Int, Int)]()
        for y in 0 ..< layout[0].count {
            var blockSize = 0
            for x in 0 ... layout.count {
                if x < layout.count && layout[x][y]  {
                    blockSize += 1
                    if blockSize == 1 {
                        points.append((x, y))
                    }else if blockSize == 2 {
                        points.removeLast()
                    }
                }else {
                    if blockSize > 1 {
                        root.addChild(createMazeBlock(maze: layout, x: x, y: y, blockSize: blockSize, scale: scale, upDown: false))
                    }
                    
                    blockSize = 0
                }
            }
        }

        for x in 0 ..< layout.count {
            var blockSize = 0
            for y in 0 ... layout[0].count {
                if y < layout[0].count && layout[x][y] && points.contains(where: {$0.0 == x && $0.1 == y}) {
                    blockSize += 1
                }else {
                    if blockSize > 0 {
                        root.addChild(createMazeBlock(maze: layout, x: x, y: y, blockSize: blockSize, scale: scale, upDown: true))
                        blockSize = 0
                    }
                }
            }
        }
    }
    
    private func createMazeBlock(maze: [[Bool]], x: Int, y: Int, blockSize: Int, scale: Int, upDown: Bool) -> SKShapeNode {
        let node = SKShapeNode()
        node.fillColor = .red
        
        if !upDown {
            node.position = CGPoint(x: (x-maze.count-blockSize*2)*scale, y: (y-maze[0].count)*scale)
            node.path = UIBezierPath(rect: CGRect(x: x*scale, y: y*scale, width: scale*2*blockSize, height: scale*2)).cgPath
        }else {
            node.position = CGPoint(x: (x-maze.count)*scale, y: (y-maze[0].count-blockSize*2)*scale)
            node.path = UIBezierPath(rect: CGRect(x: x*scale, y: y*scale, width: scale*2, height: scale*2*blockSize)).cgPath
        }
        
        node.physicsBody = SKPhysicsBody(edgeLoopFrom: node.path!.boundingBox)
        return node
    }
    
    // MARK: Intersection Creation
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
    
    private func createIntersection(stage: Int, width:Int, height:Int, scale: Int) -> SKNode {
        let intersection = SKNode()
        intersection.position = CGPoint(x: 0, y: 0)
        intersection.name = "Intersection"
        
        let stageNumber = SKLabelNode(text: "STAGE \(stage)")
        stageNumber.fontName = "AvenirNext-Bold"
        stageNumber.fontSize = CGFloat(40)
        stageNumber.color = .white
        stageNumber.position = CGPoint(x: 0, y: height*scale-Int(stageNumber.fontSize/2))
        intersection.addChild(stageNumber)
        
        intersection.addChild(createBorderWall(width: width, height: height, scale: scale, invert: true))
        intersection.addChild(createBorderWall(width: width, height: height, scale: scale, invert: false))
        
        return intersection
    }
    
    private func createBorderWall(width: Int, height: Int, scale: Int, invert: Bool) -> SKShapeNode {
        let border = SKShapeNode()
        border.fillColor = .red
        border.position = CGPoint(x: invert ? -width*scale/2 : (width-2)*scale/2, y: 0)
        border.path = UIBezierPath(rect: CGRect(x: invert ? -width*scale/2 : (width-2)*scale/2, y: 0, width: scale*2, height: height*scale*2)).cgPath
        border.physicsBody = SKPhysicsBody(edgeLoopFrom: border.path!.boundingBox)
        return border
    }
    
    // MARK: Start Creation
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- //
    
    private func createStart(width: Int, scale: Int) -> SKShapeNode {
        let start = SKShapeNode()
        start.name = "Start"
        start.fillColor = .red
        start.position = CGPoint(x: -width*scale, y: 0)
        start.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: scale*width*2, height: scale*2)).cgPath
        start.physicsBody = SKPhysicsBody(edgeLoopFrom: start.path!.boundingBox)
        
        return start
    }
}
