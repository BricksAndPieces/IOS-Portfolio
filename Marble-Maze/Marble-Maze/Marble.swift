//
//  Marble.swift
//  Marble-Maze
//
//  Created by 90307332 on 2/24/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import SpriteKit

class Marble: SKNode {
    
    init(radius: Float) {
        super.init()
        let circle = SKShapeNode(circleOfRadius: CGFloat(radius))
        circle.fillColor = UIColor.white
        addChild(circle)
        
        physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius))
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = true
        physicsBody?.allowsRotation = true
        physicsBody?.linearDamping = 1
        physicsBody?.angularDamping = 0
        physicsBody?.friction = 0.5
        physicsBody?.restitution = 0.05
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
