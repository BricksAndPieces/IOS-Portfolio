//
//  Helper.swift
//  EpicPong
//
//  Created by 90307332 on 2/7/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

func linearSpeed(_ dx: CGFloat, _ dy: CGFloat) -> CGFloat {
    return sqrt(pow(dx, 2) + pow(dy, 2))
}

extension GameScene {
    
    func contactBetween(_ contact: SKPhysicsContact, _ a: UInt32, _ b: UInt32, complete: () -> ()) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask
        
        if (maskA == a && maskB == b) || (maskA == b && maskB == a) {
            complete()
        }
    }
    
    func contactInstance(_ contact: SKPhysicsContact, _ a: UInt32, _ b: UInt32, complete: (_ node1: SKNode, _ node2: SKNode) -> ()) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask
        
        var bodyA = SKPhysicsBody()
        var bodyB = SKPhysicsBody()
        
        if (maskA == a && maskB == b) || (maskA == b && maskB == a) {
            if(maskA == a) {
                bodyA = contact.bodyA
                bodyB = contact.bodyB
            
            }else {
                bodyA = contact.bodyB
                bodyB = contact.bodyA
            }
        }
        
        complete(bodyA.node!, bodyB.node!)
    }
}
