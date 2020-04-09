//
//  GameScene.swift
//  EpicPong
//
//  Created by 90307332 on 2/5/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import SpriteKit

struct BitMask {
    static let Ball: UInt32 = 0x1 << 0
    static let Paddle: UInt32 = 0x1 << 1
}

enum GamePhase {
    case Ready
    case Playing
    case GameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let playerControl = true
    let paddleSpeed = 0.05
    let ballSpeed = 3
    
    var score1 = 0
    var score2 = 0
    
    var gamePhase = GamePhase.Ready
    
    var ball = Ball()
    var paddle1 = Paddle()
    var paddle2 = Paddle()
    var scoreLabel1 = SKLabelNode()
    var scoreLabel2 = SKLabelNode()
    
    // TODO: Get constraints working
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        paddle1.name = "paddle1"
        paddle2.name = "paddle2"
        
        scoreLabel1.position = CGPoint(x: 100, y: 30)
        scoreLabel2.position = CGPoint(x: size.width - 100, y: size.height - 30)
        scoreLabel2.zRotation = CGFloat.pi
        
        scoreLabel1.fontSize = 48
        scoreLabel2.fontSize = 48
        scoreLabel1.color = UIColor.white
        scoreLabel2.color = UIColor.white
        
        scoreLabel1.text = "Player1: 0"
        scoreLabel1.text = "Player2: 0"
        score1 = 0
        score2 = 0
        
        addChild(ball)
        addChild(paddle1)
        addChild(paddle2)
        addChild(scoreLabel1)
        addChild(scoreLabel2)
        
        resetGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gamePhase == .Ready {
            gamePhase = .Playing
            startGame()
            return
        }
        
        if gamePhase == .GameOver {
            gamePhase = .Ready
            resetGame()
            return
        }
        
        if playerControl {
            for touch in touches {
                let loc = touch.location(in: self)
                paddle1.run(SKAction.moveTo(x: loc.x, duration: paddleSpeed))
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if playerControl {
            for touch in touches {
                let loc = touch.location(in: self)
                paddle1.run(SKAction.moveTo(x: loc.x, duration: paddleSpeed))
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if(ball.physicsBody?.velocity.dy.isLess(than: CGFloat(0)) ?? true) {
            if !playerControl {
                paddle1.run(SKAction.moveTo(x: ball.position.x, duration: paddleSpeed))
            }
            paddle2.run(SKAction.moveTo(x: size.width/2, duration: 1))
        }else {
            paddle2.run(SKAction.moveTo(x: ball.position.x, duration: paddleSpeed))
            if !playerControl {
                paddle1.run(SKAction.moveTo(x: size.width/2, duration: 1))
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        contactInstance(contact, BitMask.Ball, BitMask.Paddle) { (node1, node2) in
            let paddle = node2 as! Paddle
            let w = paddle.rectangle.frame.width
            let h = paddle.rectangle.frame.height
            let r = paddle.position.x + w/2
            let dist = r - ball.position.x
            
            let minAngle = CGFloat.pi*1/6
            let maxAngle = CGFloat.pi*5/6
            let v = linearSpeed((ball.physicsBody?.velocity.dx)!, (ball.physicsBody?.velocity.dy)!)
            
            if(paddle.name == "paddle1") {
                if(ball.position.y > paddle.position.x + h/2) {
                    let angle = minAngle + (maxAngle - minAngle) * (dist / w)
                    ball.physicsBody?.velocity.dx = v*cos(angle)
                    ball.physicsBody?.velocity.dy = v*sin(angle)
                }
            }else if(paddle.name == "paddle2") {
                if(ball.position.y < paddle.position.x - h/2) {
                    let angle = -minAngle + (-maxAngle + minAngle) * (dist / w)
                    ball.physicsBody?.velocity.dx = v*cos(angle)
                    ball.physicsBody?.velocity.dy = v*sin(angle)
                }
            }
        }
    }
    
    override func didSimulatePhysics() {
        if(ball.position.x <= 0 || ball.position.x >= size.width) {
            ball.physicsBody?.velocity.dx *= -1
        }
        
        if gamePhase == .GameOver {
            return
        }
        
        if(ball.position.y <= 0) {
            score2 += 1
            scoreLabel2.text = "Player2: " + String(score2)
            gamePhase = .GameOver
        }else if(ball.position.y >= size.height) {
            score1 += 1
            scoreLabel1.text = "Player1: " + String(score1)
            gamePhase = .GameOver
        }
    }
    
    func startGame() {
        ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: 10...15)*ballSpeed, dy: Int.random(in: 10...15)*ballSpeed))
    }
    
    func resetGame() {
        ball.position = CGPoint(x: size.width/2, y: size.height/2)
        paddle1.position = CGPoint(x: size.width/2, y: 50)
        paddle2.position = CGPoint(x: size.width/2, y: size.height-50)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
    }
}
