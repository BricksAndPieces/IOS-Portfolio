//
//  Ball.swift
//  EpicPong
//
//  Created by 90307332 on 2/5/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import SpriteKit

class Ball: SKNode {
    
    var circle = SKShapeNode()
    let radius: CGFloat = 15
    
    override init() {
        super.init()
        circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = UIColor.white
        addChild(circle)
        
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = true
        physicsBody?.linearDamping = 0
        physicsBody?.angularDamping = 0
        physicsBody?.friction = 0.5
        physicsBody?.restitution = 1
        physicsBody?.categoryBitMask = BitMask.Ball
        physicsBody?.collisionBitMask = BitMask.Paddle
        physicsBody?.contactTestBitMask = BitMask.Paddle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
