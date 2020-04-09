//
//  Paddle.swift
//  EpicPong
//
//  Created by 90307332 on 2/5/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import SpriteKit

class Paddle: SKNode {

    var rectangle = SKShapeNode()
    
    override init() {
        super.init()
        rectangle = SKShapeNode(rectOf: CGSize(width: 150, height: 10))
        rectangle.fillColor = UIColor(red: 125/255, green: 132/155, blue: 145/255, alpha: 1)
        rectangle.lineWidth = 0
        addChild(rectangle)
        
        physicsBody = SKPhysicsBody(rectangleOf: rectangle.frame.size)
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0
        physicsBody?.angularDamping = 0
        physicsBody?.friction = 0
        physicsBody?.restitution = 0
        physicsBody?.categoryBitMask = BitMask.Paddle
        physicsBody?.collisionBitMask = BitMask.Ball
        physicsBody?.contactTestBitMask = BitMask.Ball
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
